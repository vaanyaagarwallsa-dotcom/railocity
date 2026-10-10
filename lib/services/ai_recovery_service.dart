import 'package:flutter/foundation.dart';
import '../models/railway_models.dart';
import 'railway_service.dart';
import 'disruption_service.dart';
import 'booking_service.dart';

class AIRecoveryService extends ChangeNotifier {
  final RailwayService railwayService;
  final DisruptionService disruptionService;
  final BookingService bookingService;

  final List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => List.unmodifiable(_messages);

  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  AIRecoveryService({
    required this.railwayService,
    required this.disruptionService,
    required this.bookingService,
  }) {
    _initWelcomeMessages();
  }

  void _initWelcomeMessages() {
    final disruption = disruptionService.activeDisruption;
    final connJourney = disruptionService.activeConnectingJourney;

    String initialGreeting;
    List<String> chips;

    if (connJourney != null && connJourney.riskLevel == ConnectionRiskLevel.criticalMiss) {
      initialGreeting =
          "⚠️ **High Connection Disruption Alert Detected**\n\n"
          "Your first train **${connJourney.firstLeg.train.trainNumber} ${connJourney.firstLeg.train.trainName}** is delayed by **${connJourney.firstLeg.delayMinutes} minutes**.\n\n"
          "This reduces your transfer buffer at **${connJourney.transferStation.name} (${connJourney.transferStation.code})** to **${connJourney.remainingTransferBufferMinutes} minutes**, putting your connection to **${connJourney.secondLeg.train.trainNumber}** at **Critical Miss Risk**.\n\n"
          "I have calculated 3 feasible alternatives and prepared your official IRCTC TDR refund guidance.";
      chips = [
        '🔄 Compare 3 Feasible Alternatives',
        '📜 How do I get a 100% TDR refund?',
        '📍 Show Vadodara Junction Platform Map',
        '💬 Ask a specific question',
      ];
    } else if (disruption != null) {
      initialGreeting =
          "ℹ️ **Disruption Notice Active**\n\n"
          "**${disruption.title}**\n\n"
          "${disruption.plainDescription}\n\n"
          "Data verified via **${disruption.sourceLabel}**.";
      chips = [
        '⏱️ Check updated arrival time',
        '🚶 Platform navigation assistance',
        '💡 What are my passenger rights?',
      ];
    } else {
      initialGreeting =
          "👋 **Railocity Railway Assistant**\n\n"
          "All your active journeys are running on time. I can assist you with live tracking, platform transfers, catering, and official railway rules.";
      chips = [
        '⏱️ When is my train arriving?',
        '🚉 Which platform is my coach on?',
        '🍽️ Check pantry catering services',
      ];
    }

    _messages.add(
      ChatMessage(
        id: 'msg_welcome_ai',
        sender: MessageSender.ai,
        text: initialGreeting,
        timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
        suggestedChips: chips,
      ),
    );
  }

  Future<void> handleUserInput(String text) async {
    final query = text.trim();
    if (query.isEmpty) return;

    _messages.add(
      ChatMessage(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        sender: MessageSender.user,
        text: query,
        timestamp: DateTime.now(),
      ),
    );
    notifyListeners();

    _isProcessing = true;
    notifyListeners();

    // Add thinking state
    final thinkingId = 'thinking_${DateTime.now().millisecondsSinceEpoch}';
    _messages.add(
      ChatMessage(
        id: thinkingId,
        sender: MessageSender.ai,
        text: 'Analyzing structured timetable data and railway guidelines...',
        timestamp: DateTime.now(),
        isThinking: true,
      ),
    );
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    _messages.removeWhere((m) => m.id == thinkingId);

    _generateGroundedResponse(query);

    _isProcessing = false;
    notifyListeners();
  }

  void _generateGroundedResponse(String rawQuery) {
    final q = rawQuery.toLowerCase();
    final connJourney = disruptionService.activeConnectingJourney;
    final disruption = disruptionService.activeDisruption;

    // 1. TDR / Refund / Section 54 Rules
    if (q.contains('tdr') || q.contains('refund') || q.contains('rule 54') || q.contains('compensation') || q.contains('cancel')) {
      _messages.add(
        ChatMessage(
          id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
          sender: MessageSender.ai,
          text:
              "📜 **Official IRCTC Refund & TDR Guidance (Section 54)**\n\n"
              "1. **Missed Connecting Train Guarantee:**\n"
              "Under Indian Railways Commercial Circular Rule 54, if you miss a connecting train because the first train was delayed, you are entitled to a **100% full refund on the connecting ticket without clerkage deduction**.\n\n"
              "2. **How to file TDR online:**\n"
              "• Open IRCTC App/Web > My Bookings > Select Connecting Ticket (${connJourney?.secondLeg.pnr ?? 'PNR'})\n"
              "• Select **File TDR** > Reason: *\"Passenger Not Travelled due to Late Running of Connecting Train\"*\n"
              "• Note down your original train number (${connJourney?.firstLeg.train.trainNumber ?? '12952'}).\n\n"
              "3. **Deadline:** TDR must be filed within **3 hours of actual arrival of the first train** at the interchange station.",
          timestamp: DateTime.now(),
          suggestedChips: [
            '🔄 Compare 3 Feasible Alternatives',
            '🎫 View my PNR details',
            '⏱️ Check delay recovery status',
          ],
        ),
      );
      return;
    }

    // 2. Alternative Journeys Query
    if (q.contains('alternative') || q.contains('options') || q.contains('next train') || q.contains('bus') || q.contains('other train')) {
      final alts = disruptionService.alternativeJourneys;
      if (alts.isNotEmpty) {
        final bufferText = alts.map((a) {
          return "• **${a.trainNumber} - ${a.trainName}** (${a.transportType})\n"
              "  Departure: **${a.departureTime}** • Arrival: **${a.arrivalTime}** (${a.duration})\n"
              "  Status: `${a.seatStatus}` • Fare: ₹${a.fare.toInt()}\n"
              "  *Why:* ${a.recommendationReason}\n"
              "  *Limitation:* ${a.limitationNote}\n";
        }).join('\n');

        _messages.add(
          ChatMessage(
            id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
            sender: MessageSender.ai,
            text:
              "🚄 **Feasible Alternative Journeys from ${disruptionService.activeConnectingJourney?.transferStation.name ?? 'Transfer Station'}:**\n\n"
              "$bufferText\n"
              "💡 *Note: Alternative options are based on verified timetables and simulated live availability. Tap below to inspect full trade-offs.*",
            timestamp: DateTime.now(),
            suggestedChips: [
              '📜 How do I get a 100% TDR refund?',
              '📍 Walking guidance between platforms',
            ],
          ),
        );
        return;
      }
    }

    // 3. Platform / Station Walking Guidance
    if (q.contains('platform') || q.contains('walk') || q.contains('fob') || q.contains('map') || q.contains('transfer') || q.contains('luggage')) {
      final station = disruptionService.activeConnectingJourney?.transferStation ?? RailwayService.mtj;
      _messages.add(
        ChatMessage(
          id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
          sender: MessageSender.ai,
          text:
              "🚶 **Platform Transfer & Accessibility Guide at ${station.name} (${station.code}):**\n\n"
              "• **Arriving Platform:** Platform 4 (Middle express bay)\n"
              "• **Connecting Train Platform:** Platform 2\n"
              "• **Fastest Walking Path:** Climb **Foot Overbridge (FOB) #2 ramp** directly opposite Coach B3/B4. Walk 40 meters south and take Ramp Down to Platform 2.\n"
              "• **Heavy Luggage / Accessibility:** Escalator B and Wheelchair Lift are operational at FOB #2 north pillar.\n"
              "• **Transfer Time Estimate:** 4 to 6 minutes brisk walk with luggage.",
          timestamp: DateTime.now(),
          suggestedChips: [
            '⏱️ What is my remaining transfer buffer?',
            '📜 Read Railway TDR Refund rules',
          ],
        ),
      );
      return;
    }

    // 4. Delay & Speed Status
    if (q.contains('delay') || q.contains('speed') || q.contains('status') || q.contains('late') || q.contains('eta')) {
      final train = disruptionService.activeConnectingJourney?.firstLeg.train ?? railwayService.activeTrackedTrain ?? railwayService.trains.first;
      _messages.add(
        ChatMessage(
          id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
          sender: MessageSender.ai,
          text:
              "📊 **Live Punctuality & Speed Telemetry:**\n\n"
              "• **Train:** ${train.trainNumber} ${train.trainName}\n"
              "• **Current Delay:** **${train.delayMinutes} minutes**\n"
              "• **Current Speed:** **${train.currentSpeedKmph} km/h**\n"
              "• **Position:** ${train.currentLocationDescription}\n"
              "• **Data Verification:** ${disruption?.sourceLabel ?? 'NTES Live Data Feed'}\n\n"
              "💡 ${connJourney != null ? 'Transfer window at ${connJourney.transferStation.code} is currently ${connJourney.remainingTransferBufferMinutes} mins (${connJourney.riskLabel}).' : 'No connection risks detected.'}",
          timestamp: DateTime.now(),
          suggestedChips: [
            '🔄 Compare alternative options',
            '📜 View TDR refund rules',
          ],
        ),
      );
      return;
    }

    // Default grounded assistance
    _messages.add(
      ChatMessage(
        id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
        sender: MessageSender.ai,
        text:
            "I'm monitoring your active journey details and verified railway telemetry.\n\n"
            "Here are the recommended actions based on your current journey status:",
        timestamp: DateTime.now(),
        suggestedChips: [
          '🔄 Compare 3 Feasible Alternatives',
          '📜 Explain 100% TDR refund rules',
          '🚶 Platform walking & luggage guidance',
          '⏱️ Check live speed & delay recovery',
        ],
      ),
    );
  }
}
