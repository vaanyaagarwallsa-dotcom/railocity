import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/railway_models.dart';
import '../theme/app_theme.dart';

class TicketPassCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback? onTrackTrain;
  final VoidCallback? onCancel;

  const TicketPassCard({
    super.key,
    required this.booking,
    this.onTrackTrain,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEE, dd MMM yyyy');

    return Semantics(
      label:
          'Ticket Pass for Train ${booking.trainNumber} ${booking.trainName}. PNR ${booking.pnrChunked}. Coach ${booking.coach}, Seat ${booking.seatNumber}. Departure from ${booking.sourceStation.name} at ${booking.departureTime}.',
      container: true,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.borderHighlight, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            // 1. TOP HEADER BANNER
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(22),
                  topRight: Radius.circular(22),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.confirmation_number_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        '${booking.trainNumber} • ${booking.trainName}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle_outline_rounded,
                          size: 11,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          booking.status,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 2. MAIN JOURNEY DETAILS
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  // Station to Station row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Source
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking.sourceStation.code,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              booking.sourceStation.name,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              booking.departureTime,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Train Icon & Date
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.arrow_forward_rounded,
                              color: AppColors.textMuted,
                              size: 18,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              dateFormat.format(booking.travelDate),
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Destination
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              booking.destinationStation.code,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              booking.destinationStation.name,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              booking.arrivalTime,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Tear-off cutouts & dashed line
                  _buildTearOffSeparator(),

                  const SizedBox(height: AppSpacing.md),

                  // 3. PASSENGER & BERTH INFO
                  Row(
                    children: [
                      _buildInfoBlock(
                        'PASSENGER',
                        '${booking.passengerName} (${booking.passengerAge})',
                      ),
                      _buildInfoBlock(
                        'CLASS',
                        booking.seatClass,
                      ),
                      _buildInfoBlock(
                        'COACH / SEAT',
                        '${booking.coach} - ${booking.seatNumber}',
                        isHighlighted: true,
                      ),
                      _buildInfoBlock(
                        'BERTH',
                        booking.berthType,
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // 4. PNR CHUNKED BOX
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'PNR: ',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              booking.pnrChunked,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: booking.pnr));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('PNR copied to clipboard!'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                          child: Row(
                            children: const [
                              Icon(
                                Icons.copy_rounded,
                                size: 12,
                                color: AppColors.secondary,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Copy',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // 5. ACTION BUTTONS
                  Row(
                    children: [
                      if (onTrackTrain != null)
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(0, 42),
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: const Icon(Icons.radar_rounded, size: 16),
                            label: const Text(
                              'Live Track',
                              style: TextStyle(fontSize: 13),
                            ),
                            onPressed: onTrackTrain,
                          ),
                        ),
                      if (onCancel != null) ...[
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                              side: BorderSide(
                                  color: AppColors.error.withOpacity(0.5)),
                              minimumSize: const Size(0, 42),
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: onCancel,
                            child: const Text(
                              'Cancel',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBlock(String label, String value, {bool isHighlighted = false}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isHighlighted ? AppColors.secondaryLight : AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTearOffSeparator() {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: const BoxDecoration(
            color: AppColors.background,
            shape: BoxShape.circle,
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              const dashWidth = 5.0;
              const dashSpace = 4.0;
              final dashCount =
                  (constraints.constrainWidth() / (dashWidth + dashSpace)).floor();
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(dashCount, (_) {
                  return const SizedBox(
                    width: dashWidth,
                    height: 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: AppColors.borderHighlight),
                    ),
                  );
                }),
              );
            },
          ),
        ),
        Container(
          width: 12,
          height: 12,
          decoration: const BoxDecoration(
            color: AppColors.background,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}
