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
                      size: 18,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs + 2),
                  const Text(
                    'Route Halts & Telemetry',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Text(
                '${train.stops.length} halts • ${train.source.code} ➔ ${train.destination.code}',
                style: const TextStyle(
                  fontSize: 12,
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
                  borderRadius: BorderRadius.circular(14),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Timeline Column (Dot & connecting line)
                        SizedBox(
                          width: 36,
                          child: Column(
                            children: [
                              _buildTimelineNode(
                                isPassed: isPassed,
                                isCurrent: isCurrentTrainStop,
                                isBoarding: isBoardingStation,
                              ),
                              if (!isLast)
                                Container(
                                  width: 3,
                                  height: 58,
                                  decoration: BoxDecoration(
                                    color: isPassed
                                        ? AppColors.success.withOpacity(0.6)
                                        : AppColors.borderHighlight,
                                    borderRadius: BorderRadius.circular(2),
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
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                            decoration: BoxDecoration(
                              color: isBoardingStation
                                  ? AppColors.primaryContainer.withOpacity(0.35)
                                  : (isCurrentTrainStop
                                      ? AppColors.surfaceContainerHigh
                                      : AppColors.surface),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isBoardingStation
                                    ? AppColors.secondary
                                    : (isCurrentTrainStop
                                        ? AppColors.primaryLight
                                        : AppColors.border),
                                width: isBoardingStation ? 1.8 : 1.2,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        stop.station.name,
                                        style: TextStyle(
                                          fontWeight: isBoardingStation
                                              ? FontWeight.bold
                                              : FontWeight.w600,
                                          fontSize: 14,
                                          color: isPassed
                                              ? AppColors.textMuted
                                              : AppColors.textPrimary,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceContainerHighest,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        stop.station.code,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    if (isBoardingStation)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.secondaryContainer,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          border: Border.all(
                                            color: AppColors.secondary,
                                            width: 1,
                                          ),
                                        ),
                                        child: const Text(
                                          'YOUR BOARDING',
                                          style: TextStyle(
                                            color: AppColors.secondary,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 0.4,
                                          ),
                                        ),
                                      ),
                                    if (isCurrentTrainStop && !isBoardingStation)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.warningContainer,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          border: Border.all(
                                            color: AppColors.warning,
                                            width: 1,
                                          ),
                                        ),
                                        child: const Text(
                                          'TRAIN HERE',
                                          style: TextStyle(
                                            color: AppColors.warning,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 0.4,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.access_time_rounded,
                                          size: 13,
                                          color: isBoardingStation
                                              ? AppColors.secondary
                                              : AppColors.textMuted,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Arr: ${stop.actualArrival} (PF ${stop.platform})',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: isBoardingStation
                                                ? FontWeight.bold
                                                : FontWeight.w500,
                                            color: isBoardingStation
                                                ? AppColors.secondary
                                                : AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      '${stop.distanceKm.toInt()} km',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textMuted,
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
          color: AppColors.primary,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.6),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Center(
          child: Icon(Icons.train_rounded, size: 12, color: Colors.white),
        ),
      );
    }
    if (isBoarding) {
      return Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: AppColors.secondary,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withOpacity(0.5),
              blurRadius: 8,
            ),
          ],
        ),
        child: const Center(
          child: Icon(Icons.pin_drop_rounded, size: 10, color: Colors.black),
        ),
      );
    }
    if (isPassed) {
      return Container(
        width: 16,
        height: 16,
        decoration: const BoxDecoration(
          color: AppColors.success,
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(Icons.check_rounded, size: 11, color: Colors.white),
        ),
      );
    }
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.borderHighlight, width: 2),
      ),
    );
  }
}
