import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/railway_models.dart';
import '../services/railway_service.dart';
import '../services/booking_service.dart';
import '../theme/app_theme.dart';

class TrainSearchScreen extends StatefulWidget {
  final RailwayService railwayService;
  final BookingService bookingService;
  final void Function(Train) onTrackTrain;

  const TrainSearchScreen({
    super.key,
    required this.railwayService,
    required this.bookingService,
    required this.onTrackTrain,
  });

  @override
  State<TrainSearchScreen> createState() => _TrainSearchScreenState();
}

class _TrainSearchScreenState extends State<TrainSearchScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _trainQueryController = TextEditingController();
  final TextEditingController _pnrController = TextEditingController();

  late Station _fromStation;
  late Station _toStation;
  DateTime _travelDate = DateTime.now().add(const Duration(days: 1));

  List<String> _recentSearches = ['12952 Mumbai Rajdhani', '22436 Vande Bharat', 'NDLS ➔ MMCT', 'NDLS ➔ BSB'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fromStation = RailwayService.ndls;
    _toStation = RailwayService.mmct;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _trainQueryController.dispose();
    _pnrController.dispose();
    super.dispose();
  }

  void _swapStations() {
    setState(() {
      final temp = _fromStation;
      _fromStation = _toStation;
      _toStation = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search & Journey Setup'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: AppColors.primary,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
          tabs: const [
            Tab(text: 'By Station Route', icon: Icon(Icons.swap_horiz_rounded, size: 16)),
            Tab(text: 'By Train / PNR', icon: Icon(Icons.train_rounded, size: 16)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStationRouteTab(),
          _buildTrainOrPnrTab(),
        ],
      ),
    );
  }

  Widget _buildStationRouteTab() {
    final searchResults = widget.railwayService.searchTrains(_fromStation.code, _toStation.code);
    final displayTrains = searchResults.isNotEmpty ? searchResults : widget.railwayService.trains;
    final dateFormat = DateFormat('EEE, dd MMM');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. ROUTE SELECTOR CARD
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildStationPickerField('FROM', _fromStation, (st) => setState(() => _fromStation = st)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.swap_horizontal_circle_outlined, color: AppColors.primary),
                      onPressed: _swapStations,
                    ),
                    Expanded(
                      child: _buildStationPickerField('TO', _toStation, (st) => setState(() => _toStation = st)),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                const Divider(height: 1),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('JOURNEY DATE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.primary)),
                        Text(dateFormat.format(_travelDate), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _travelDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 120)),
                        );
                        if (picked != null) {
                          setState(() => _travelDate = picked);
                        }
                      },
                      child: const Text('Change Date'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // 2. RECENT SEARCHES CHIPS
          Row(
            children: const [
              Icon(Icons.history_rounded, size: 14, color: AppColors.textMutedLight),
              SizedBox(width: 4),
              Text('Recent Searches:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMutedLight)),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            children: _recentSearches.map((s) {
              return ActionChip(
                label: Text(s, style: const TextStyle(fontSize: 11)),
                onPressed: () {
                  if (s.contains('Mumbai')) {
                    setState(() {
                      _fromStation = RailwayService.ndls;
                      _toStation = RailwayService.mmct;
                    });
                  } else if (s.contains('BSB')) {
                    setState(() {
                      _fromStation = RailwayService.ndls;
                      _toStation = RailwayService.bsb;
                    });
                  }
                },
              );
            }).toList(),
          ),

          const SizedBox(height: AppSpacing.md),

          // 3. TRAIN RESULTS LIST
          Text(
            'Available Trains (${displayTrains.length})',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.xs),
          ...displayTrains.map((train) => _buildTrainSearchResultCard(train)),
        ],
      ),
    );
  }

  Widget _buildStationPickerField(String label, Station station, void Function(Station) onSelected) {
    return InkWell(
      onTap: () => _showStationListPicker(onSelected),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.primary)),
          const SizedBox(height: 2),
          Text(station.code, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primary)),
          Text(station.name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildTrainSearchResultCard(Train train) {
    final fromStop = train.getStopForStation(_fromStation.code) ?? train.stops.first;
    final toStop = train.getStopForStation(_toStation.code) ?? train.stops.last;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${train.trainNumber} • ${train.trainName}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainerLight,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  train.trainType,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(fromStop.scheduledDeparture, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                  Text(fromStop.station.name, style: const TextStyle(fontSize: 10, color: AppColors.textMutedLight)),
                ],
              ),
              const Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.primary),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(toStop.scheduledArrival, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                  Text(toStop.station.name, style: const TextStyle(fontSize: 10, color: AppColors.textMutedLight)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${train.classes.length} classes available',
                style: const TextStyle(fontSize: 11, color: AppColors.textMutedLight),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  widget.railwayService.setActiveTrackedTrain(train);
                  widget.onTrackTrain(train);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: const Size(0, 32),
                ),
                child: const Text('Track & Set Active', style: TextStyle(fontSize: 11)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrainOrPnrTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Direct Train Search Field
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'LOOKUP BY TRAIN NUMBER OR NAME',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.primary),
                ),
                const SizedBox(height: AppSpacing.xs),
                TextField(
                  controller: _trainQueryController,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: 'e.g. 12952, Rajdhani, Vande Bharat...',
                    prefixIcon: Icon(Icons.search_rounded, size: 18),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // 2. Direct PNR Import Field
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'IMPORT JOURNEY VIA 10-DIGIT PNR',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.primary),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _pnrController,
                        keyboardType: TextInputType.number,
                        maxLength: 10,
                        decoration: const InputDecoration(
                          hintText: 'e.g. 2849104821',
                          counterText: '',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (_pnrController.text.trim().length >= 10) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Journey imported for PNR ${_pnrController.text.trim()}'),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter a valid 10-digit railway PNR.'),
                            ),
                          );
                        }
                      },
                      child: const Text('Import'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showStationListPicker(void Function(Station) onSelected) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: widget.railwayService.allStations.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final st = widget.railwayService.allStations[index];
            return ListTile(
              title: Text('${st.name} (${st.code})', style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text('${st.city} • ${st.platforms} Platforms'),
              onTap: () {
                onSelected(st);
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }
}
