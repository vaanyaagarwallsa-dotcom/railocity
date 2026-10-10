import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/railway_service.dart';
import '../theme/app_theme.dart';

class LiveCountdownCard extends StatefulWidget {
  final RailwayService railwayService;
  final VoidCallback onSelectStation;
  final VoidCallback onSelectTrain;

  const LiveCountdownCard({
    super.key,
    required this.railwayService,
    required this.onSelectStation,
    required this.onSelectTrain,
  });

  @override
  State<LiveCountdownCard> createState() => _LiveCountdownCardState();
}

class _LiveCountdownCardState extends State<LiveCountdownCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final train = widget.railwayService.activeTrackedTrain;
    final boardingStation = widget.railwayService.userBoardingStation;
    final countdown = widget.railwayService.formattedCountdownToBoarding;
    final stop = train?.getStopForStation(boardingStation.code);
    final platform = stop?.platform ?? 2;
    final delay = train?.delayMinutes ?? 0;
    final isDelayed = delay > 0;

    return Semantics(
      label:
          'Live train arrival countdown card. Train ${train?.trainNumber ?? ''} ${train?.trainName ?? ''}. Arriving in $countdown at platform $platform.',
      container: true,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isDelayed
                ? AppColors.warning.withOpacity(0.4)
                : AppColors.primary.withOpacity(0.35),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.surfaceContainerLow,
                  AppColors.surface,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. TOP BAR: Train Selector Pill + Live GPS status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Train Selector Button
                    InkWell(
                      onTap: widget.onSelectTrain,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.borderHighlight,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.train_rounded,
                              size: 16,
                              color: AppColors.secondary,
                            ),
                            const SizedBox(width: 6),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 160),
                              child: Text(
                                train != null
                                    ? '${train.trainNumber} • ${train.trainName}'
                                    : 'Select Train',
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 18,
                              color: AppColors.textMuted,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Live GPS Pulse Indicator
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.success.withOpacity(0.4),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Transform.scale(
                                scale: _pulseAnimation.value,
                                child: Container(
                                  width: 7,
                                  height: 7,
                                  decoration: const BoxDecoration(
                                    color: AppColors.success,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'LIVE GPS',
                                style: TextStyle(
                                  color: AppColors.success,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),

                // 2. MAIN COUNTDOWN & ARRIVAL STATUS
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ARRIVING IN',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          countdown,
                          style: const TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                            color: AppColors.textPrimary,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),

                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isDelayed
                            ? AppColors.warningContainer.withOpacity(0.7)
                            : AppColors.successContainer.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDelayed
                              ? AppColors.warning
                              : AppColors.success,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isDelayed
                                ? Icons.warning_amber_rounded
                                : Icons.check_circle_rounded,
                            size: 14,
                            color: isDelayed
                                ? AppColors.warning
                                : AppColors.success,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            isDelayed ? '+$delay min' : 'On-Time',
                            style: TextStyle(
                              color: isDelayed
                                  ? AppColors.warning
                                  : AppColors.success,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.sm),

                // Live Location Telemetry
                Row(
                  children: [
                    const Icon(
                      Icons.navigation_rounded,
                      size: 13,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        train?.currentLocationDescription ?? 'In transit',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),

                // 3. BOARDING STATION ROW
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 16,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Boarding at:',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${boardingStation.name} (${boardingStation.code})',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      InkWell(
                        onTap: widget.onSelectStation,
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Change',
                            style: TextStyle(
                              color: AppColors.secondaryLight,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.md),
                const Divider(color: AppColors.border, height: 1),
                const SizedBox(height: AppSpacing.md),

                // 4. TELEMETRY BADGES (Platform, Speed, Station Access)
                Row(
                  children: [
                    _buildTelemetryBadge(
                      icon: Icons.meeting_room_rounded,
                      label: 'Platform',
                      value: 'Plat $platform',
                      highlightColor: AppColors.secondary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    _buildTelemetryBadge(
                      icon: Icons.speed_rounded,
                      label: 'Speed',
                      value: '${train?.currentSpeedKmph ?? 0} km/h',
                      highlightColor: AppColors.info,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    _buildTelemetryBadge(
                      icon: Icons.accessible_forward_rounded,
                      label: 'Access',
                      value: 'Lift & FOB',
                      highlightColor: AppColors.primaryLight,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTelemetryBadge({
    required IconData icon,
    required String label,
    required String value,
    required Color highlightColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 12, color: highlightColor),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
