import 'package:flutter/material.dart';
import '../services/railway_service.dart';
import '../theme/app_theme.dart';

class LiveCountdownCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final train = railwayService.activeTrackedTrain;
    final boardingStation = railwayService.userBoardingStation;
    final countdown = railwayService.formattedCountdownToBoarding;
    final stop = train?.getStopForStation(boardingStation.code);
    final platform = stop?.platform ?? 2;
    final delay = train?.delayMinutes ?? 0;
    final isDelayed = delay > 0;

    return Semantics(
      label:
          'Live train arrival countdown. Train ${train?.trainNumber ?? ''} ${train?.trainName ?? ''}. Arriving in $countdown at platform $platform.',
      container: true,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDelayed
                ? AppColors.warning.withOpacity(0.6)
                : Theme.of(context).colorScheme.outlineVariant,
            width: isDelayed ? 1.4 : 1.0,
          ),
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. TOP BAR: Train Selector + Live Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: onSelectTrain,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.train_rounded, size: 14, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text(
                          '${train?.trainNumber ?? ''} • ${train?.trainName ?? 'Select Train'}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.keyboard_arrow_down_rounded, size: 16),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isDelayed
                        ? AppColors.warningContainerLight
                        : AppColors.successContainerLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isDelayed ? AppColors.warning : AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        isDelayed ? '+$delay min Delay' : 'On Time',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: isDelayed
                              ? AppColors.onWarningContainerLight
                              : AppColors.onSuccessContainerLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // 2. MAIN COUNTDOWN & PLATFORM SECTION
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'ESTIMATED TIME TO BOARDING',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: 4),
                          InkWell(
                            onTap: onSelectStation,
                            child: Row(
                              children: [
                                Text(
                                  '@ ${boardingStation.code}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                                const Icon(Icons.edit_location_alt_outlined, size: 11),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        countdown,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).colorScheme.onSurface,
                          letterSpacing: -0.5,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainerLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'PLATFORM',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: AppColors.onPrimaryContainerLight,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$platform',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.sm),

            // 3. TELEMETRY & LIVE POSITION INFO
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.navigation_rounded, size: 14, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      train?.currentLocationDescription ?? 'Tracking train GPS signal',
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${train?.currentSpeedKmph ?? 0} km/h',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
