import 'package:flutter/material.dart';
import '../services/disruption_service.dart';
import '../theme/app_theme.dart';
import '../widgets/alternative_journey_card.dart';

class AlternativeJourneysScreen extends StatelessWidget {
  final DisruptionService disruptionService;

  const AlternativeJourneysScreen({
    super.key,
    required this.disruptionService,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: disruptionService,
      builder: (context, _) {
        final alternatives = disruptionService.alternativeJourneys;
        final connJourney = disruptionService.activeConnectingJourney;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Alternative Journeys'),
            actions: [
              IconButton(
                tooltip: 'Filter options',
                icon: const Icon(Icons.tune_rounded, size: 20),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('All alternatives ranked by earliest departure & lowest risk.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info banner explaining that booking redirects to IRCTC
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Alternatives are based on verified IRCTC timetable data. Selecting an option redirects you to the official booking portal.',
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                if (connJourney != null) ...[
                  Text(
                    'Alternatives from ${connJourney.transferStation.name} (${connJourney.transferStation.code})',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ranked by transfer feasibility after your estimated arrival at ${connJourney.firstLeg.actualArrival}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],

                if (alternatives.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        const Icon(Icons.train_outlined, size: 48, color: AppColors.textMutedLight),
                        const SizedBox(height: AppSpacing.sm),
                        const Text(
                          'No Active Disruptions Requiring Alternatives',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Your scheduled train is running on time. Alternative routing is calculated automatically when delays exceed connection thresholds.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...alternatives.map(
                    (alt) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: AlternativeJourneyCard(
                        alternative: alt,
                        onSelect: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Opening official IRCTC booking portal for ${alt.trainNumber} - ${alt.trainName}...'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
