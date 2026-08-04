import 'package:meta/meta.dart';

enum InningsFlowState {
  scoring,
  awaitingNextBatter,
  awaitingNextBowler,
  inningsCompleted,
}

@immutable
class InningsState {
  final String inningsId;
  final String battingTeamId;
  final String bowlingTeamId;
  final int inningsNumber;
  final int totalRuns;
  final int totalWickets;
  final int legalBallsBowled;
  final String strikerId;
  final String nonStrikerId;
  final String? currentBowlerId;
  final String? previousBowlerId;
  final String? previousOverBowlerId;
  final String? activeOverId;
  final int nextOverNumber;
  final InningsFlowState flowState;
  final int? targetRuns;
  final bool isCompleted;
  final String? completionReason;
  final int playingMemberCountSnapshot;
  final int maximumWickets;
  final List<String> battingOrder;

  const InningsState({
    required this.inningsId,
    required this.battingTeamId,
    required this.bowlingTeamId,
    required this.inningsNumber,
    this.totalRuns = 0,
    this.totalWickets = 0,
    this.legalBallsBowled = 0,
    required this.strikerId,
    required this.nonStrikerId,
    required this.currentBowlerId,
    this.previousBowlerId,
    this.previousOverBowlerId,
    this.activeOverId,
    this.nextOverNumber = 0,
    this.flowState = InningsFlowState.scoring,
    this.targetRuns,
    this.isCompleted = false,
    this.completionReason,
    this.playingMemberCountSnapshot = 0,
    this.maximumWickets = 0,
    this.battingOrder = const [],
  });

  String get oversFormatted {
    final overs = legalBallsBowled ~/ 6;
    final balls = legalBallsBowled % 6;
    return '$overs.$balls';
  }

  double get currentRunRate {
    if (legalBallsBowled == 0) return 0.0;
    final overs = legalBallsBowled / 6.0;
    return totalRuns / overs;
  }

  double get runRate => currentRunRate;

  double? requiredRunRate(int totalOvers) {
    if (targetRuns == null) return null;
    final totalBalls = totalOvers * 6;
    final ballsRemaining = totalBalls - legalBallsBowled;
    if (ballsRemaining <= 0) return 0.0;
    final runsNeeded = targetRuns! - totalRuns;
    if (runsNeeded <= 0) return 0.0;
    final oversRemaining = ballsRemaining / 6.0;
    return runsNeeded / oversRemaining;
  }

  InningsState copyWith({
    String? inningsId,
    String? battingTeamId,
    String? bowlingTeamId,
    int? inningsNumber,
    int? totalRuns,
    int? totalWickets,
    int? legalBallsBowled,
    String? strikerId,
    String? nonStrikerId,
    String? currentBowlerId,
    bool clearCurrentBowler = false,
    String? previousBowlerId,
    String? previousOverBowlerId,
    String? activeOverId,
    bool clearActiveOver = false,
    int? nextOverNumber,
    InningsFlowState? flowState,
    int? targetRuns,
    bool? isCompleted,
    String? completionReason,
    int? playingMemberCountSnapshot,
    int? maximumWickets,
    List<String>? battingOrder,
  }) {
    return InningsState(
      inningsId: inningsId ?? this.inningsId,
      battingTeamId: battingTeamId ?? this.battingTeamId,
      bowlingTeamId: bowlingTeamId ?? this.bowlingTeamId,
      inningsNumber: inningsNumber ?? this.inningsNumber,
      totalRuns: totalRuns ?? this.totalRuns,
      totalWickets: totalWickets ?? this.totalWickets,
      legalBallsBowled: legalBallsBowled ?? this.legalBallsBowled,
      strikerId: strikerId ?? this.strikerId,
      nonStrikerId: nonStrikerId ?? this.nonStrikerId,
      currentBowlerId:
          clearCurrentBowler ? null : (currentBowlerId ?? this.currentBowlerId),
      previousBowlerId: previousBowlerId ?? this.previousBowlerId,
      previousOverBowlerId: previousOverBowlerId ?? this.previousOverBowlerId,
      activeOverId:
          clearActiveOver ? null : (activeOverId ?? this.activeOverId),
      nextOverNumber: nextOverNumber ?? this.nextOverNumber,
      flowState: flowState ?? this.flowState,
      targetRuns: targetRuns ?? this.targetRuns,
      isCompleted: isCompleted ?? this.isCompleted,
      completionReason: completionReason ?? this.completionReason,
      playingMemberCountSnapshot:
          playingMemberCountSnapshot ?? this.playingMemberCountSnapshot,
      maximumWickets: maximumWickets ?? this.maximumWickets,
      battingOrder: battingOrder ?? this.battingOrder,
    );
  }

  Map<String, dynamic> toJson() => {
        'inningsId': inningsId,
        'battingTeamId': battingTeamId,
        'bowlingTeamId': bowlingTeamId,
        'inningsNumber': inningsNumber,
        'totalRuns': totalRuns,
        'totalWickets': totalWickets,
        'legalBallsBowled': legalBallsBowled,
        'oversFormatted': oversFormatted,
        'strikerId': strikerId,
        'nonStrikerId': nonStrikerId,
        'currentBowlerId': currentBowlerId,
        'previousBowlerId': previousBowlerId,
        'previousOverBowlerId': previousOverBowlerId,
        'activeOverId': activeOverId,
        'nextOverNumber': nextOverNumber,
        'flowState': flowState.name,
        'targetRuns': targetRuns,
        'isCompleted': isCompleted,
        'completionReason': completionReason,
        'playingMemberCountSnapshot': playingMemberCountSnapshot,
        'maximumWickets': maximumWickets,
        'battingOrder': battingOrder,
      };

  factory InningsState.fromJson(Map<String, dynamic> json) => InningsState(
        inningsId: json['inningsId'] as String,
        battingTeamId: json['battingTeamId'] as String,
        bowlingTeamId: json['bowlingTeamId'] as String,
        inningsNumber: json['inningsNumber'] as int,
        totalRuns: json['totalRuns'] as int? ?? 0,
        totalWickets: json['totalWickets'] as int? ?? 0,
        legalBallsBowled: json['legalBallsBowled'] as int? ?? 0,
        strikerId: json['strikerId'] as String,
        nonStrikerId: json['nonStrikerId'] as String,
        currentBowlerId: json['currentBowlerId'] as String?,
        previousBowlerId: json['previousBowlerId'] as String?,
        previousOverBowlerId: json['previousOverBowlerId'] as String? ??
            json['previousBowlerId'] as String?,
        activeOverId: json.containsKey('activeOverId')
            ? json['activeOverId'] as String?
            : '${json['inningsId']}_over_${(json['legalBallsBowled'] as int? ?? 0) ~/ 6}',
        nextOverNumber: json['nextOverNumber'] as int? ??
            (json['legalBallsBowled'] as int? ?? 0) ~/ 6,
        flowState: InningsFlowState.values.firstWhere(
          (value) => value.name == json['flowState'],
          orElse: () => (json['isCompleted'] as bool? ?? false)
              ? InningsFlowState.inningsCompleted
              : InningsFlowState.scoring,
        ),
        targetRuns: json['targetRuns'] as int?,
        isCompleted: json['isCompleted'] as bool? ?? false,
        completionReason: json['completionReason'] as String?,
        playingMemberCountSnapshot:
            json['playingMemberCountSnapshot'] as int? ?? 0,
        maximumWickets: json['maximumWickets'] as int? ?? 0,
        battingOrder:
            (json['battingOrder'] as List<dynamic>?)?.cast<String>() ??
                const [],
      );
}
