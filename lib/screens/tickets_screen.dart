import 'package:flutter/material.dart';
import '../models/railway_models.dart';
import '../services/booking_service.dart';
import '../services/railway_service.dart';
import '../theme/app_theme.dart';
import '../widgets/ticket_pass_card.dart';

class TicketsScreen extends StatefulWidget {
  final BookingService bookingService;
  final RailwayService railwayService;
  final VoidCallback onNavigateToLive;
  final VoidCallback onNavigateToAI;

  const TicketsScreen({
    super.key,
    required this.bookingService,
    required this.railwayService,
    required this.onNavigateToLive,
    required this.onNavigateToAI,
  });

  @override
  State<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.bookingService,
      builder: (context, _) {
        final bookings = widget.bookingService.bookings;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'My Trips & Passes',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: -0.2,
              ),
            ),
            actions: [
              IconButton(
                tooltip: 'Book New with AI',
                icon: const Icon(
                  Icons.add_circle_outline_rounded,
                  color: AppColors.secondary,
                ),
                onPressed: widget.onNavigateToAI,
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.secondary,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorWeight: 3,
              labelColor: AppColors.secondary,
              unselectedLabelColor: AppColors.textMuted,
              labelStyle:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              tabs: [
                Tab(
                  text: 'Upcoming Trips (${bookings.length})',
                  icon: const Icon(Icons.confirmation_number_rounded, size: 18),
                ),
                const Tab(
                  text: 'Past Journeys (0)',
                  icon: Icon(Icons.history_rounded, size: 18),
                ),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              // Tab 1: Active Upcoming Trips
              bookings.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: bookings.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: AppSpacing.lg),
                      itemBuilder: (context, index) {
                        final b = bookings[index];
                        return TicketPassCard(
                          booking: b,
                          onTrackTrain: () {
                            final train = widget.railwayService
                                .getTrainByNumber(b.trainNumber);
                            if (train != null) {
                              widget.railwayService.setActiveTrackedTrain(train);
                            }
                            widget.railwayService
                                .setUserBoardingStation(b.sourceStation);
                            widget.onNavigateToLive();
                          },
                          onCancel: () => _showCancelDialog(context, b),
                        );
                      },
                    ),

              // Tab 2: Past Journeys Empty State
              _buildPastTripsEmptyState(),
            ],
          ),
        );
      },
    );
  }

  /// Empty State adhering to Slide 19:
  /// 1. Explain the situation
  /// 2. Give context
  /// 3. Suggest the next action
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderHighlight, width: 1.5),
              ),
              child: const Icon(
                Icons.confirmation_number_outlined,
                size: 56,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'No Active Trips Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: const Text(
                'When you book a ticket or ask Railo AI to reserve a berth, your digital boarding pass will appear here with live PNR status.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(220, 48),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm + 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.auto_awesome_rounded, size: 18),
              label: const Text(
                'Book with Railo AI',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              onPressed: widget.onNavigateToAI,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPastTripsEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.history_rounded,
                size: 48,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'No Past Journeys',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Completed train trips and archived tickets will be stored here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Error Prevention & Recovery Pattern (Slide 32 & Slide 14)
  void _showCancelDialog(BuildContext context, Booking booking) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.borderHighlight),
          ),
          title: Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: AppColors.warning),
              SizedBox(width: 8),
              Text(
                'Cancel Ticket?',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to cancel PNR ${booking.pnrChunked} (${booking.trainName})?',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Estimated Refund:',
                          style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),
                        Text(
                          '₹${(booking.fare - 120).toInt()}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Standard IRCTC cancellation fee: ₹120. Refund processed in 24 hrs.',
                      style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Keep Ticket',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                widget.bookingService.cancelBooking(booking.pnr);
                Navigator.pop(dialogContext);

                // Provide instant feedback + Undo option (User Control / Recovery)
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Booking PNR ${booking.pnrChunked} was cancelled.',
                    ),
                    action: SnackBarAction(
                      label: 'UNDO',
                      textColor: AppColors.secondary,
                      onPressed: () {
                        // Re-create the booking
                        widget.bookingService.createBooking(
                          train: widget.railwayService
                                  .getTrainByNumber(booking.trainNumber) ??
                              widget.railwayService.trains.first,
                          sourceStation: booking.sourceStation,
                          destinationStation: booking.destinationStation,
                          travelDate: booking.travelDate,
                          seatClass: booking.seatClass,
                          passengerName: booking.passengerName,
                          passengerAge: booking.passengerAge,
                          passengerGender: booking.passengerGender,
                          preferredBerth: booking.berthType,
                        );
                      },
                    ),
                    duration: const Duration(seconds: 4),
                  ),
                );
              },
              child: const Text(
                'Confirm Cancellation',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}
