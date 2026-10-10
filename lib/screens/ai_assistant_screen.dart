import 'package:flutter/material.dart';
import '../models/railway_models.dart';
import '../services/ai_agent_service.dart';
import '../theme/app_theme.dart';
import '../widgets/ticket_pass_card.dart';

class AIAssistantScreen extends StatefulWidget {
  final AIAgentService aiAgentService;
  final VoidCallback onNavigateToLive;
  final VoidCallback onNavigateToTickets;

  const AIAssistantScreen({
    super.key,
    required this.aiAgentService,
    required this.onNavigateToLive,
    required this.onNavigateToTickets,
  });

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage([String? text]) {
    final query = text ?? _inputController.text;
    if (query.trim().isEmpty) return;
    _inputController.clear();
    widget.aiAgentService.handleUserInput(query);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.aiAgentService,
      builder: (context, _) {
        final messages = widget.aiAgentService.messages;
        final isProcessing = widget.aiAgentService.isProcessing;

        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.smart_toy_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Railo AI Companion',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Online • Ready to assist',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'Railo Capabilities',
                icon: const Icon(
                  Icons.help_outline_rounded,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                onPressed: () => _showAgentCapabilitiesModal(context),
              ),
            ],
          ),
          body: Column(
            children: [
              // Chat conversation list
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    return _buildMessageItem(msg);
                  },
                ),
              ),

              // Bottom suggestion chips row
              _buildSuggestedChipsBar(),

              // Input bar
              _buildInputArea(isProcessing),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageItem(ChatMessage msg) {
    final isUser = msg.sender == MessageSender.user;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser) ...[
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    size: 13,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isUser
                        ? AppColors.primary
                        : AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 16),
                    ),
                    border: Border.all(
                      color: isUser
                          ? AppColors.primaryLight.withOpacity(0.5)
                          : AppColors.borderHighlight,
                      width: 1,
                    ),
                  ),
                  child: msg.isThinking
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            SizedBox(
                              width: 13,
                              height: 13,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.secondary,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Thinking & finding best options...',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          msg.text,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.4,
                            color: isUser
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                ),
              ),
              if (isUser) const SizedBox(width: 8),
            ],
          ),

          // Autonomous Agent Reasoning Steps Accordion
          if (msg.reasoningSteps != null && msg.reasoningSteps!.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 6, left: 28),
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(
                        Icons.check_circle_rounded,
                        size: 13,
                        color: AppColors.secondary,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Agent Steps:',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ...msg.reasoningSteps!.map(
                    (step) => Padding(
                      padding: const EdgeInsets.only(bottom: 2.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '• ',
                            style: TextStyle(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              step,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Embedded Digital Ticket Card for Instant Confirmation
          if (msg.bookingCard != null)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 20),
              child: TicketPassCard(
                booking: msg.bookingCard!,
                onTrackTrain: widget.onNavigateToLive,
              ),
            ),

          // Suggested Action Chips inside message
          if (msg.suggestedChips.isNotEmpty && !isUser)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 20),
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                children: msg.suggestedChips.map((chip) {
                  return ActionChip(
                    backgroundColor: AppColors.surfaceContainerHigh,
                    side: const BorderSide(color: AppColors.borderHighlight),
                    label: Text(
                      chip,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.secondaryLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: () => _sendMessage(chip),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSuggestedChipsBar() {
    final chips = [
      '⚡ Book ticket to Mumbai',
      '⏱️ Train arrival countdown',
      '🚉 Platform for Coach B3',
      '⚠️ Route delays check',
    ];

    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        separatorBuilder: (context, index) => const SizedBox(width: 6),
        itemBuilder: (context, i) {
          return InkWell(
            onTap: () => _sendMessage(chips[i]),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Center(
                child: Text(
                  chips[i],
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputArea(bool isProcessing) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs + 2,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _inputController,
                textInputAction: TextInputAction.send,
                onSubmitted: isProcessing ? null : (_) => _sendMessage(),
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Ask Railo AI or say "Book ticket to Mumbai"...',
                  hintStyle: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceContainerLow,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Container(
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                tooltip: 'Send prompt',
                icon: isProcessing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.send_rounded,
                        color: Colors.white, size: 16),
                onPressed: isProcessing ? null : () => _sendMessage(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAgentCapabilitiesModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Railo AI Capabilities',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: AppSpacing.md),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.bolt_rounded, color: AppColors.secondary),
                title: Text(
                  'Automated 1-Click Ticket Booking',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'Parses natural language, checks quota, allocates seats, and confirms PNRs.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.timer_outlined, color: AppColors.info),
                title: Text(
                  'Live ETA & Boarding Countdown',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'Calculates down to the second when your train pulls into your platform.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading:
                    Icon(Icons.accessible_forward_rounded, color: AppColors.success),
                title: Text(
                  'Platform & Coach Positioning',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'Guides you to exact platform positions relative to station bridges, lifts, and escalators.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
