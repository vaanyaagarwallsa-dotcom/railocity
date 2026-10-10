import 'package:flutter/material.dart';
import '../models/railway_models.dart';
import '../theme/app_theme.dart';

class ConnectionRiskIndicator extends StatelessWidget {
  final ConnectingJourney connectingJourney;

  const ConnectionRiskIndicator({
    super.key,
    required this.connectingJourney,
  });

  @override
  Widget build(BuildContext context) {
    final leg1 = connectingJourney.firstLeg;
    final leg2 = connectingJourney.secondLeg;
    final scheduledBuffer = connectingJourney.scheduledTransferBufferMinutes;
    final delay = leg1.delayMinutes;
    final remainingBuffer = connectingJourney.remainingTransferBufferMinutes;
    final riskLevel = connectingJourney.riskLevel;

    Color riskColor;
    Color riskBg;
    IconData riskIcon;

    switch (riskLevel) {
      case ConnectionRiskLevel.criticalMiss:
        riskColor = AppColors.criticalRed;
        riskBg = AppColors.criticalRedContainerLight;
        riskIcon = Icons.error_rounded;
        break;
      case ConnectionRiskLevel.tight:
        riskColor = AppColors.warning;
        riskBg = AppColors.warningContainerLight;
        riskIcon = Icons.warning_amber_rounded;
        break;
      case ConnectionRiskLevel.safe:
        riskColor = AppColors.success;
        riskBg = AppColors.successContainerLight;
        riskIcon = Icons.check_circle_rounded;
        break;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      if (riskLevel == ConnectionRiskLevel.criticalMiss) {
        riskBg = AppColors.criticalRedContainerDark;
      } else if (riskLevel == ConnectionRiskLevel.tight) {
        riskBg = AppColors.warningContainerDark;
      } else {
        riskBg = AppColors.successContainerDark;
      }
    }

    return Semantics(
      label: 'Connecting journey risk analysis: ${connectingJourney.riskLabel}. Remaining transfer buffer: $remainingBuffer minutes.',
      container: true,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: riskLevel == ConnectionRiskLevel.safe
                ? Theme.of(context).colorScheme.outlineVariant
                : riskColor,
            width: riskLevel == ConnectionRiskLevel.safe ? 1 : 1.4,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Station + Risk Level Pill
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'INTERCHANGE CONNECTION IMPACT',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Transfer at ${connectingJourney.transferStation.name} (${connectingJourney.transferStation.code})',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: riskBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: riskColor.withOpacity(0.5), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(riskIcon, size: 14, color: riskColor),
                      const SizedBox(width: 5),
                      Text(
                        riskLevel == ConnectionRiskLevel.criticalMiss
                            ? 'CRITICAL RISK'
                            : (riskLevel == ConnectionRiskLevel.tight ? 'TIGHT BUFFER' : 'SAFE BUFFER'),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: riskColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // Connection Leg 1 and Leg 2 Sequence
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  // Leg 1 Row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'LEG 1',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${leg1.train.trainNumber} ${leg1.train.trainName}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'ETA: ${leg1.actualArrival}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: delay > 0 ? AppColors.criticalRed : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            'Sched: ${leg1.scheduledArrival}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Transfer Window Gauge Bar
                  Row(
                    children: [
                      const SizedBox(width: 40),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: riskBg,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: riskColor.withOpacity(0.4)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Scheduled Buffer: ${scheduledBuffer}m',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                'Remaining Buffer: ${remainingBuffer}m',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: riskColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Leg 2 Row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'LEG 2',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${leg2.train.trainNumber} ${leg2.train.trainName}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Dep: ${leg2.scheduledDeparture}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Platform ${leg2.platform}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            // Plain Language Summary
            Text(
              riskLevel == ConnectionRiskLevel.criticalMiss
                  ? '⚠️ With a remaining window of only ${remainingBuffer} minutes, transferring between Platform ${leg1.platform} and Platform ${leg2.platform} with luggage carries severe risk of missing the second train.'
                  : '✅ Transfer window of ${remainingBuffer} minutes is sufficient for platform transition at ${connectingJourney.transferStation.name}.',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
