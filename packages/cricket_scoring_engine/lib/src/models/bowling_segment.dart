import 'package:meta/meta.dart';

enum BowlerChangeReason {
  injury,
  illness,
  unableToContinue,
  equipmentIssue,
  suspended,
  tacticalLocalRule,
  other,
}

@immutable
class BowlingSegment {
  final String id;
  final String inningsId;
  final String overId;
  final int overNumber;
  final String bowlerId;
  final int startSequence;
  final int startLegalBall;
  final int? endSequence;
  final int legalBallsBowled;
  final BowlerChangeReason? endReason;

  const BowlingSegment({
    required this.id,
    required this.inningsId,
    required this.overId,
    required this.overNumber,
    required this.bowlerId,
    required this.startSequence,
    required this.startLegalBall,
    this.endSequence,
    this.legalBallsBowled = 0,
    this.endReason,
  });

  bool get isOpen => endSequence == null;

  BowlingSegment copyWith({
    int? endSequence,
    bool clearEndSequence = false,
    int? legalBallsBowled,
    BowlerChangeReason? endReason,
  }) =>
      BowlingSegment(
        id: id,
        inningsId: inningsId,
        overId: overId,
        overNumber: overNumber,
        bowlerId: bowlerId,
        startSequence: startSequence,
        startLegalBall: startLegalBall,
        endSequence: clearEndSequence ? null : endSequence ?? this.endSequence,
        legalBallsBowled: legalBallsBowled ?? this.legalBallsBowled,
        endReason: endReason ?? this.endReason,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'inningsId': inningsId,
        'overId': overId,
        'overNumber': overNumber,
        'bowlerId': bowlerId,
        'startSequence': startSequence,
        'startLegalBall': startLegalBall,
        'endSequence': endSequence,
        'legalBallsBowled': legalBallsBowled,
        'endReason': endReason?.name,
      };

  factory BowlingSegment.fromJson(Map<String, dynamic> json) => BowlingSegment(
        id: json['id'] as String,
        inningsId: json['inningsId'] as String,
        overId: json['overId'] as String,
        overNumber: json['overNumber'] as int,
        bowlerId: json['bowlerId'] as String,
        startSequence: json['startSequence'] as int,
        startLegalBall: json['startLegalBall'] as int,
        endSequence: json['endSequence'] as int?,
        legalBallsBowled: json['legalBallsBowled'] as int? ?? 0,
        endReason: json['endReason'] == null
            ? null
            : BowlerChangeReason.values.firstWhere(
                (value) => value.name == json['endReason'],
              ),
      );
}

@immutable
class BowlerReplacementEvent {
  final String id;
  final String matchId;
  final String inningsId;
  final String overId;
  final String previousBowlerId;
  final String replacementBowlerId;
  final int legalBallsCompleted;
  final int remainingLegalBalls;
  final BowlerChangeReason reason;
  final int currentScore;
  final String changedBy;
  final int timestamp;

  const BowlerReplacementEvent({
    required this.id,
    required this.matchId,
    required this.inningsId,
    required this.overId,
    required this.previousBowlerId,
    required this.replacementBowlerId,
    required this.legalBallsCompleted,
    required this.remainingLegalBalls,
    required this.reason,
    required this.currentScore,
    required this.changedBy,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'matchId': matchId,
        'inningsId': inningsId,
        'overId': overId,
        'previousBowlerId': previousBowlerId,
        'replacementBowlerId': replacementBowlerId,
        'legalBallsCompleted': legalBallsCompleted,
        'remainingLegalBalls': remainingLegalBalls,
        'reason': reason.name,
        'currentScore': currentScore,
        'changedBy': changedBy,
        'timestamp': timestamp,
      };

  factory BowlerReplacementEvent.fromJson(Map<String, dynamic> json) =>
      BowlerReplacementEvent(
        id: json['id'] as String,
        matchId: json['matchId'] as String,
        inningsId: json['inningsId'] as String,
        overId: json['overId'] as String,
        previousBowlerId: json['previousBowlerId'] as String,
        replacementBowlerId: json['replacementBowlerId'] as String,
        legalBallsCompleted: json['legalBallsCompleted'] as int,
        remainingLegalBalls: json['remainingLegalBalls'] as int,
        reason: BowlerChangeReason.values.firstWhere(
          (value) => value.name == json['reason'],
        ),
        currentScore: json['currentScore'] as int,
        changedBy: json['changedBy'] as String,
        timestamp: json['timestamp'] as int,
      );
}
