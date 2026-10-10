import 'package:flutter/material.dart';
import '../models/railway_models.dart';
import '../services/railway_service.dart';
import '../services/booking_service.dart';
import '../services/disruption_service.dart';
import '../services/alerts_service.dart';
import '../theme/app_theme.dart';
import '../widgets/live_countdown_card.dart';
import '../widgets/disruption_banner.dart';
import '../widgets/coach_locator_widget.dart';
import '../widgets/route_stepper_widget.dart';
import '../widgets/data_freshness_header.dart';
import 'disruption_details_screen.dart';
import 'ai_recovery_screen.dart';
import 'train_search_screen.dart';

class HomeOverviewScreen extends StatelessWidget {
  final RailwayService railwayService;
  final BookingService bookingService;
  final DisruptionService disruptionService;
  final AlertsService alertsService;
  final VoidCallback onNavigateToSearch;
  final VoidCallback onNavigateToAIRecovery;
  final VoidCallback onNavigateToAlerts;

  const HomeOverviewScreen({
    super.key,
    required this.railwayService,
    required this.bookingService,
    required this.disruptionService,
    required this.alertsService,
    required this.onNavigateToSearch,
    required this.onNavigateToAIRecovery,
    required this.onNavigateToAlerts,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        railwayService,
        bookingService,
        disruptionService,
        alertsService,
      ]),
      builder: (context, _) {
        final train = railwayService.activeTrackedTrain;
        final boardingStation = railwayService.userBoardingStation;
        final nextBooking = bookingService.nextUpcomingBooking;
        final disruption = disruptionService.activeDisruption;
        final stop = train?.getStopForStation(boardingStation.code);
        final unreadAlerts = alertsService.unreadCount;

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
                  child: const Icon(Icons.train_rounded, color: AppColors.primary, size: 18),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Railocity',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      'Disruption Assistance & Live Telemetry',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textMutedLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'Alerts Centre',
                icon: Badge(
                  isLabelVisible: unreadAlerts > 0,
                  label: Text('$unreadAlerts'),
                  backgroundColor: AppColors.criticalRed,
                  child: const Icon(Icons.notifications_none_rounded, size: 22),
                ),
                onPressed: onNavigateToAlerts,
              ),
              IconButton(
                tooltip: 'Search Trains & PNR',
                icon: const Icon(Icons.search_rounded, size: 22),
                onPressed: onNavigateToSearch,
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
                      // 1. ACTIVE DISRUPTION BANNER (Highlighted prominently only when active)
                      if (disruption != null)
                        DisruptionBanner(
                          disruption: disruption,
                          onTapDetails: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DisruptionDetailsScreen(
                                  disruption: disruption,
                                  disruptionService: disruptionService,
                                  railwayService: railwayService,
                                  onNavigateToAIRecovery: onNavigateToAIRecovery,
                                ),
                              ),
                            );
                          },
                          onAnalyzeConnection: onNavigateToAIRecovery,
                        ),

                      // 2. PRIMARY ACTIVE JOURNEY & COUNTDOWN CARD
                      LiveCountdownCard(
                        railwayService: railwayService,
                        onSelectStation: () => _showStationPickerSheet(context),
                        onSelectTrain: () => _showTrainPickerSheet(context),
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // 3. QUICK ACTION BAR (Single clear primary action without competing cards)
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: onNavigateToSearch,
                              icon: const Icon(Icons.add_rounded, size: 16),
                              label: const Text('Add / Search Journey'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (disruption != null && disruption.isConnectingJourneyAffected)
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: onNavigateToAIRecovery,
                                icon: const Icon(Icons.auto_awesome_rounded, size: 16),
                                label: const Text('AI Recovery'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // 4. COACH PLATFORM POSITION
                      if (train != null)
                        CoachLocatorWidget(
                          coaches: train.coaches,
                          highlightedCoach: nextBooking?.coach ?? 'B3',
                          platform: stop?.platform ?? 2,
                        ),

                      const SizedBox(height: AppSpacing.md),

                      // 5. ROUTE HALTS TIMELINE
                      if (train != null)
                        RouteStepperWidget(
                          train: train,
                          boardingStation: boardingStation,
                          onStationTap: (station) {
                            railwayService.setUserBoardingStation(station);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Boarding station set to ${station.name} (${station.code})'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        ),

                      const SizedBox(height: AppSpacing.xl),
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

  void _showStationPickerSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: railwayService.allStations.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final st = railwayService.allStations[index];
            final isCurrent = st.code == railwayService.userBoardingStation.code;
            return ListTile(
              title: Text('${st.name} (${st.code})', style: TextStyle(fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600)),
              subtitle: Text('${st.city} • ${st.platforms} Platforms'),
              trailing: isCurrent ? const Icon(Icons.check_circle_rounded, color: AppColors.primary) : null,
              onTap: () {
                railwayService.setUserBoardingStation(st);
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  void _showTrainPickerSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: railwayService.trains.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final t = railwayService.trains[index];
            final isSelected = t.trainNumber == railwayService.activeTrackedTrain?.trainNumber;
            return ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.outlineVariant),
              ),
              title: Text('${t.trainNumber} • ${t.trainName}', style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text('${t.source.code} ➔ ${t.destination.code} • ${t.trainType}'),
              trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: AppColors.primary) : null,
              onTap: () {
                railwayService.setActiveTrackedTrain(t);
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }
}
