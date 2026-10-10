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
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.confirmation_number_rounded,
                    color: AppColors.secondary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Text(
                  'My Trips & Passes',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'Book New with AI',
                icon: const Icon(
                  Icons.add_circle_outline_rounded,
                  color: AppColors.secondary,
                  size: 22,
                ),
                onPressed: widget.onNavigateToAI,
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.secondary,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorWeight: 2.5,
              labelColor: AppColors.secondary,
              unselectedLabelColor: AppColors.textMuted,
              labelStyle:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              tabs: [
                Tab(
                  text: 'Upcoming (${bookings.length})',
                  icon: const Icon(Icons.confirmation_number_outlined, size: 16),
                ),
                const Tab(
                  text: 'Past Journeys',
                  icon: Icon(Icons.history_rounded, size: 16),
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
                          const SizedBox(height: AppSpacing.md),
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
                border: Border.all(color: AppColors.borderHighlight, width: 1),
              ),
              child: const Icon(
                Icons.confirmation_number_outlined,
                size: 48,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'No Active Trips',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300),
              child: const Text(
                'When you book a ticket or ask Railo AI to reserve a berth, your digital pass will appear here.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              icon: const Icon(Icons.smart_toy_rounded, size: 18),
              label: const Text('Book with Railo AI'),
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
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.history_toggle_off_rounded,
                size: 40,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'No Past Journeys',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'Completed train journeys will be archived here.',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context, Booking booking) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.borderHighlight),
          ),
          title: Row(
            children: const [
              Icon(Icons.warning_amber_rounded,
                  color: AppColors.error, size: 22),
              SizedBox(width: 8),
              Text(
                'Cancel Booking?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to cancel ticket for ${booking.passengerName} on ${booking.trainName}?',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.currency_rupee_rounded,
                        size: 16, color: AppColors.success),
                    const SizedBox(width: 4),
                    Text(
                      'Refund: ₹${(booking.fare * 0.9).toInt()} will be credited',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Keep Ticket'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                widget.bookingService.cancelBooking(booking.pnr);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Booking for PNR ${booking.pnr} cancelled.'),
                    backgroundColor: AppColors.surfaceContainerHigh,
                  ),
                );
              },
              child: const Text('Confirm Cancellation'),
            ),
          ],
        );
      },
    );
  }
}
