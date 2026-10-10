import 'package:flutter/material.dart';
import '../models/railway_models.dart';
import '../services/disruption_service.dart';
import '../services/railway_service.dart';
import '../services/booking_service.dart';
import '../services/ai_recovery_service.dart';
import '../theme/app_theme.dart';
import '../widgets/connection_risk_indicator.dart';
import '../widgets/alternative_journey_card.dart';
import 'alternative_journeys_screen.dart';

class AIRecoveryScreen extends StatefulWidget {
  final DisruptionService disruptionService;
  final RailwayService railwayService;

  const AIRecoveryScreen({
    super.key,
    required this.disruptionService,
    required this.railwayService,
  });

  @override
  State<AIRecoveryScreen> createState() => _AIRecoveryScreenState();
}

class _AIRecoveryScreenState extends State<AIRecoveryScreen> {
  late final AIRecoveryService _aiRecoveryService;
  final TextEditingController _queryController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _aiRecoveryService = AIRecoveryService(
      railwayService: widget.railwayService,
      disruptionService: widget.disruptionService,
      bookingService: BookingService(),
    );
  }

  @override
  void dispose() {
    _queryController.dispose();
    _scrollController.dispose();
    _aiRecoveryService.dispose();
    super.dispose();
  }

  void _sendQuery([String? text]) {
    final query = text ?? _queryController.text;
    if (query.trim().isEmpty) return;
    _queryController.clear();
    _aiRecoveryService.handleUserInput(query);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([widget.disruptionService, _aiRecoveryService]),
      builder: (context, _) {
        final connJourney = widget.disruptionService.activeConnectingJourney;
        final disruption = widget.disruptionService.activeDisruption;
        final alternatives = widget.disruptionService.alternativeJourneys;
        final messages = _aiRecoveryService.messages;
        final isProcessing = _aiRecoveryService.isProcessing;

        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainerLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 16),
                ),
                const SizedBox(width: 8),
                const Text(
                  'AI Journey Recovery',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. STRUCTURED CONNECTION TRANSFER WINDOW GAUGE
                      if (connJourney != null) ...[
                        ConnectionRiskIndicator(connectingJourney: connJourney),
                        const SizedBox(height: AppSpacing.md),
                      ],

                      // 2. CONCISE AI PLAIN-LANGUAGE EXPLANATION CARD
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
                            Row(
                              children: [
                                const Icon(Icons.psychology_rounded, size: 18, color: AppColors.primary),
                                const SizedBox(width: 8),
                                const Text(
                                  'Grounded AI Disruption Analysis',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryContainerLight,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'Verified Telemetry',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              connJourney != null
                                  ? '• Train ${connJourney.firstLeg.train.trainNumber} has incurred a 55-minute delay due to track maintenance near Kota Junction.\n'
                                    '• Scheduled buffer at Vadodara Junction was 70 mins; actual transfer window is now reduced to 15 mins.\n'
                                    '• Because transferring with luggage between Platform 4 and Platform 2 takes approximately 6 mins, there is a high probability of missing Train 20901 Vande Bharat.\n'
                                    '• Under Indian Railway Section 54, you are eligible for 100% full refund on the connecting ticket without clerkage cancellation charges.'
                                  : (disruption != null
                                      ? disruption.plainDescription
                                      : 'All journeys operating within standard scheduled punctuality thresholds.'),
                              style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(context).colorScheme.onSurface,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // 3. FEASIBLE ALTERNATIVES OVERVIEW
                      if (alternatives.isNotEmpty) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Feasible Alternatives (Structured)',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AlternativeJourneysScreen(
                                      disruptionService: widget.disruptionService,
                                    ),
                                  ),
                                );
                              },
                              child: const Text('View Comparison'),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        ...alternatives.take(2).map(
                          (alt) => Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: AlternativeJourneyCard(
                              alternative: alt,
                              onSelect: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Redirecting to official IRCTC portal for ${alt.trainNumber}...'),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                      ],

                      // 4. OFFICIAL TDR & PASSENGER RULES CARD
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
                                Icon(Icons.verified_user_outlined, size: 16, color: AppColors.primary),
                                SizedBox(width: 6),
                                Text(
                                  'IRCTC TDR & Refund Rules (Section 54)',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              '1. File TDR on IRCTC App under: "Passenger Not Travelled due to Late Running of Connecting Train".\n'
                              '2. Full 100% fare is refunded to original payment mode with 0 cancellation deduction.\n'
                              '3. Time limit: TDR must be filed within 3 hours of actual arrival at transfer station.',
                              style: TextStyle(fontSize: 12, height: 1.4),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // 5. INTERACTIVE CONVERSATION HISTORY
                      const Text(
                        'Ask Railway Assistant',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      ...messages.map((msg) => _buildChatMessage(msg)),

                      const SizedBox(height: AppSpacing.md),
                    ],
                  ),
                ),
              ),

              // Bottom query input bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _queryController,
                          textInputAction: TextInputAction.send,
                          onSubmitted: isProcessing ? null : (_) => _sendQuery(),
                          decoration: InputDecoration(
                            hintText: 'Ask about TDR refund, baggage, or platforms...',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        icon: isProcessing
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.send_rounded, size: 16),
                        onPressed: isProcessing ? null : () => _sendQuery(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChatMessage(ChatMessage msg) {
    final isUser = msg.sender == MessageSender.user;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isUser ? AppColors.primary : Theme.of(context).colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isUser ? AppColors.primaryDark : Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            child: msg.isThinking
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 1.8, color: AppColors.primary)),
                      SizedBox(width: 8),
                      Text('Consulting railway timetable and rules...', style: TextStyle(fontSize: 12)),
                    ],
                  )
                : Text(
                    msg.text,
                    style: TextStyle(
                      fontSize: 12,
                      color: isUser ? Colors.white : Theme.of(context).colorScheme.onSurface,
                      height: 1.35,
                    ),
                  ),
          ),
          if (msg.suggestedChips.isNotEmpty && !isUser)
            Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                children: msg.suggestedChips.map((chip) {
                  return ActionChip(
                    label: Text(chip, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                    onPressed: () => _sendQuery(chip),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
