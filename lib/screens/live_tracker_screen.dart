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
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.radar_rounded,
                    color: AppColors.secondary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Railocity',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    Text(
                      'Live Boarding & ETA Tracker',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'Ask Railo AI',
                icon: const Icon(Icons.auto_awesome, color: AppColors.secondary),
                onPressed: widget.onNavigateToAI,
              ),
              IconButton(
                tooltip: 'Select Boarding Station',
                icon: const Icon(Icons.location_on_outlined,
                    color: AppColors.textPrimary),
                onPressed: _showStationPickerSheet,
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
                // 1. Next Upcoming Train Quick Banner (if any active booking)
                if (nextBooking != null)
                  _buildNextBookingBanner(nextBooking),

                const SizedBox(height: AppSpacing.sm),

                // 2. Primary Live Boarding Arrival Countdown Card
                LiveCountdownCard(
                  railwayService: widget.railwayService,
                  onSelectStation: _showStationPickerSheet,
                  onSelectTrain: _showTrainPickerSheet,
                ),

                const SizedBox(height: AppSpacing.lg),

                // 3. Coach Position Guide on Platform
                if (train != null)
                  CoachLocatorWidget(
                    coaches: train.coaches,
                    highlightedCoach: nextBooking?.coach ?? 'B3',
                    platform: stop?.platform ?? 2,
                  ),

                const SizedBox(height: AppSpacing.lg),

                // 4. Quick Action Callout for Railo AI
                _buildAICalloutBanner(),

                const SizedBox(height: AppSpacing.lg),

                // 5. Complete Train Halts & Route Visualizer
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
                                  color: AppColors.secondary, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                  'Boarding station updated to ${station.name} (${station.code})'),
                            ],
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),

                const SizedBox(height: AppSpacing.xxl),
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
        margin: const EdgeInsets.only(bottom: AppSpacing.xs),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderHighlight, width: 1.2),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.bookmark_added_rounded,
                color: AppColors.secondary,
                size: 16,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'YOUR CONFIRMED TICKET',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.secondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${booking.trainName} • Coach ${booking.coach}, Seat ${booking.seatNumber}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                booking.departureTime,
                style: const TextStyle(
                  fontSize: 13,
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

  Widget _buildAICalloutBanner() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderHighlight, width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.smart_toy_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Automate Ticket Bookings',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Railo AI handles quota checks, PNR allocation & platform advice.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryContainer,
              foregroundColor: AppColors.secondary,
              minimumSize: const Size(72, 40),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: widget.onNavigateToAI,
            child: const Text(
              'Ask AI',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
              initialChildSize: 0.75,
              maxChildSize: 0.92,
              builder: (context, scrollController) {
                return Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Select Boarding Station',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Real-time ETA recalculates to this station',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded,
                                color: AppColors.textSecondary),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // Accessible Search Input
                      TextField(
                        controller: searchController,
                        onChanged: (_) => setModalState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Search station by name, code or city...',
                          prefixIcon: const Icon(Icons.search_rounded,
                              color: AppColors.secondary),
                          suffixIcon: searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
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
                        child: filteredStations.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.search_off_rounded,
                                        size: 40, color: AppColors.textMuted),
                                    const SizedBox(height: 8),
                                    Text(
                                      'No station found for "${searchController.text}"',
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.separated(
                                controller: scrollController,
                                itemCount: filteredStations.length,
                                separatorBuilder: (context, index) =>
                                    const Divider(
                                  color: AppColors.border,
                                  height: 1,
                                ),
                                itemBuilder: (context, index) {
                                  final station = filteredStations[index];
                                  final isSelected = station.code ==
                                      widget.railwayService.userBoardingStation
                                          .code;

                                  return ListTile(
                                    contentPadding:
                                        const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 2,
                                    ),
                                    leading: CircleAvatar(
                                      backgroundColor: isSelected
                                          ? AppColors.secondary
                                          : AppColors.surfaceContainerHigh,
                                      child: Text(
                                        station.code,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected
                                              ? Colors.black
                                              : AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      station.name,
                                      style: TextStyle(
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.w600,
                                        color: isSelected
                                            ? AppColors.secondary
                                            : AppColors.textPrimary,
                                        fontSize: 14,
                                      ),
                                    ),
                                    subtitle: Text(
                                      '${station.city} • ${station.platforms} platforms • Lift & Escalator',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                    trailing: isSelected
                                        ? const Icon(
                                            Icons.check_circle_rounded,
                                            color: AppColors.secondary,
                                          )
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Track Train Live',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Choose a train to view live countdown and speed telemetries:',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: AppColors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              ...widget.railwayService.trains.map((t) {
                final isSelected = t.trainNumber ==
                    widget.railwayService.activeTrackedTrain?.trainNumber;
                return Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryContainer.withOpacity(0.4)
                        : AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.secondary
                          : AppColors.border,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: 4,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.train_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      '${t.trainNumber} - ${t.trainName}',
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w600,
                        color: isSelected
                            ? AppColors.secondary
                            : AppColors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      '${t.source.code} ➔ ${t.destination.code} • ${t.currentSpeedKmph} km/h • ${t.delayMinutes == 0 ? "On Time" : "+${t.delayMinutes}m delay"}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.secondary,
                          )
                        : const Icon(
                            Icons.radio_button_unchecked_rounded,
                            color: AppColors.textMuted,
                          ),
                    onTap: () {
                      widget.railwayService.setActiveTrackedTrain(t);
                      Navigator.pop(context);
                    },
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
