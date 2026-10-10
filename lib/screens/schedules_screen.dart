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
  DateTime _travelDate = DateTime.now().add(const Duration(days: 1));

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
        title: const Text(
          'Train Schedules & Search',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: -0.2,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.secondary,
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorWeight: 3,
          labelColor: AppColors.secondary,
          unselectedLabelColor: AppColors.textMuted,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(
              text: 'Search Trains',
              icon: Icon(Icons.search_rounded, size: 20),
            ),
            Tab(
              text: 'Station Board',
              icon: Icon(Icons.departure_board_rounded, size: 20),
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
          // 1. STATION & DATE SELECTION CARD (High affordance)
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.borderHighlight, width: 1.2),
            ),
            child: Column(
              children: [
                // From & To Stations Row with Swap Button
                Row(
                  children: [
                    Expanded(
                      child: _buildStationSelector(
                        label: 'FROM STATION',
                        station: _fromStation,
                        onTap: () => _pickStation(isFrom: true),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Swap Departure & Destination',
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.swap_horiz_rounded,
                          color: AppColors.secondary,
                          size: 20,
                        ),
                      ),
                      onPressed: _swapStations,
                    ),
                    Expanded(
                      child: _buildStationSelector(
                        label: 'TO STATION',
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

                // Date Selection & Quota
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.calendar_month_rounded,
                              size: 16,
                              color: AppColors.secondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              DateFormat('EEE, dd MMM yyyy').format(_travelDate),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.shield_outlined,
                              size: 14, color: AppColors.secondary),
                          SizedBox(width: 4),
                          Text(
                            'General Quota',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // 2. SEARCH RESULTS HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Available Trains (${displayTrains.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Row(
                children: const [
                  Icon(Icons.bolt, size: 14, color: AppColors.secondary),
                  SizedBox(width: 4),
                  Text(
                    '1-Tap AI Booking',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // 3. TRAIN LIST CARDS
          ...displayTrains.map((train) => _buildTrainCard(train)),

          const SizedBox(height: AppSpacing.xxl),
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
    return Semantics(
      button: true,
      label: '$label: ${station.name} (${station.code}). Tap to change station.',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            crossAxisAlignment:
                isRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                station.code,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                station.name,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrainCard(Train train) {
    final fromStop =
        train.getStopForStation(_fromStation.code) ?? train.stops.first;
    final toStop = train.getStopForStation(_toStation.code) ?? train.stops.last;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Train number & Daily frequency
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
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      train.trainType,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.successContainer.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.success, width: 1),
                ),
                child: const Text(
                  'Runs Daily',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.success,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Journey Timing Summary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fromStop.scheduledDeparture,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    fromStop.station.name,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    'PF ${fromStop.platform}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  const Text(
                    '15h 40m',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  SizedBox(
                    width: 80,
                    child: Row(
                      children: const [
                        CircleAvatar(
                          radius: 3,
                          backgroundColor: AppColors.secondary,
                        ),
                        Expanded(
                          child: Divider(
                            color: AppColors.borderHighlight,
                            thickness: 1.5,
                          ),
                        ),
                        Icon(
                          Icons.train_rounded,
                          size: 14,
                          color: AppColors.secondary,
                        ),
                        Expanded(
                          child: Divider(
                            color: AppColors.borderHighlight,
                            thickness: 1.5,
                          ),
                        ),
                        CircleAvatar(
                          radius: 3,
                          backgroundColor: AppColors.secondary,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Direct Express',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    toStop.scheduledArrival,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    toStop.station.name,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    'PF ${toStop.platform}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Seat Class Cards with 1-Tap AI Booking
          SizedBox(
            height: 76,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: train.classes.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final sc = train.classes[i];
                final isAvailable = sc.isConfirmed;

                return Semantics(
                  button: true,
                  label:
                      'Class ${sc.code} (${sc.name}). Fare ₹${sc.fare.toInt()}. Status: ${sc.statusText}. Tap to book with Railo AI.',
                  child: InkWell(
                    onTap: () {
                      widget.aiAgentService
                          .executeAutomatedBookingFromCard(train, sc);
                      widget.onNavigateToAI();
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 130,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isAvailable
                              ? AppColors.secondary.withOpacity(0.5)
                              : AppColors.borderHighlight,
                          width: 1.2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                sc.code,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                '₹${sc.fare.toInt()}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.secondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                isAvailable
                                    ? Icons.check_circle_rounded
                                    : Icons.access_time_rounded,
                                size: 12,
                                color: isAvailable
                                    ? AppColors.success
                                    : AppColors.warning,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  sc.statusText,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isAvailable
                                        ? AppColors.success
                                        : AppColors.warning,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStationBoardTab() {
    final station = widget.railwayService.userBoardingStation;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Station Info Banner
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.departure_board_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Station Board: ${station.name}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Live platform assignments & departure schedule for next 4 hours:',
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Departures List
          ...widget.railwayService.trains.map((train) {
            final stop = train.getStopForStation(station.code) ??
                train.stops.first;
            final isDelay = train.delayMinutes > 0;

            return Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'PF ${stop.platform}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
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
                        Text(
                          'Towards ${train.destination.name} (${train.destination.code})',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        stop.actualDeparture,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            isDelay
                                ? Icons.warning_amber_rounded
                                : Icons.check_circle_rounded,
                            size: 12,
                            color: isDelay
                                ? AppColors.warning
                                : AppColors.success,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            !isDelay
                                ? 'On Time'
                                : '+${train.delayMinutes}m delay',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isDelay
                                  ? AppColors.warning
                                  : AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  void _pickStation({required bool isFrom}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text(
              isFrom ? 'Select Departure Station' : 'Select Destination Station',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ...widget.railwayService.allStations.map(
              (st) => ListTile(
                title: Text(
                  st.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  '${st.code} • ${st.city} • ${st.platforms} platforms',
                  style: const TextStyle(color: AppColors.textMuted),
                ),
                onTap: () {
                  setState(() {
                    if (isFrom) {
                      _fromStation = st;
                    } else {
                      _toStation = st;
                    }
                  });
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _travelDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 120)),
    );
    if (picked != null) {
      setState(() => _travelDate = picked);
    }
  }
}
