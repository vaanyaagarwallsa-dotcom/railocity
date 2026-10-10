import 'package:flutter/material.dart';
import '../models/railway_models.dart';
import '../theme/app_theme.dart';
import 'verified_source_badge.dart';

class DisruptionBanner extends StatelessWidget {
  final Disruption disruption;
  final VoidCallback onTapDetails;
  final VoidCallback? onAnalyzeConnection;

  const DisruptionBanner({
    super.key,
    required this.disruption,
    required this.onTapDetails,
    this.onAnalyzeConnection,
  });

  @override
  Widget build(BuildContext context) {
    final isCritical = disruption.severity == DisruptionSeverity.critical;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isCritical
        ? (isDark ? AppColors.criticalRedContainerDark : AppColors.criticalRedContainerLight)
        : (isDark ? AppColors.warningContainerDark : AppColors.warningContainerLight);

    final borderColor = isCritical
        ? (isDark ? AppColors.criticalRedDark : AppColors.criticalRed)
        : (isDark ? AppColors.warningDark : AppColors.warning);

    final iconColor = isCritical ? AppColors.criticalRed : AppColors.warning;

    return Semantics(
      label: 'Disruption alert: ${disruption.title}. ${disruption.plainDescription}',
      container: true,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header: Severity + Title + Source
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isCritical ? Icons.warning_rounded : Icons.info_outline_rounded,
                      color: iconColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              isCritical ? 'CRITICAL DISRUPTION' : 'SERVICE ADVISORY',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: iconColor,
                                letterSpacing: 0.6,
                              ),
                            ),
                            const Spacer(),
                            VerifiedSourceBadge(source: disruption.source),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          disruption.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onSurface,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Middle Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: Text(
                disruption.plainDescription,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
            ),

            // Platform Shift guidance preview if present
            if (disruption.newPlatform != null)
              Container(
                margin: const EdgeInsets.fromLTRB(14, 8, 14, 4),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderColor.withOpacity(0.4), width: 0.8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.directions_walk_rounded, size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'New Platform: Platform ${disruption.newPlatform} (Was Plat ${disruption.originalPlatform ?? '2'})',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 6),
            const Divider(height: 1),

            // Bottom Action Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Row(
                children: [
                  TextButton.icon(
                    onPressed: onTapDetails,
                    icon: const Icon(Icons.info_outline_rounded, size: 15),
                    label: const Text('Disruption Details'),
                    style: TextButton.styleFrom(
                      foregroundColor: iconColor,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                  ),
                  const Spacer(),
                  if (disruption.isConnectingJourneyAffected && onAnalyzeConnection != null)
                    ElevatedButton.icon(
                      onPressed: onAnalyzeConnection,
                      icon: const Icon(Icons.auto_awesome_rounded, size: 14),
                      label: const Text('AI Recovery'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isCritical ? AppColors.criticalRed : AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        minimumSize: const Size(0, 36),
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
