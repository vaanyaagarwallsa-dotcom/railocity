import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/railway_models.dart';
import '../services/alerts_service.dart';
import '../services/disruption_service.dart';
import '../services/railway_service.dart';
import '../theme/app_theme.dart';
import '../widgets/verified_source_badge.dart';
import 'disruption_details_screen.dart';

class AlertsCenterScreen extends StatefulWidget {
  final AlertsService alertsService;
  final DisruptionService disruptionService;
  final RailwayService railwayService;
  final VoidCallback? onNavigateToAIRecovery;

  const AlertsCenterScreen({
    super.key,
    required this.alertsService,
    required this.disruptionService,
    required this.railwayService,
    this.onNavigateToAIRecovery,
  });

  @override
  State<AlertsCenterScreen> createState() => _AlertsCenterScreenState();
}

class _AlertsCenterScreenState extends State<AlertsCenterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.alertsService,
      builder: (context, _) {
        final criticalAlerts = widget.alertsService.criticalAlerts;
        final infoAlerts = widget.alertsService.informationalAlerts;
        final unreadCount = widget.alertsService.unreadCount;

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
                  child: const Icon(Icons.notifications_active_rounded, color: AppColors.primary, size: 16),
                ),
                const SizedBox(width: 8),
                const Text('Alerts & Advisories'),
              ],
            ),
            actions: [
              if (unreadCount > 0)
                TextButton(
                  onPressed: () => widget.alertsService.markAllAsRead(),
                  child: const Text('Mark all read', style: TextStyle(fontSize: 12)),
                ),
              IconButton(
                tooltip: 'Notification Preferences',
                icon: const Icon(Icons.tune_rounded, size: 20),
                onPressed: _showNotificationPreferencesSheet,
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primary,
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: AppColors.primary,
              unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Disruptions'),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.criticalRedContainerLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${criticalAlerts.length}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.criticalRed,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Updates'),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainerLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${infoAlerts.length}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildAlertsList(criticalAlerts, isCriticalTab: true),
              _buildAlertsList(infoAlerts, isCriticalTab: false),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAlertsList(List<AlertItem> alerts, {required bool isCriticalTab}) {
    if (alerts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isCriticalTab ? Icons.check_circle_outline_rounded : Icons.notifications_none_rounded,
                size: 40,
                color: AppColors.textMutedLight,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                isCriticalTab ? 'No Critical Disruptions' : 'No Recent Updates',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                isCriticalTab
                    ? 'All active trains and connections are running within normal buffers.'
                    : 'Station announcements and coach updates will appear here.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final timeFormat = DateFormat('hh:mm a');

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: alerts.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final alert = alerts[index];
        final isCritical = alert.severity == DisruptionSeverity.critical;
        final isWarning = alert.severity == DisruptionSeverity.warning;

        return InkWell(
          onTap: () {
            widget.alertsService.markAsRead(alert.id);
            if (widget.disruptionService.activeDisruption != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DisruptionDetailsScreen(
                    disruption: widget.disruptionService.activeDisruption!,
                    disruptionService: widget.disruptionService,
                    railwayService: widget.railwayService,
                    onNavigateToAIRecovery: widget.onNavigateToAIRecovery,
                  ),
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: alert.isRead
                  ? Theme.of(context).colorScheme.surface
                  : Theme.of(context).colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: alert.isRead
                    ? Theme.of(context).colorScheme.outlineVariant
                    : (isCritical ? AppColors.criticalRed.withOpacity(0.5) : AppColors.primary.withOpacity(0.5)),
                width: alert.isRead ? 1 : 1.2,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isCritical
                        ? AppColors.criticalRedContainerLight
                        : (isWarning ? AppColors.warningContainerLight : AppColors.primaryContainerLight),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isCritical
                        ? Icons.warning_rounded
                        : (isWarning ? Icons.warning_amber_rounded : Icons.info_outline_rounded),
                    size: 16,
                    color: isCritical
                        ? AppColors.criticalRed
                        : (isWarning ? AppColors.warning : AppColors.primary),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              alert.title,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: alert.isRead ? FontWeight.w600 : FontWeight.w800,
                              ),
                            ),
                          ),
                          Text(
                            timeFormat.format(alert.timestamp),
                            style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        alert.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            'Train ${alert.trainNumber} • ${alert.stationCode}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '• ${alert.verifiedSource}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showNotificationPreferencesSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Notification Preferences',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SwitchListTile(
                    title: const Text('Push Notifications for Delays'),
                    subtitle: const Text('Alert when train delay exceeds threshold'),
                    value: widget.alertsService.pushNotificationsEnabled,
                    activeColor: AppColors.primary,
                    onChanged: (val) {
                      widget.alertsService.togglePushNotifications(val);
                      setSheetState(() {});
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Platform Shift Alerts'),
                    subtitle: const Text('Instant notification when arriving platform changes'),
                    value: widget.alertsService.platformChangeAlerts,
                    activeColor: AppColors.primary,
                    onChanged: (val) {
                      widget.alertsService.togglePlatformChangeAlerts(val);
                      setSheetState(() {});
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Audio Chime & Vibration'),
                    subtitle: const Text('Sound chime for critical missed connection risks'),
                    value: widget.alertsService.audioChimeEnabled,
                    activeColor: AppColors.primary,
                    onChanged: (val) {
                      widget.alertsService.toggleAudioChime(val);
                      setSheetState(() {});
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
