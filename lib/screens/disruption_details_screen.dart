import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/railway_models.dart';
import '../services/disruption_service.dart';
import '../services/railway_service.dart';
import '../theme/app_theme.dart';
import '../widgets/verified_source_badge.dart';
import '../widgets/data_freshness_header.dart';
import 'ai_recovery_screen.dart';
import 'alternative_journeys_screen.dart';

class DisruptionDetailsScreen extends StatelessWidget {
  final Disruption disruption;
  final DisruptionService disruptionService;
  final RailwayService railwayService;
  final VoidCallback? onNavigateToAIRecovery;

  const DisruptionDetailsScreen({
    super.key,
    required this.disruption,
    required this.disruptionService,
    required this.railwayService,
    this.onNavigateToAIRecovery,
  });

  @override
  Widget build(BuildContext context) {
    final isCritical = disruption.severity == DisruptionSeverity.critical;
    final train = disruptionService.activeConnectingJourney?.firstLeg.train ??
        railwayService.activeTrackedTrain ??
        railwayService.trains.first;
    final timeFormat = DateFormat('hh:mm a, dd MMM');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Disruption Details'),
        actions: [
          IconButton(
            tooltip: 'Share Advisory',
            icon: const Icon(Icons.share_outlined, size: 20),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Disruption advisory copied to clipboard.'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          DataFreshnessHeader(disruptionService: disruptionService),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. EVENT STATUS HEADER CARD
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: isCritical
                          ? (Theme.of(context).brightness == Brightness.dark
                              ? AppColors.criticalRedContainerDark
                              : AppColors.criticalRedContainerLight)
                          : (Theme.of(context).brightness == Brightness.dark
                              ? AppColors.warningContainerDark
                              : AppColors.warningContainerLight),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isCritical ? AppColors.criticalRed : AppColors.warning,
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isCritical ? AppColors.criticalRed : AppColors.warning,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                isCritical ? 'CRITICAL DISRUPTION' : 'SERVICE ADVISORY',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const Spacer(),
                            VerifiedSourceBadge(source: disruption.source),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          disruption.title,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).colorScheme.onSurface,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Reported at ${timeFormat.format(disruption.timestamp)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // 2. TIMINGS COMPARISON CARD: Scheduled vs Estimated
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TIMING & SCHEDULE IMPACT',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Table(
                          border: TableBorder(
                            horizontalInside: BorderSide(
                              color: Theme.of(context).colorScheme.outlineVariant,
                              width: 1,
                            ),
                          ),
                          columnWidths: const {
                            0: FlexColumnWidth(1.4),
                            1: FlexColumnWidth(1),
                            2: FlexColumnWidth(1.2),
                          },
                          children: [
                            TableRow(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surfaceContainerLow,
                              ),
                              children: const [
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Station / Point', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Scheduled', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Estimated Arrival', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                                ),
                              ],
                            ),
                            TableRow(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    '${train.destination.name} (${train.destination.code})',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('08:35 AM', style: TextStyle(fontSize: 12)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    disruption.delayMinutes > 0
                                        ? '09:30 AM (+${disruption.delayMinutes}m)'
                                        : '08:35 AM (On Time)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: disruption.delayMinutes > 0 ? AppColors.criticalRed : AppColors.success,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // 3. PLAIN LANGUAGE DESCRIPTION & WALKING GUIDANCE
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'WHAT HAPPENED (PLAIN LANGUAGE)',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          disruption.plainDescription,
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context).colorScheme.onSurface,
                            height: 1.4,
                          ),
                        ),
                        if (disruption.walkingGuidance != null) ...[
                          const SizedBox(height: AppSpacing.sm),
                          const Divider(height: 1),
                          const SizedBox(height: AppSpacing.sm),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.directions_walk_rounded, size: 18, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Station Walking & Accessibility Instructions:',
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      disruption.walkingGuidance!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        height: 1.35,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // 4. OFFICIAL RAILWAY ADVICE & PASSENGER RIGHTS
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.gavel_rounded, size: 16, color: AppColors.primary),
                            SizedBox(width: 6),
                            Text(
                              'OFFICIAL RAILWAY GUIDELINES & REFUND RULES',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          disruption.officialAdvice,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // 5. CALL TO ACTION BUTTONS
                  if (disruption.isConnectingJourneyAffected) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.auto_awesome_rounded, size: 16),
                        label: const Text('Analyze Connection Impact & AI Recovery'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {
                          if (onNavigateToAIRecovery != null) {
                            Navigator.pop(context);
                            onNavigateToAIRecovery!();
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AIRecoveryScreen(
                                  disruptionService: disruptionService,
                                  railwayService: railwayService,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                  ],

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.alt_route_rounded, size: 16),
                      label: const Text('Explore Feasible Alternative Journeys'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AlternativeJourneysScreen(
                              disruptionService: disruptionService,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
