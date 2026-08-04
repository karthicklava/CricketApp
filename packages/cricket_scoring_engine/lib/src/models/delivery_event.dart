import 'package:meta/meta.dart';

enum ExtrasType { none, wide, noBall, bye, legBye, penalty }

enum WicketType {
  bowled,
  caught,
  lbw,
  runOut,
  stumped,
  hitWicket,
  retiredHurt,
  retiredOut,
  retiredNotOut,
  obstructingField,
  hitBallTwice,
  timedOut,
  absentHurt,
}

@immutable
class WicketDetail {
  final WicketType type;
  final String dismissedPlayerId;
  final String? fielderId;
  final int runsCompletedBeforeDismissal;
  final bool crossed;

  const WicketDetail({
    required this.type,
    required this.dismissedPlayerId,
    this.fielderId,
    this.runsCompletedBeforeDismissal = 0,
    this.crossed = false,
  });

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'dismissedPlayerId': dismissedPlayerId,
        'fielderId': fielderId,
        'runsCompletedBeforeDismissal': runsCompletedBeforeDismissal,
        'crossed': crossed,
      };

  factory WicketDetail.fromJson(Map<String, dynamic> json) => WicketDetail(
        type: WicketType.values.firstWhere((e) => e.name == json['type']),
        dismissedPlayerId: json['dismissedPlayerId'] as String,
        fielderId: json['fielderId'] as String?,
        runsCompletedBeforeDismissal:
            json['runsCompletedBeforeDismissal'] as int? ?? 0,
        crossed: json['crossed'] as bool? ?? false,
      );
}

@immutable
class DeliveryEvent {
  final String eventId;
  final String matchId;
  final String inningsId;
  final int overNumber;
  final int legalBallNumber;
  final int eventSequence;
  final int sequenceInOver;
  final String scorerDeviceId;
  final String strikerId;
  final String nonStrikerId;
  final String bowlerId;
  final int runsBatter;
  final ExtrasType extrasType;
  final int extrasRuns;
  final int wideRuns;
  final int additionalWideRuns;
  final int noBallRuns;
  final int byeRuns;
  final int legByeRuns;
  final int penaltyRuns;
  final bool isLegal;
  final bool isBoundaryFour;
  final bool isBoundarySix;
  final WicketDetail? wicket;
  final bool isReversed;
  final String? reversedByEventId;
  final String previousEventHash;
  final int clientTimestamp;

  const DeliveryEvent({
    required this.eventId,
    required this.matchId,
    required this.inningsId,
    required this.overNumber,
    required this.legalBallNumber,
    required this.eventSequence,
    required this.sequenceInOver,
    required this.scorerDeviceId,
    required this.strikerId,
    required this.nonStrikerId,
    required this.bowlerId,
    this.runsBatter = 0,
    this.extrasType = ExtrasType.none,
    this.extrasRuns = 0,
    this.wideRuns = 0,
    this.additionalWideRuns = 0,
    this.noBallRuns = 0,
    this.byeRuns = 0,
    this.legByeRuns = 0,
    this.penaltyRuns = 0,
    this.isLegal = true,
    this.isBoundaryFour = false,
    this.isBoundarySix = false,
    this.wicket,
    this.isReversed = false,
    this.reversedByEventId,
    required this.previousEventHash,
    required this.clientTimestamp,
  });

  int get totalExtras =>
      wideRuns + noBallRuns + byeRuns + legByeRuns + penaltyRuns;

  int get totalRuns => runsBatter + totalExtras;

  int get completedRunsForStrike {
    if (wideRuns > 0) return additionalWideRuns;
    if (noBallRuns > 0) {
      return runsBatter + byeRuns + legByeRuns;
    }
    if (byeRuns > 0) return byeRuns;
    if (legByeRuns > 0) return legByeRuns;
    return runsBatter;
  }

  String get displayLabel {
    final suffix = wicket == null ? '' : '+W';
    if (wicket?.type == WicketType.retiredHurt) return 'RH';
    if (wicket?.type == WicketType.retiredOut) return 'RO';
    if (wicket?.type == WicketType.absentHurt) return 'ABS';
    if (wideRuns > 0) {
      return '${additionalWideRuns == 0 ? 'Wd' : 'Wd+$additionalWideRuns'}$suffix';
    }
    if (noBallRuns > 0) {
      final additional = runsBatter + byeRuns + legByeRuns;
      return '${additional == 0 ? 'Nb' : 'Nb+$additional'}$suffix';
    }
    if (byeRuns > 0) return 'B$byeRuns$suffix';
    if (legByeRuns > 0) return 'LB$legByeRuns$suffix';
    if (penaltyRuns > 0) return 'P$penaltyRuns$suffix';
    if (wicket != null && runsBatter == 0) return 'W';
    return '$runsBatter$suffix';
  }

  String get ballReference => '${overNumber + 1}.$legalBallNumber';

  bool get isBowlerWicket {
    if (wicket == null) return false;
    switch (wicket!.type) {
      case WicketType.bowled:
      case WicketType.caught:
      case WicketType.lbw:
      case WicketType.stumped:
      case WicketType.hitWicket:
        return true;
      case WicketType.runOut:
      case WicketType.retiredHurt:
      case WicketType.retiredOut:
      case WicketType.retiredNotOut:
      case WicketType.obstructingField:
      case WicketType.hitBallTwice:
      case WicketType.timedOut:
      case WicketType.absentHurt:
        return false;
    }
  }

  Map<String, dynamic> toJson() => {
        'eventId': eventId,
        'matchId': matchId,
        'inningsId': inningsId,
        'overNumber': overNumber,
        'legalBallNumber': legalBallNumber,
        'eventSequence': eventSequence,
        'sequenceInOver': sequenceInOver,
        'scorerDeviceId': scorerDeviceId,
        'strikerId': strikerId,
        'nonStrikerId': nonStrikerId,
        'bowlerId': bowlerId,
        'runsBatter': runsBatter,
        'extrasType': extrasType.name,
        'extrasRuns': extrasRuns,
        'wideRuns': wideRuns,
        'additionalWideRuns': additionalWideRuns,
        'noBallRuns': noBallRuns,
        'byeRuns': byeRuns,
        'legByeRuns': legByeRuns,
        'penaltyRuns': penaltyRuns,
        'isLegal': isLegal,
        'isBoundaryFour': isBoundaryFour,
        'isBoundarySix': isBoundarySix,
        'wicket': wicket?.toJson(),
        'isReversed': isReversed,
        'reversedByEventId': reversedByEventId,
        'previousEventHash': previousEventHash,
        'clientTimestamp': clientTimestamp,
      };

  factory DeliveryEvent.fromJson(Map<String, dynamic> json) => DeliveryEvent(
        eventId: json['eventId'] as String,
        matchId: json['matchId'] as String,
        inningsId: json['inningsId'] as String,
        overNumber: json['overNumber'] as int,
        legalBallNumber: json['legalBallNumber'] as int,
        eventSequence: json['eventSequence'] as int,
        sequenceInOver:
            json['sequenceInOver'] as int? ?? json['eventSequence'] as int,
        scorerDeviceId: json['scorerDeviceId'] as String,
        strikerId: json['strikerId'] as String,
        nonStrikerId: json['nonStrikerId'] as String,
        bowlerId: json['bowlerId'] as String,
        runsBatter: json['runsBatter'] as int? ?? 0,
        extrasType: ExtrasType.values.firstWhere(
          (e) => e.name == json['extrasType'],
          orElse: () => ExtrasType.none,
        ),
        extrasRuns: json['extrasRuns'] as int? ?? 0,
        wideRuns: json['wideRuns'] as int? ??
            (json['extrasType'] == 'wide'
                ? (json['extrasRuns'] as int? ?? 1)
                : 0),
        additionalWideRuns: json['additionalWideRuns'] as int? ??
            ((json['wideRuns'] as int? ??
                        (json['extrasType'] == 'wide'
                            ? (json['extrasRuns'] as int? ?? 1)
                            : 0)) -
                    1)
                .clamp(0, 999) as int,
        noBallRuns: json['noBallRuns'] as int? ??
            (json['extrasType'] == 'noBall' ? 1 : 0),
        byeRuns: json['byeRuns'] as int? ??
            (json['extrasType'] == 'bye'
                ? (json['extrasRuns'] as int? ?? 0)
                : 0),
        legByeRuns: json['legByeRuns'] as int? ??
            (json['extrasType'] == 'legBye'
                ? (json['extrasRuns'] as int? ?? 0)
                : 0),
        penaltyRuns: json['penaltyRuns'] as int? ??
            (json['extrasType'] == 'penalty'
                ? (json['extrasRuns'] as int? ?? 0)
                : 0),
        isLegal: json['isLegal'] as bool? ?? true,
        isBoundaryFour: json['isBoundaryFour'] as bool? ?? false,
        isBoundarySix: json['isBoundarySix'] as bool? ?? false,
        wicket: json['wicket'] != null
            ? WicketDetail.fromJson(json['wicket'] as Map<String, dynamic>)
            : null,
        isReversed: json['isReversed'] as bool? ?? false,
        reversedByEventId: json['reversedByEventId'] as String?,
        previousEventHash: json['previousEventHash'] as String,
        clientTimestamp: json['clientTimestamp'] as int,
      );
}
