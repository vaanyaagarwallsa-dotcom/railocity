import 'package:flutter/material.dart';
import '../models/railway_models.dart';
import '../theme/app_theme.dart';

class RouteStepperWidget extends StatelessWidget {
  final Train train;
  final Station boardingStation;
  final ValueChanged<Station> onStationTap;

  const RouteStepperWidget({
    super.key,
    required this.train,
    required this.boardingStation,
    required this.onStationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          'Train route halts and live timeline for train ${train.trainNumber} ${train.trainName}.',
      container: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title & Route Summary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.timeline_rounded,
                      size: 16,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs + 2),
                  const Text(
                    'Route Timeline',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Text(
                '${train.stops.length} halts • ${train.source.code} ➔ ${train.destination.code}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Halts Timeline
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: train.stops.length,
            itemBuilder: (context, index) {
              final stop = train.stops[index];
              final isBoardingStation = stop.station.code.toUpperCase() ==
                  boardingStation.code.toUpperCase();
              final isCurrentTrainStop = index == train.currentStopIndex;
              final isPassed = index < train.currentStopIndex;
              final isLast = index == train.stops.length - 1;

              return Semantics(
                button: true,
                label:
                    'Station ${stop.station.name}, ${isPassed ? "Departed" : (isCurrentTrainStop ? "Current Train Location" : "Upcoming Halt")}. Scheduled arrival ${stop.actualArrival} at Platform ${stop.platform}.',
                child: InkWell(
                  onTap: () => onStationTap(stop.station),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Timeline Column (Dot & connecting line)
                        SizedBox(
                          width: 32,
                          child: Column(
                            children: [
                              _buildTimelineNode(
                                isPassed: isPassed,
                                isCurrent: isCurrentTrainStop,
                                isBoarding: isBoardingStation,
                              ),
                              if (!isLast)
                                Container(
                                  width: 2,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: isPassed
                                        ? AppColors.success.withOpacity(0.5)
                                        : AppColors.borderHighlight,
                                    borderRadius: BorderRadius.circular(1),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),

                        // Station Detail Card
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm + 2,
                              vertical: AppSpacing.sm,
                            ),
                            decoration: BoxDecoration(
                              color: isBoardingStation
                                  ? AppColors.primaryContainer.withOpacity(0.3)
                                  : (isCurrentTrainStop
                                      ? AppColors.surfaceContainerHigh
                                      : AppColors.surface),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isBoardingStation
                                    ? AppColors.secondary
                                    : (isCurrentTrainStop
                                        ? AppColors.primaryLight.withOpacity(0.5)
                                        : AppColors.border),
                                width: isBoardingStation ? 1.4 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              stop.station.name,
                                              style: TextStyle(
                                                fontWeight: isBoardingStation
                                                    ? FontWeight.bold
                                                    : FontWeight.w600,
                                                fontSize: 13,
                                                color: isPassed
                                                    ? AppColors.textMuted
                                                    : AppColors.textPrimary,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            '(${stop.station.code})',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: isBoardingStation
                                                  ? AppColors.secondary
                                                  : AppColors.textMuted,
                                            ),
                                          ),
                                          if (isBoardingStation) ...[
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: AppColors.secondaryContainer,
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: const Text(
                                                'YOUR BOARDING',
                                                style: TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w800,
                                                  color: AppColors.secondaryLight,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        'Platform ${stop.platform} • ${stop.distanceKm.toInt()} km',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      stop.actualArrival,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: isPassed
                                            ? AppColors.textMuted
                                            : AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      isPassed
                                          ? 'Departed'
                                          : (isCurrentTrainStop
                                              ? 'At Station'
                                              : 'Dep ${stop.actualDeparture}'),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: isPassed
                                            ? AppColors.textMuted
                                            : (isCurrentTrainStop
                                                ? AppColors.secondary
                                                : AppColors.textSecondary),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineNode({
    required bool isPassed,
    required bool isCurrent,
    required bool isBoarding,
  }) {
    if (isCurrent) {
      return Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: AppColors.secondary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withOpacity(0.5),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(
          Icons.train_rounded,
          size: 13,
          color: Colors.black,
        ),
      );
    }

    if (isBoarding) {
      return Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.secondary, width: 2),
        ),
        child: const Icon(
          Icons.location_on_rounded,
          size: 11,
          color: Colors.white,
        ),
      );
    }

    if (isPassed) {
      return Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.2),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.success, width: 1.5),
        ),
        child: const Icon(
          Icons.check_rounded,
          size: 10,
          color: AppColors.success,
        ),
      );
    }

    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.borderHighlight, width: 2),
      ),
    );
  }
}
