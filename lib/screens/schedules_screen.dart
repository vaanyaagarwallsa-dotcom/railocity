import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/railway_models.dart';
import '../services/railway_service.dart';
import '../services/ai_agent_service.dart';
import '../theme/app_theme.dart';

class SchedulesScreen extends StatefulWidget {
  final RailwayService railwayService;
  final AIAgentService aiAgentService;
  final VoidCallback onNavigateToAI;

  const SchedulesScreen({
    super.key,
    required this.railwayService,
    required this.aiAgentService,
    required this.onNavigateToAI,
  });

  @override
  State<SchedulesScreen> createState() => _SchedulesScreenState();
}

class _SchedulesScreenState extends State<SchedulesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Station _fromStation;
  late Station _toStation;
  late Station _boardStation;
  DateTime _travelDate = DateTime.now().add(const Duration(days: 1));

  // Selected class cache per train
  final Map<String, SeatClass> _selectedClasses = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fromStation = RailwayService.ndls;
    _toStation = RailwayService.mmct;
    _boardStation = RailwayService.ndls;
  }

  @override
  void dispose() {
    _tabController.dispose();
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
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.calendar_month_rounded,
                color: AppColors.secondary,
                size: 18,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            const Text(
              'Train Schedules',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.secondary,
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorWeight: 2.5,
          labelColor: AppColors.secondary,
          unselectedLabelColor: AppColors.textMuted,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(
              text: 'Search Trains',
              icon: Icon(Icons.search_rounded, size: 16),
            ),
            Tab(
              text: 'Station Board',
              icon: Icon(Icons.departure_board_rounded, size: 16),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTrainSearchTab(),
          _buildStationBoardTab(),
        ],
      ),
    );
  }

  Widget _buildTrainSearchTab() {
    final searchResults =
        widget.railwayService.searchTrains(_fromStation.code, _toStation.code);
    final displayTrains = searchResults.isNotEmpty
        ? searchResults
        : widget.railwayService.trains;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. STATION & DATE SEARCH CARD
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderHighlight, width: 1),
            ),
            child: Column(
              children: [
                // From & To Stations Row with Swap Button
                Row(
                  children: [
                    Expanded(
                      child: _buildStationSelector(
                        label: 'FROM',
                        station: _fromStation,
                        onTap: () => _pickStation(isFrom: true),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Swap Departure & Destination',
                      icon: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.swap_horiz_rounded,
                          color: AppColors.secondary,
                          size: 18,
                        ),
                      ),
                      onPressed: _swapStations,
                    ),
                    Expanded(
                      child: _buildStationSelector(
                        label: 'TO',
                        station: _toStation,
                        onTap: () => _pickStation(isFrom: false),
                        isRight: true,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.sm),
                const Divider(color: AppColors.border),
                const SizedBox(height: AppSpacing.sm),

                // Date Selection Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.calendar_today_rounded,
                              size: 14,
                              color: AppColors.secondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              DateFormat('EEE, dd MMM yyyy').format(_travelDate),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Quota Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'General Quota (GN)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Quick Popular Route Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildQuickRouteChip(
                    RailwayService.ndls, RailwayService.mmct, 'Delhi ➔ Mumbai'),
                const SizedBox(width: AppSpacing.xs),
                _buildQuickRouteChip(
                    RailwayService.ndls, RailwayService.bsb, 'Delhi ➔ Varanasi'),
                const SizedBox(width: AppSpacing.xs),
                _buildQuickRouteChip(
                    RailwayService.hwh, RailwayService.ndls, 'Howrah ➔ Delhi'),
                const SizedBox(width: AppSpacing.xs),
                _buildQuickRouteChip(
                    RailwayService.mas, RailwayService.sbc, 'Chennai ➔ Bengaluru'),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Results Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${displayTrains.length} Trains Available',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Showing confirmed berths',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // Train Cards List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: displayTrains.length,
            separatorBuilder: (context, i) =>
                const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              final train = displayTrains[index];
              return _buildTrainCard(train);
            },
          ),

          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildStationSelector({
    required String label,
    required Station station,
    required VoidCallback onTap,
    bool isRight = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 6.0),
        child: Column(
          crossAxisAlignment:
              isRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppColors.textMuted,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              station.code,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              station.name,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickRouteChip(Station from, Station to, String label) {
    final isSelected =
        _fromStation.code == from.code && _toStation.code == to.code;

    return ActionChip(
      label: Text(label),
      backgroundColor: isSelected
          ? AppColors.primaryContainer
          : AppColors.surfaceContainerLow,
      side: BorderSide(
        color: isSelected ? AppColors.secondary : AppColors.border,
      ),
      labelStyle: TextStyle(
        fontSize: 11,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        color: isSelected ? AppColors.secondaryLight : AppColors.textSecondary,
      ),
      onPressed: () {
        setState(() {
          _fromStation = from;
          _toStation = to;
        });
      },
    );
  }

  Widget _buildTrainCard(Train train) {
    final firstStop = train.stops.first;
    final lastStop = train.stops.last;
    final selectedClass = _selectedClasses[train.trainNumber] ??
        train.classes.firstWhere(
          (c) => c.isConfirmed,
          orElse: () => train.classes.first,
        );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderHighlight, width: 1),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Train Name + Train Type
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${train.trainNumber} • ${train.trainName}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Runs Daily • ${train.stops.length} Halts',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  train.trainType,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondaryLight,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // Journey Timing Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      firstStop.scheduledDeparture,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      firstStop.station.code,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Text(
                      '➔ 13h 45m ➔',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${lastStop.distanceKm.toInt()} km',
                      style: const TextStyle(
                        fontSize: 9,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      lastStop.scheduledArrival,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      lastStop.station.code,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Class Availability Pills
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: train.classes.map((c) {
                final isSelected = selectedClass.code == c.code;
                Color statusColor = AppColors.success;
                if (c.isRAC) statusColor = AppColors.warning;
                if (c.isWL) statusColor = AppColors.error;

                return Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedClasses[train.trainNumber] = c;
                      });
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryContainer
                            : AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.secondary
                              : AppColors.border,
                          width: isSelected ? 1.4 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                c.code,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? AppColors.secondaryLight
                                      : AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '₹${c.fare.toInt()}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            c.statusText,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Action Row
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(0, 40),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => _showBookingDialog(train, selectedClass),
                  child: Text(
                    'Book ${selectedClass.code} (₹${selectedClass.fare.toInt()})',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 40),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.radar_rounded, size: 14),
                label: const Text('Live Status', style: TextStyle(fontSize: 12)),
                onPressed: () {
                  widget.railwayService.setActiveTrackedTrain(train);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Tracking ${train.trainName} on Live Boarding tab'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStationBoardTab() {
    final liveBoard = widget.railwayService.getStationBoard(_boardStation.code);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Station Selector Card
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.borderHighlight),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_city_rounded,
                        color: AppColors.secondary, size: 20),
                    const SizedBox(width: AppSpacing.sm),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'STATION BOARD',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMuted,
                          ),
                        ),
                        Text(
                          '${_boardStation.name} (${_boardStation.code})',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(70, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    _showBoardStationPicker();
                  },
                  child: const Text('Change', style: TextStyle(fontSize: 11)),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          const Text(
            'Live Departures & Arrivals',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: liveBoard.length,
            separatorBuilder: (context, i) =>
                const SizedBox(height: AppSpacing.xs + 2),
            itemBuilder: (context, index) {
              final item = liveBoard[index];
              final train = item['train'] as Train;
              final stop = item['stop'] as TrainStop;
              final isDelayed = stop.delayMinutes > 0;

              return Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            stop.actualDeparture,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Plat ${stop.platform}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${train.trainNumber} ${train.trainName}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'To ${train.destination.name}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDelayed
                            ? AppColors.warningContainer.withOpacity(0.6)
                            : AppColors.successContainer.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isDelayed ? '+${stop.delayMinutes} min' : 'On Time',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isDelayed
                              ? AppColors.warning
                              : AppColors.success,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  void _pickStation({required bool isFrom}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final stations = widget.railwayService.allStations;
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isFrom ? 'Select Departure Station' : 'Select Arrival Station',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: ListView.separated(
                  itemCount: stations.length,
                  separatorBuilder: (c, i) =>
                      const Divider(color: AppColors.border, height: 1),
                  itemBuilder: (c, index) {
                    final s = stations[index];
                    return ListTile(
                      title: Text(
                        '${s.name} (${s.code})',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      subtitle: Text(
                        s.city,
                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                      onTap: () {
                        setState(() {
                          if (isFrom) {
                            _fromStation = s;
                          } else {
                            _toStation = s;
                          }
                        });
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showBoardStationPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final stations = widget.railwayService.allStations;
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Station Board',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: ListView.separated(
                  itemCount: stations.length,
                  separatorBuilder: (c, i) =>
                      const Divider(color: AppColors.border, height: 1),
                  itemBuilder: (c, index) {
                    final s = stations[index];
                    return ListTile(
                      title: Text(
                        '${s.name} (${s.code})',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        s.city,
                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                      onTap: () {
                        setState(() => _boardStation = s);
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _travelDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 120)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.surface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _travelDate = picked);
    }
  }

  void _showBookingDialog(Train train, SeatClass seatClass) {
    final nameCtrl = TextEditingController(text: 'Vaanya Agarwal');
    final ageCtrl = TextEditingController(text: '26');
    String gender = 'Female';
    String berth = 'Lower Berth';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                top: AppSpacing.lg,
                bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Book ${seatClass.code} Berth',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              '${train.trainNumber} ${train.trainName}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.secondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded,
                              color: AppColors.textMuted),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.md),
                    const Divider(color: AppColors.border),
                    const SizedBox(height: AppSpacing.md),

                    // Passenger Name
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Passenger Full Name',
                        prefixIcon: Icon(Icons.person_outline_rounded, size: 18),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    // Age & Gender
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: ageCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Age',
                              prefixIcon: Icon(Icons.cake_outlined, size: 18),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: gender,
                            dropdownColor: AppColors.surfaceContainerLow,
                            decoration: const InputDecoration(
                              labelText: 'Gender',
                            ),
                            items: ['Female', 'Male', 'Other']
                                .map((g) => DropdownMenuItem(
                                      value: g,
                                      child: Text(g,
                                          style: const TextStyle(fontSize: 13)),
                                    ))
                                .toList(),
                            onChanged: (v) {
                              if (v != null) setSheetState(() => gender = v);
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    // Berth Preference
                    DropdownButtonFormField<String>(
                      value: berth,
                      dropdownColor: AppColors.surfaceContainerLow,
                      decoration: const InputDecoration(
                        labelText: 'Berth Preference',
                        prefixIcon: Icon(Icons.bed_outlined, size: 18),
                      ),
                      items: [
                        'Lower Berth',
                        'Middle Berth',
                        'Upper Berth',
                        'Side Lower',
                        'Window Seat',
                        'No Preference'
                      ]
                          .map((b) => DropdownMenuItem(
                                value: b,
                                child:
                                    Text(b, style: const TextStyle(fontSize: 13)),
                              ))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setSheetState(() => berth = v);
                      },
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Fare Summary
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'TOTAL FARE',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Includes IRCTC service fees',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '₹${seatClass.fare.toInt()}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: AppColors.secondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Confirm Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          // Book ticket
                          widget.aiAgentService.bookingService.bookTicket(
                            train: train,
                            seatClass: seatClass.code,
                            source: _fromStation,
                            destination: _toStation,
                            travelDate: _travelDate,
                            passengerName: nameCtrl.text.trim().isEmpty
                                ? 'Vaanya Agarwal'
                                : nameCtrl.text.trim(),
                            passengerAge:
                                int.tryParse(ageCtrl.text.trim()) ?? 26,
                            passengerGender: gender,
                            berthType: berth,
                          );
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  '🎉 Ticket confirmed on ${train.trainName}! View in My Trips.'),
                              backgroundColor: AppColors.surfaceContainerHigh,
                            ),
                          );
                        },
                        child: const Text('Confirm & Pay ₹',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
