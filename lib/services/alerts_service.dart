import 'package:flutter/foundation.dart';
import '../models/railway_models.dart';

class AlertsService extends ChangeNotifier {
  final List<AlertItem> _alerts = [];
  List<AlertItem> get alerts => List.unmodifiable(_alerts);

  bool _pushNotificationsEnabled = true;
  bool get pushNotificationsEnabled => _pushNotificationsEnabled;

  int _delayThresholdMinutes = 15;
  int get delayThresholdMinutes => _delayThresholdMinutes;

  bool _audioChimeEnabled = true;
  bool get audioChimeEnabled => _audioChimeEnabled;

  bool _platformChangeAlerts = true;
  bool get platformChangeAlerts => _platformChangeAlerts;

  AlertsService() {
    _initSampleAlerts();
  }

  void _initSampleAlerts() {
    final now = DateTime.now();
    _alerts.addAll([
      AlertItem(
        id: 'alt_001',
        title: 'Missed Connection Risk: 55m Delay on 12952',
        description: 'Remaining transfer buffer at Vadodara Jn reduced to 15m. Connecting train 20901 Vande Bharat is departing on time from Platform 2.',
        severity: DisruptionSeverity.critical,
        timestamp: now.subtract(const Duration(minutes: 5)),
        trainNumber: '12952',
        stationCode: 'BRC',
        verifiedSource: 'NTES Live System',
        isRead: false,
        relatedJourneyId: 'cj_ndls_adi_01',
      ),
      AlertItem(
        id: 'alt_002',
        title: 'Platform Shift: Platform 2 ➔ Platform 4 at Mathura Jn',
        description: 'Train 12952 arriving on Platform 4 due to line maintenance. Use FOB #2 ramp for step-free access.',
        severity: DisruptionSeverity.warning,
        timestamp: now.subtract(const Duration(minutes: 22)),
        trainNumber: '12952',
        stationCode: 'MTJ',
        verifiedSource: 'Station Master Broadcast',
        isRead: false,
      ),
      AlertItem(
        id: 'alt_003',
        title: 'Approaching Station Alert: Mathura Jn in 14 mins',
        description: 'Train speed 112 km/h. Please prepare luggage and check coach indicator board.',
        severity: DisruptionSeverity.info,
        timestamp: now.subtract(const Duration(minutes: 35)),
        trainNumber: '12952',
        stationCode: 'MTJ',
        verifiedSource: 'GPS Telemetry Feed',
        isRead: true,
      ),
      AlertItem(
        id: 'alt_004',
        title: 'Pantry Catering Service Resumed',
        description: 'Dinner orders dispatched for Coach B1-B6. Water refilling completed at Agra Cantt.',
        severity: DisruptionSeverity.info,
        timestamp: now.subtract(const Duration(hours: 1, minutes: 10)),
        trainNumber: '12952',
        stationCode: 'AGC',
        verifiedSource: 'IRCTC Onboard Manager',
        isRead: true,
      ),
    ]);
  }

  int get unreadCount => _alerts.where((a) => !a.isRead).length;

  List<AlertItem> get criticalAlerts =>
      _alerts.where((a) => a.severity == DisruptionSeverity.critical || a.severity == DisruptionSeverity.warning).toList();

  List<AlertItem> get informationalAlerts =>
      _alerts.where((a) => a.severity == DisruptionSeverity.info).toList();

  void markAsRead(String id) {
    final index = _alerts.indexWhere((a) => a.id == id);
    if (index != -1) {
      _alerts[index] = _alerts[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (int i = 0; i < _alerts.length; i++) {
      _alerts[i] = _alerts[i].copyWith(isRead: true);
    }
    notifyListeners();
  }

  void togglePushNotifications(bool val) {
    _pushNotificationsEnabled = val;
    notifyListeners();
  }

  void setDelayThreshold(int minutes) {
    _delayThresholdMinutes = minutes;
    notifyListeners();
  }

  void toggleAudioChime(bool val) {
    _audioChimeEnabled = val;
    notifyListeners();
  }

  void togglePlatformChangeAlerts(bool val) {
    _platformChangeAlerts = val;
    notifyListeners();
  }
}
