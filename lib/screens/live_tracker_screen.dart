import 'package:flutter/material.dart';
import '../models/railway_models.dart';
import '../services/railway_service.dart';
import '../services/booking_service.dart';
import '../theme/app_theme.dart';
import '../widgets/live_countdown_card.dart';
import '../widgets/coach_locator_widget.dart';
import '../widgets/route_stepper_widget.dart';

class LiveTrackerScreen extends StatefulWidget {
  final RailwayService railwayService;
  final BookingService bookingService;
  final VoidCallback onNavigateToAI;

  const LiveTrackerScreen({
    super.key,
    required this.railwayService,
    required this.bookingService,
    required this.onNavigateToAI,
  });

  @override
  State<LiveTrackerScreen> createState() => _LiveTrackerScreenState();
}

class _LiveTrackerScreenState extends State<LiveTrackerScreen> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation:
          Listenable.merge([widget.railwayService, widget.bookingService]),
      builder: (context, _) {
        final train = widget.railwayService.activeTrackedTrain;
        final boardingStation = widget.railwayService.userBoardingStation;
        final nextBooking = widget.bookingService.nextUpcomingBooking;
        final stop = train?.getStopForStation(boardingStation.code);

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
                    Icons.radar_rounded,
                    color: AppColors.secondary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Live Tracker',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    Text(
                      'Real-time train arrival & platform guide',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'Select Boarding Station',
                icon: const Icon(Icons.location_on_outlined,
                    color: AppColors.textPrimary, size: 22),
                onPressed: _showStationPickerSheet,
              ),
              IconButton(
                tooltip: 'Select Train',
                icon: const Icon(Icons.train_outlined,
                    color: AppColors.textPrimary, size: 22),
                onPressed: _showTrainPickerSheet,
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Confirmed booking hint banner (if any active trip)
                if (nextBooking != null)
                  _buildNextBookingBanner(nextBooking),

                // 2. Primary Live Countdown Card
                LiveCountdownCard(
                  railwayService: widget.railwayService,
                  onSelectStation: _showStationPickerSheet,
                  onSelectTrain: _showTrainPickerSheet,
                ),

                const SizedBox(height: AppSpacing.md),

                // 3. Coach Layout Position
                if (train != null)
                  CoachLocatorWidget(
                    coaches: train.coaches,
                    highlightedCoach: nextBooking?.coach ?? 'B3',
                    platform: stop?.platform ?? 2,
                  ),

                const SizedBox(height: AppSpacing.md),

                // 4. Complete Train Halts Timeline
                if (train != null)
                  RouteStepperWidget(
                    train: train,
                    boardingStation: boardingStation,
                    onStationTap: (station) {
                      widget.railwayService.setUserBoardingStation(station);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.check_circle_rounded,
                                  color: AppColors.secondary, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                  'Boarding station set to ${station.name} (${station.code})'),
                            ],
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),

                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNextBookingBanner(Booking booking) {
    return Semantics(
      label:
          'Next confirmed journey on ${booking.trainName}. Coach ${booking.coach}, Seat ${booking.seatNumber}. Departing at ${booking.departureTime}.',
      container: true,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs + 2,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderHighlight, width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.bookmark_added_rounded,
                color: AppColors.secondary,
                size: 14,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CONFIRMED TICKET',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: AppColors.secondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    '${booking.trainName} • Coach ${booking.coach}, Seat ${booking.seatNumber}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                booking.departureTime,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStationPickerSheet() {
    final searchController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final query = searchController.text.toLowerCase();
            final filteredStations = widget.railwayService.allStations.where((s) {
              return s.name.toLowerCase().contains(query) ||
                  s.code.toLowerCase().contains(query) ||
                  s.city.toLowerCase().contains(query);
            }).toList();

            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.7,
              maxChildSize: 0.9,
              builder: (context, scrollController) {
                return Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Select Boarding Station',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded,
                                color: AppColors.textMuted),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      // Search Input
                      TextField(
                        controller: searchController,
                        onChanged: (_) => setModalState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Search station by name, code or city...',
                          prefixIcon: const Icon(Icons.search_rounded,
                              color: AppColors.textMuted, size: 20),
                          suffixIcon: searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, size: 18),
                                  onPressed: () {
                                    searchController.clear();
                                    setModalState(() {});
                                  },
                                )
                              : null,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.sm),

                      // Station List
                      Expanded(
                        child: ListView.separated(
                          controller: scrollController,
                          itemCount: filteredStations.length,
                          separatorBuilder: (context, i) =>
                              const Divider(color: AppColors.border, height: 1),
                          itemBuilder: (context, index) {
                            final station = filteredStations[index];
                            final isCurrent =
                                station.code.toUpperCase() ==
                                    widget.railwayService.userBoardingStation
                                        .code
                                        .toUpperCase();

                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 2,
                              ),
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isCurrent
                                      ? AppColors.primary
                                      : AppColors.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  station.code,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: isCurrent
                                        ? Colors.white
                                        : AppColors.secondary,
                                  ),
                                ),
                              ),
                              title: Text(
                                station.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              subtitle: Text(
                                '${station.city} • ${station.platforms} Platforms • Accessibility Ready',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              trailing: isCurrent
                                  ? const Icon(Icons.check_circle_rounded,
                                      color: AppColors.secondary, size: 20)
                                  : null,
                              onTap: () {
                                widget.railwayService
                                    .setUserBoardingStation(station);
                                Navigator.pop(context);
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
          },
        );
      },
    );
  }

  void _showTrainPickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        final trains = widget.railwayService.trains;

        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.65,
          maxChildSize: 0.85,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Select Active Train',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded,
                            color: AppColors.textMuted),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      itemCount: trains.length,
                      separatorBuilder: (context, i) =>
                          const SizedBox(height: AppSpacing.xs),
                      itemBuilder: (context, index) {
                        final t = trains[index];
                        final isSelected = t.trainNumber ==
                            widget.railwayService.activeTrackedTrain?.trainNumber;

                        return InkWell(
                          onTap: () {
                            widget.railwayService.setActiveTrackedTrain(t);
                            Navigator.pop(context);
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primaryContainer.withOpacity(0.4)
                                  : AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.secondary
                                    : AppColors.border,
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceContainerHigh,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.train_rounded,
                                    color: AppColors.secondary,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${t.trainNumber} • ${t.trainName}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${t.source.code} ➔ ${t.destination.code} • ${t.trainType}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(Icons.check_circle_rounded,
                                      color: AppColors.secondary, size: 20),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
