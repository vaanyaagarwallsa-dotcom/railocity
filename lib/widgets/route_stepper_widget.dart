import 'package:flutter/material.dart';
import '../models/railway_models.dart';
import '../theme/app_theme.dart';

class RouteStepperWidget extends StatelessWidget {
  final Train train;
  final Station boardingStation;
  final void Function(Station) onStationTap;

  const RouteStepperWidget({
    super.key,
    required this.train,
    required this.boardingStation,
    required this.onStationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainerLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.alt_route_rounded, size: 16, color: AppColors.primary),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Route & Scheduled Halts',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Text(
                '${train.stops.length} Stops',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: train.stops.length,
            itemBuilder: (context, index) {
              final stop = train.stops[index];
              final isBoarding = stop.station.code.toUpperCase() == boardingStation.code.toUpperCase();
              final isPassed = index < train.currentStopIndex;
              final isCurrent = index == train.currentStopIndex;
              final hasDelay = stop.delayMinutes > 0;

              return InkWell(
                onTap: () => onStationTap(stop.station),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Time column
                      SizedBox(
                        width: 70,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              stop.actualArrival.isNotEmpty ? stop.actualArrival : stop.scheduledArrival,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isBoarding ? FontWeight.w800 : FontWeight.w600,
                                color: hasDelay ? AppColors.criticalRed : Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            if (hasDelay)
                              Text(
                                'Sched ${stop.scheduledArrival}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Stepper line and node
                      Column(
                        children: [
                          Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: isBoarding
                                  ? AppColors.primary
                                  : (isPassed ? Theme.of(context).colorScheme.surfaceContainerHighest : Colors.white),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isBoarding ? AppColors.primary : AppColors.primary.withOpacity(0.5),
                                width: 2,
                              ),
                            ),
                            child: isBoarding
                                ? const Center(child: Icon(Icons.check, size: 9, color: Colors.white))
                                : null,
                          ),
                          if (index < train.stops.length - 1)
                            Container(
                              width: 2,
                              height: 32,
                              color: isPassed
                                  ? Theme.of(context).colorScheme.surfaceContainerHighest
                                  : AppColors.primary.withOpacity(0.3),
                            ),
                        ],
                      ),

                      const SizedBox(width: 10),

                      // Station name & platform info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '${stop.station.name} (${stop.station.code})',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isBoarding ? FontWeight.w800 : (isCurrent ? FontWeight.w700 : FontWeight.w500),
                                    color: isBoarding ? AppColors.primary : Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                if (isBoarding) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryContainerLight,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'BOARDING',
                                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.primary),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Platform ${stop.platform} • ${stop.distanceKm.toInt()} km',
                              style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
