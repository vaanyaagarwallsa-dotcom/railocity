import 'package:flutter/material.dart';

enum TrainStatus { onTime, delayed, arrived, departed, scheduled, cancelled, diverted }

enum DisruptionSeverity { info, warning, critical }

enum VerificationSource { ntesLive, stationMaster, railocityEstimate, passengerReport }

enum ConnectionRiskLevel { safe, tight, criticalMiss }

class Station {
  final String code;
  final String name;
  final String city;
  final int platforms;
  final bool hasWheelchairAccess;
  final bool hasEscalators;
  final bool hasElevators;
  final bool hasBrailleSignage;

  const Station({
    required this.code,
    required this.name,
    required this.city,
    this.platforms = 8,
    this.hasWheelchairAccess = true,
    this.hasEscalators = true,
    this.hasElevators = true,
    this.hasBrailleSignage = true,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Station && runtimeType == other.runtimeType && code == other.code;

  @override
  int get hashCode => code.hashCode;
}

class TrainStop {
  final Station station;
  final String scheduledArrival;
  final String scheduledDeparture;
  String actualArrival;
  String actualDeparture;
  int platform;
  final double distanceKm;
  TrainStatus status;
  int delayMinutes;
  final String delayReason;

  TrainStop({
    required this.station,
    required this.scheduledArrival,
    required this.scheduledDeparture,
    required this.actualArrival,
    required this.actualDeparture,
    required this.platform,
    required this.distanceKm,
    this.status = TrainStatus.scheduled,
    this.delayMinutes = 0,
    this.delayReason = '',
  });
}

class SeatClass {
  final String code; // 1A, 2A, 3A, SL, CC, EC
  final String name; // AC First, AC 2-Tier, AC 3-Tier, Sleeper, Chair Car, Exec
  final double fare;
  final int availableSeats;
  final String statusText; // "AVAILABLE-42", "RAC 12", "WL 5"

  const SeatClass({
    required this.code,
    required this.name,
    required this.fare,
    required this.availableSeats,
    required this.statusText,
  });

  bool get isConfirmed => statusText.toUpperCase().contains('AVAILABLE');
  bool get isRAC => statusText.toUpperCase().contains('RAC');
  bool get isWL => statusText.toUpperCase().contains('WL');
}

class Train {
  final String trainNumber;
  final String trainName;
  final String trainType; // Vande Bharat, Rajdhani Superfast, Shatabdi, Superfast
  final Station source;
  final Station destination;
  final List<TrainStop> stops;
  final List<SeatClass> classes;
  int currentSpeedKmph;
  String currentLocationDescription;
  int currentStopIndex;
  int delayMinutes;
  final List<String> coaches; // ['ENG', 'EOG', 'B1', 'B2', 'B3', 'A1', 'EOG']

  Train({
    required this.trainNumber,
    required this.trainName,
    required this.trainType,
    required this.source,
    required this.destination,
    required this.stops,
    required this.classes,
    this.currentSpeedKmph = 85,
    this.currentLocationDescription = 'Approaching Mathura Junction',
    this.currentStopIndex = 1,
    this.delayMinutes = 4,
    required this.coaches,
  });

  TrainStop? getStopForStation(String stationCode) {
    for (final stop in stops) {
      if (stop.station.code.toUpperCase() == stationCode.toUpperCase()) {
        return stop;
      }
    }
    return null;
  }

  int getMinutesUntilArrivalAt(String stationCode) {
    final targetIndex = stops.indexWhere(
      (s) => s.station.code.toUpperCase() == stationCode.toUpperCase(),
    );
    if (targetIndex == -1) return -1;
    if (targetIndex < currentStopIndex) return 0;

    int stopsAway = targetIndex - currentStopIndex;
    int baseMinutes = stopsAway * 35 + (targetIndex == currentStopIndex ? 12 : 0);
    return (baseMinutes + delayMinutes).clamp(1, 1440);
  }
}

class Disruption {
  final String id;
  final String title;
  final String plainDescription;
  final DisruptionSeverity severity;
  final VerificationSource source;
  final DateTime timestamp;
  final int delayMinutes;
  final String affectedStationCode;
  final int? originalPlatform;
  final int? newPlatform;
  final String? walkingGuidance;
  final bool isConnectingJourneyAffected;
  final String officialAdvice;

  const Disruption({
    required this.id,
    required this.title,
    required this.plainDescription,
    required this.severity,
    required this.source,
    required this.timestamp,
    this.delayMinutes = 0,
    required this.affectedStationCode,
    this.originalPlatform,
    this.newPlatform,
    this.walkingGuidance,
    this.isConnectingJourneyAffected = false,
    required this.officialAdvice,
  });

  String get sourceLabel {
    switch (source) {
      case VerificationSource.ntesLive:
        return 'Verified by NTES Live';
      case VerificationSource.stationMaster:
        return 'Verified by Station Master';
      case VerificationSource.railocityEstimate:
        return 'Railocity AI Estimate';
      case VerificationSource.passengerReport:
        return 'Unverified Passenger Report';
    }
  }
}

class JourneyLeg {
  final Train train;
  final Station fromStation;
  final Station toStation;
  final String scheduledDeparture;
  final String scheduledArrival;
  final String actualDeparture;
  final String actualArrival;
  final int delayMinutes;
  final int platform;
  final String coach;
  final String seat;
  final String pnr;

  const JourneyLeg({
    required this.train,
    required this.fromStation,
    required this.toStation,
    required this.scheduledDeparture,
    required this.scheduledArrival,
    required this.actualDeparture,
    required this.actualArrival,
    required this.delayMinutes,
    required this.platform,
    required this.coach,
    required this.seat,
    required this.pnr,
  });
}

class ConnectingJourney {
  final String journeyId;
  final String passengerName;
  final JourneyLeg firstLeg;
  final JourneyLeg secondLeg;
  final Station transferStation;
  final int scheduledTransferBufferMinutes; // e.g. 75 min scheduled buffer
  final Disruption? activeDisruption;

  const ConnectingJourney({
    required this.journeyId,
    required this.passengerName,
    required this.firstLeg,
    required this.secondLeg,
    required this.transferStation,
    required this.scheduledTransferBufferMinutes,
    this.activeDisruption,
  });

  /// Deterministic calculation of remaining transfer buffer
  int get remainingTransferBufferMinutes {
    final effectiveDelay = firstLeg.delayMinutes;
    return scheduledTransferBufferMinutes - effectiveDelay;
  }

  ConnectionRiskLevel get riskLevel {
    final remaining = remainingTransferBufferMinutes;
    if (remaining <= 15) return ConnectionRiskLevel.criticalMiss;
    if (remaining <= 35) return ConnectionRiskLevel.tight;
    return ConnectionRiskLevel.safe;
  }

  String get riskLabel {
    switch (riskLevel) {
      case ConnectionRiskLevel.criticalMiss:
        return 'High Risk of Missed Connection';
      case ConnectionRiskLevel.tight:
        return 'Tight Transfer Window';
      case ConnectionRiskLevel.safe:
        return 'Feasible Transfer Window';
    }
  }
}

class AlternativeJourney {
  final String id;
  final String trainNumber;
  final String trainName;
  final String transportType; // Train, Vande Bharat, Intercity Express, AC Bus
  final Station fromStation;
  final Station toStation;
  final String departureTime;
  final String arrivalTime;
  final String duration;
  final double fare;
  final String seatStatus;
  final String recommendationReason;
  final String limitationNote;
  final bool isDirect;
  final int riskScore; // 1 to 5, 1 is best
  final bool isSimulatedSample;

  const AlternativeJourney({
    required this.id,
    required this.trainNumber,
    required this.trainName,
    required this.transportType,
    required this.fromStation,
    required this.toStation,
    required this.departureTime,
    required this.arrivalTime,
    required this.duration,
    required this.fare,
    required this.seatStatus,
    required this.recommendationReason,
    required this.limitationNote,
    this.isDirect = true,
    this.riskScore = 1,
    this.isSimulatedSample = true,
  });
}

class AlertItem {
  final String id;
  final String title;
  final String description;
  final DisruptionSeverity severity;
  final DateTime timestamp;
  final String trainNumber;
  final String stationCode;
  final String verifiedSource;
  final bool isRead;
  final String? relatedJourneyId;

  const AlertItem({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    required this.timestamp,
    required this.trainNumber,
    required this.stationCode,
    required this.verifiedSource,
    this.isRead = false,
    this.relatedJourneyId,
  });

  AlertItem copyWith({bool? isRead}) {
    return AlertItem(
      id: id,
      title: title,
      description: description,
      severity: severity,
      timestamp: timestamp,
      trainNumber: trainNumber,
      stationCode: stationCode,
      verifiedSource: verifiedSource,
      isRead: isRead ?? this.isRead,
      relatedJourneyId: relatedJourneyId,
    );
  }
}

class Booking {
  final String pnr;
  final String trainNumber;
  final String trainName;
  final String trainType;
  final Station sourceStation;
  final Station destinationStation;
  final DateTime travelDate;
  final String departureTime;
  final String arrivalTime;
  final String coach;
  final String seatNumber;
  final String berthType;
  final String seatClass;
  final String passengerName;
  final int passengerAge;
  final String passengerGender;
  final double fare;
  final String status;
  final int platform;

  Booking({
    required this.pnr,
    required this.trainNumber,
    required this.trainName,
    required this.trainType,
    required this.sourceStation,
    required this.destinationStation,
    required this.travelDate,
    required this.departureTime,
    required this.arrivalTime,
    required this.coach,
    required this.seatNumber,
    required this.berthType,
    required this.seatClass,
    required this.passengerName,
    required this.passengerAge,
    required this.passengerGender,
    required this.fare,
    this.status = 'CONFIRMED',
    this.platform = 3,
  });

  String get pnrChunked {
    if (pnr.length >= 10) {
      return '${pnr.substring(0, 3)} - ${pnr.substring(3, 6)} - ${pnr.substring(6)}';
    }
    return pnr;
  }
}

enum MessageSender { user, ai, system }

class ChatAction {
  final String label;
  final String actionType;
  final dynamic payload;

  ChatAction({
    required this.label,
    required this.actionType,
    this.payload,
  });
}

class ChatMessage {
  final String id;
  final MessageSender sender;
  final String text;
  final DateTime timestamp;
  final List<String> suggestedChips;
  final List<ChatAction> actions;
  final Booking? bookingCard;
  final Train? trainStatusCard;
  final Disruption? disruptionCard;
  final ConnectingJourney? connectingJourneyCard;
  final List<String>? reasoningSteps;
  final bool isThinking;

  ChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.timestamp,
    this.suggestedChips = const [],
    this.actions = const [],
    this.bookingCard,
    this.trainStatusCard,
    this.disruptionCard,
    this.connectingJourneyCard,
    this.reasoningSteps,
    this.isThinking = false,
  });
}
