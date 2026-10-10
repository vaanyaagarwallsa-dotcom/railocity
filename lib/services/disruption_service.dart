import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/railway_models.dart';
import 'railway_service.dart';

enum DemoScenario {
  missedConnectionRisk, // 55 min delay eats 70 min transfer buffer -> 15m remaining
  urgentPlatformShift,  // Platform 2 -> Platform 4 at Mathura Jn
  fogDelayRecovery,     // 40 min delay due to northern fog, recovering speed
  trainCancelledTDR,    // Train cancelled, TDR auto-guidance & full refund
  onTimeSmoothTrip,     // On-time journey, verified
}

class DisruptionService extends ChangeNotifier {
  final RailwayService railwayService;

  DemoScenario _currentScenario = DemoScenario.missedConnectionRisk;
  DemoScenario get currentScenario => _currentScenario;

  Disruption? _activeDisruption;
  Disruption? get activeDisruption => _activeDisruption;

  ConnectingJourney? _activeConnectingJourney;
  ConnectingJourney? get activeConnectingJourney => _activeConnectingJourney;

  List<AlternativeJourney> _alternativeJourneys = [];
  List<AlternativeJourney> get alternativeJourneys => List.unmodifiable(_alternativeJourneys);

  DateTime _lastDataSyncTime = DateTime.now().subtract(const Duration(minutes: 2));
  DateTime get lastDataSyncTime => _lastDataSyncTime;

  bool _isRefreshing = false;
  bool get isRefreshing => _isRefreshing;

  Timer? _syncTicker;

  DisruptionService({required this.railwayService}) {
    _loadScenario(_currentScenario);
    _startPeriodicSync();
  }

  void _startPeriodicSync() {
    _syncTicker = Timer.periodic(const Duration(seconds: 30), (_) {
      _lastDataSyncTime = DateTime.now();
      notifyListeners();
    });
  }

  Future<void> refreshData() async {
    _isRefreshing = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 600));
    _lastDataSyncTime = DateTime.now();
    _isRefreshing = false;
    notifyListeners();
  }

  String get dataFreshnessLabel {
    final diff = DateTime.now().difference(_lastDataSyncTime);
    if (diff.inSeconds < 45) return 'Live feed updated just now';
    if (diff.inMinutes < 60) return 'Updated ${diff.inMinutes}m ago • NTES Live';
    return 'Updated at ${_lastDataSyncTime.hour}:${_lastDataSyncTime.minute.toString().padLeft(2, '0')}';
  }

  void switchScenario(DemoScenario scenario) {
    _currentScenario = scenario;
    _loadScenario(scenario);
    notifyListeners();
  }

  void _loadScenario(DemoScenario scenario) {
    final now = DateTime.now();
    final train12952 = railwayService.getTrainByNumber('12952') ?? railwayService.trains.first;
    final train22436 = railwayService.getTrainByNumber('22436') ?? railwayService.trains[1];

    switch (scenario) {
      case DemoScenario.missedConnectionRisk:
        // Leg 1: 12952 NDLS -> BRC (Arrives 03:40 + 55m = 04:35)
        // Leg 2: 20901 Vande Bharat BRC -> ADI (Departs 04:50)
        // Buffer: 70 min scheduled - 55 min delay = 15 min remaining buffer!
        train12952.delayMinutes = 55;
        train12952.currentLocationDescription = 'Delayed near Kota Jn due to signal maintenance';

        _activeDisruption = Disruption(
          id: 'disrupt_conn_01',
          title: '55 min Delay - Connection at Vadodara (BRC) in Critical Danger',
          plainDescription:
              'Train 12952 is currently running 55 minutes behind schedule due to automated signaling interlocking maintenance near Kota Junction. Your transfer buffer at Vadodara Junction is reduced from 70 mins to only 15 mins.',
          severity: DisruptionSeverity.critical,
          source: VerificationSource.ntesLive,
          timestamp: now.subtract(const Duration(minutes: 4)),
          delayMinutes: 55,
          affectedStationCode: 'BRC',
          isConnectingJourneyAffected: true,
          officialAdvice:
              'IRCTC Connection Protection: Under Railway Rule 54, if your connecting train is missed due to late running of the first train, you are entitled to a 100% full refund on the connecting segment without cancellation charge via TDR.',
        );

        final leg1 = JourneyLeg(
          train: train12952,
          fromStation: RailwayService.ndls,
          toStation: RailwayService.brc,
          scheduledDeparture: '16:55',
          scheduledArrival: '03:40',
          actualDeparture: '16:55',
          actualArrival: '04:35 (+55m)',
          delayMinutes: 55,
          platform: 4,
          coach: 'B3',
          seat: '42',
          pnr: '2849104821',
        );

        final leg2Train = Train(
          trainNumber: '20901',
          trainName: 'Vande Bharat Express',
          trainType: 'Semi High-Speed',
          source: RailwayService.brc,
          destination: const Station(code: 'ADI', name: 'Ahmedabad Junction', city: 'Ahmedabad', platforms: 12),
          stops: [],
          classes: [],
          coaches: ['C1', 'C2', 'E1'],
        );

        final leg2 = JourneyLeg(
          train: leg2Train,
          fromStation: RailwayService.brc,
          toStation: const Station(code: 'ADI', name: 'Ahmedabad Junction', city: 'Ahmedabad', platforms: 12),
          scheduledDeparture: '04:50',
          scheduledArrival: '06:05',
          actualDeparture: '04:50 (On Time)',
          actualArrival: '06:05',
          delayMinutes: 0,
          platform: 2,
          coach: 'C1',
          seat: '14',
          pnr: '7491028391',
        );

        _activeConnectingJourney = ConnectingJourney(
          journeyId: 'cj_ndls_adi_01',
          passengerName: 'Adarsh P. Abhilash',
          firstLeg: leg1,
          secondLeg: leg2,
          transferStation: RailwayService.brc,
          scheduledTransferBufferMinutes: 70,
          activeDisruption: _activeDisruption,
        );

        _alternativeJourneys = [
          AlternativeJourney(
            id: 'alt_01',
            trainNumber: '22953',
            trainName: 'Gujarat Superfast Express',
            transportType: 'Superfast Train',
            fromStation: RailwayService.brc,
            toStation: const Station(code: 'ADI', name: 'Ahmedabad Junction', city: 'Ahmedabad', platforms: 12),
            departureTime: '05:45',
            arrivalTime: '07:15',
            duration: '1h 30m',
            fare: 285.0,
            seatStatus: 'AVAILABLE-48 (2S/CC)',
            recommendationReason: 'Departs 55 mins after your delayed arrival. Comfortable transfer time with no luggage sprint.',
            limitationNote: 'Chair car class only. Unreserved counters available on Platform 1.',
            isDirect: true,
            riskScore: 1,
            isSimulatedSample: true,
          ),
          AlternativeJourney(
            id: 'alt_02',
            trainNumber: '12009',
            trainName: 'Mumbai Central - Ahmedabad Shatabdi',
            transportType: 'Premium Shatabdi',
            fromStation: RailwayService.brc,
            toStation: const Station(code: 'ADI', name: 'Ahmedabad Junction', city: 'Ahmedabad', platforms: 12),
            departureTime: '06:30',
            arrivalTime: '07:45',
            duration: '1h 15m',
            fare: 540.0,
            seatStatus: 'AVAILABLE-16 (CC)',
            recommendationReason: 'Includes complimentary morning breakfast and dedicated priority platform berth.',
            limitationNote: 'Higher dynamic fare. Requires fresh booking via IRCTC App.',
            isDirect: true,
            riskScore: 1,
            isSimulatedSample: true,
          ),
          AlternativeJourney(
            id: 'alt_03',
            trainNumber: 'GSRTC-EV',
            trainName: 'GSRTC Electric Intercity AC Express',
            transportType: 'Express Highway Coach',
            fromStation: RailwayService.brc,
            toStation: const Station(code: 'ADI', name: 'Ahmedabad Junction', city: 'Ahmedabad', platforms: 12),
            departureTime: 'Every 20 mins from Station Bay 3',
            arrivalTime: '1h 45m travel time via NE-1 Expressway',
            duration: '1h 45m',
            fare: 210.0,
            seatStatus: 'Direct Walk-in Available',
            recommendationReason: 'Leaves directly from Vadodara Railway Station Bus Bay with zero waiting delay.',
            limitationNote: 'Road traffic variation at Ahmedabad city ring road entry.',
            isDirect: true,
            riskScore: 2,
            isSimulatedSample: true,
          ),
        ];
        break;

      case DemoScenario.urgentPlatformShift:
        train12952.delayMinutes = 8;
        _activeDisruption = Disruption(
          id: 'disrupt_plat_02',
          title: 'Platform Reallocated: Platform 2 ➔ Platform 4 at Mathura Junction',
          plainDescription:
              'Due to incoming goods traffic on Line 2, Train 12952 will now arrive on Platform 4 instead of Platform 2. Please use Foot Overbridge #2 ramp or Escalator B near Coach S4 position.',
          severity: DisruptionSeverity.warning,
          source: VerificationSource.stationMaster,
          timestamp: now.subtract(const Duration(minutes: 2)),
          delayMinutes: 8,
          affectedStationCode: 'MTJ',
          originalPlatform: 2,
          newPlatform: 4,
          walkingGuidance:
              'Platform 4 is accessible via Foot Overbridge (FOB) #2 ramp. Wheelchair elevator is operational at the south end near the Station Master office.',
          isConnectingJourneyAffected: false,
          officialAdvice:
              'Station audio announcements are live. Porter and battery buggy services are stationed at FOB #2 ramp for elderly passengers and heavy luggage.',
        );
        _activeConnectingJourney = null;
        _alternativeJourneys = [];
        break;

      case DemoScenario.fogDelayRecovery:
        train12952.delayMinutes = 42;
        train12952.currentLocationDescription = 'Fog safety protocol active • Speed 65 km/h';
        _activeDisruption = Disruption(
          id: 'disrupt_fog_03',
          title: 'Dense Fog Protocol • 42 min Delay on Mathura-Agra Section',
          plainDescription:
              'Train speed has been regulated to 65 km/h under Northern Railway fog safety precautions. Delay is expected to be partially recovered (+15 mins) on the clear Palwal corridor.',
          severity: DisruptionSeverity.warning,
          source: VerificationSource.ntesLive,
          timestamp: now.subtract(const Duration(minutes: 6)),
          delayMinutes: 42,
          affectedStationCode: 'AGC',
          isConnectingJourneyAffected: false,
          officialAdvice:
              'Loco pilot is utilizing GPS Fog Safety Devices (FSD). Track inspection has cleared speed acceleration after 08:30 hrs.',
        );
        _activeConnectingJourney = null;
        _alternativeJourneys = [];
        break;

      case DemoScenario.trainCancelledTDR:
        train22436.delayMinutes = 0;
        _activeDisruption = Disruption(
          id: 'disrupt_canc_04',
          title: 'Train Cancelled • Route Track Upgradation on CNB-PRYJ Section',
          plainDescription:
              'Northern Railway has cancelled Train 22436 Vande Bharat Express today due to non-interlocking track modernization work between Kanpur Central and Prayagraj.',
          severity: DisruptionSeverity.critical,
          source: VerificationSource.ntesLive,
          timestamp: now.subtract(const Duration(minutes: 10)),
          delayMinutes: 0,
          affectedStationCode: 'NDLS',
          isConnectingJourneyAffected: false,
          officialAdvice:
              'Automatic 100% Refund: E-ticket fares will be automatically credited to your original payment account within 3 to 5 banking days. No manual TDR filing is required for fully cancelled trains.',
        );
        _activeConnectingJourney = null;
        _alternativeJourneys = [
          AlternativeJourney(
            id: 'alt_canc_01',
            trainNumber: '12560',
            trainName: 'Shiv Ganga Superfast Express',
            transportType: 'Superfast Express',
            fromStation: RailwayService.ndls,
            toStation: RailwayService.bsb,
            departureTime: '20:05',
            arrivalTime: '07:10',
            duration: '11h 05m',
            fare: 1540.0,
            seatStatus: 'RAC 12 (3A) / Tatkal Open at 10 AM',
            recommendationReason: 'Most reliable overnight alternative from New Delhi to Varanasi Junction.',
            limitationNote: 'Overnight journey with sleeper & AC coaches.',
            isDirect: true,
            riskScore: 1,
            isSimulatedSample: true,
          ),
          AlternativeJourney(
            id: 'alt_canc_02',
            trainNumber: '12582',
            trainName: 'New Delhi - Banaras Superfast',
            transportType: 'Superfast Mail',
            fromStation: RailwayService.ndls,
            toStation: RailwayService.bsb,
            departureTime: '22:50',
            arrivalTime: '10:00',
            duration: '11h 10m',
            fare: 1420.0,
            seatStatus: 'AVAILABLE-28 (3A)',
            recommendationReason: 'Confirmed AC 3-tier berths available for immediate reservation.',
            limitationNote: 'Departs late evening from Platform 14.',
            isDirect: true,
            riskScore: 1,
            isSimulatedSample: true,
          ),
        ];
        break;

      case DemoScenario.onTimeSmoothTrip:
        train12952.delayMinutes = 0;
        train12952.currentLocationDescription = 'Cruising at 115 km/h • Green Signal Corridor';
        _activeDisruption = null;
        _activeConnectingJourney = null;
        _alternativeJourneys = [];
        break;
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _syncTicker?.cancel();
    super.dispose();
  }
}
