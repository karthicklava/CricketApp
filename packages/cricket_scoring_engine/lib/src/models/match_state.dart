import 'package:meta/meta.dart';
import 'match_config.dart';
import 'team.dart';
import 'innings_state.dart';
import 'delivery_event.dart';
import 'match_award.dart';
import 'bowling_segment.dart';
import 'match_team_role_snapshot.dart';

enum MatchStatus {
  draft,
  ready,
  live,
  inningsBreak,
  paused,
  completed,
  abandoned,
  noResult,
  cancelled,
}

enum MatchEndOutcome {
  abandoned,
  noResult,
  teamForfeit,
  cancelled,
  manuallyCompleted,
}

enum MatchEndReason {
  rain,
  badLight,
  wetOutfield,
  unsafeGround,
  injury,
  insufficientPlayers,
  teamWithdrawal,
  timeLimit,
  equipmentIssue,
  dispute,
  technicalIssue,
  other,
}

@immutable
class MatchResult {
  final String winnerTeamId;
  final String resultString;
  final int winByRuns;
  final int winByWickets;
  final bool isTie;
  final bool isSuperOverRequired;

  const MatchResult({
    required this.winnerTeamId,
    required this.resultString,
    this.winByRuns = 0,
    this.winByWickets = 0,
    this.isTie = false,
    this.isSuperOverRequired = false,
  });

  Map<String, dynamic> toJson() => {
        'winnerTeamId': winnerTeamId,
        'resultString': resultString,
        'winByRuns': winByRuns,
        'winByWickets': winByWickets,
        'isTie': isTie,
        'isSuperOverRequired': isSuperOverRequired,
      };

  factory MatchResult.fromJson(Map<String, dynamic> json) => MatchResult(
        winnerTeamId: json['winnerTeamId'] as String? ?? '',
        resultString: json['resultString'] as String? ?? 'Match completed',
        winByRuns: json['winByRuns'] as int? ?? 0,
        winByWickets: json['winByWickets'] as int? ?? 0,
        isTie: json['isTie'] as bool? ?? false,
        isSuperOverRequired: json['isSuperOverRequired'] as bool? ?? false,
      );
}

@immutable
class MatchState {
  final String matchId;
  final MatchConfig config;
  final Team teamA;
  final Team teamB;
  final String tossWinnerTeamId;
  final String tossDecision; // 'BAT' or 'BOWL'
  final MatchStatus status;
  final int currentInningsIndex;
  final List<InningsState> innings;
  final List<DeliveryEvent> events;
  final MatchResult? result;
  final List<MatchAward> awards;
  final List<BowlingSegment> bowlingSegments;
  final List<BowlerReplacementEvent> bowlerReplacementEvents;
  final List<String> suspendedBowlerIds;
  final List<MatchTeamRoleSnapshot> teamRoleSnapshots;
  final int? scheduledAt;
  final int? startedAt;
  final int? createdAt;
  final String? venueName;
  final String? matchTimeZone;
  final MatchEndOutcome? manualEndOutcome;
  final MatchEndReason? endReasonCode;
  final String? endReasonText;
  final String? endNote;
  final bool endedManually;
  final int? endedAt;
  final String? endedBy;
  final String? loserTeamId;
  final String? resultType;
  final String? manualResultText;
  final MatchStatus? statusBeforeManualEnd;

  const MatchState({
    required this.matchId,
    required this.config,
    required this.teamA,
    required this.teamB,
    required this.tossWinnerTeamId,
    required this.tossDecision,
    this.status = MatchStatus.draft,
    this.currentInningsIndex = 0,
    required this.innings,
    this.events = const [],
    this.result,
    this.awards = const [],
    this.bowlingSegments = const [],
    this.bowlerReplacementEvents = const [],
    this.suspendedBowlerIds = const [],
    this.teamRoleSnapshots = const [],
    this.scheduledAt,
    this.startedAt,
    this.createdAt,
    this.venueName,
    this.matchTimeZone,
    this.manualEndOutcome,
    this.endReasonCode,
    this.endReasonText,
    this.endNote,
    this.endedManually = false,
    this.endedAt,
    this.endedBy,
    this.loserTeamId,
    this.resultType,
    this.manualResultText,
    this.statusBeforeManualEnd,
  });

  InningsState get activeInnings => innings[currentInningsIndex];

  MatchTeamRoleSnapshot? roleSnapshotForTeam(String teamId) {
    for (final snapshot in teamRoleSnapshots) {
      if (snapshot.teamId == teamId) return snapshot;
    }
    return null;
  }

  String displayNameFor(String teamId, String playerId, String playerName) {
    final roles = roleSnapshotForTeam(teamId);
    return formatPlayerDisplayName(
      playerName: playerName,
      isCaptain: roles?.captainPlayerId == playerId,
      isWicketkeeper: roles?.wicketkeeperPlayerId == playerId,
    );
  }

  MatchState copyWith({
    String? matchId,
    MatchConfig? config,
    Team? teamA,
    Team? teamB,
    String? tossWinnerTeamId,
    String? tossDecision,
    MatchStatus? status,
    int? currentInningsIndex,
    List<InningsState>? innings,
    List<DeliveryEvent>? events,
    MatchResult? result,
    List<MatchAward>? awards,
    List<BowlingSegment>? bowlingSegments,
    List<BowlerReplacementEvent>? bowlerReplacementEvents,
    List<String>? suspendedBowlerIds,
    List<MatchTeamRoleSnapshot>? teamRoleSnapshots,
    int? scheduledAt,
    int? startedAt,
    int? createdAt,
    String? venueName,
    String? matchTimeZone,
    MatchEndOutcome? manualEndOutcome,
    MatchEndReason? endReasonCode,
    String? endReasonText,
    String? endNote,
    bool? endedManually,
    int? endedAt,
    String? endedBy,
    String? loserTeamId,
    String? resultType,
    String? manualResultText,
    MatchStatus? statusBeforeManualEnd,
    bool clearManualEnd = false,
    bool clearResult = false,
  }) {
    return MatchState(
      matchId: matchId ?? this.matchId,
      config: config ?? this.config,
      teamA: teamA ?? this.teamA,
      teamB: teamB ?? this.teamB,
      tossWinnerTeamId: tossWinnerTeamId ?? this.tossWinnerTeamId,
      tossDecision: tossDecision ?? this.tossDecision,
      status: status ?? this.status,
      currentInningsIndex: currentInningsIndex ?? this.currentInningsIndex,
      innings: innings ?? this.innings,
      events: events ?? this.events,
      result: clearResult ? null : result ?? this.result,
      awards: awards ?? this.awards,
      bowlingSegments: bowlingSegments ?? this.bowlingSegments,
      bowlerReplacementEvents:
          bowlerReplacementEvents ?? this.bowlerReplacementEvents,
      suspendedBowlerIds: suspendedBowlerIds ?? this.suspendedBowlerIds,
      teamRoleSnapshots: teamRoleSnapshots ?? this.teamRoleSnapshots,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      startedAt: startedAt ?? this.startedAt,
      createdAt: createdAt ?? this.createdAt,
      venueName: venueName ?? this.venueName,
      matchTimeZone: matchTimeZone ?? this.matchTimeZone,
      manualEndOutcome:
          clearManualEnd ? null : manualEndOutcome ?? this.manualEndOutcome,
      endReasonCode:
          clearManualEnd ? null : endReasonCode ?? this.endReasonCode,
      endReasonText:
          clearManualEnd ? null : endReasonText ?? this.endReasonText,
      endNote: clearManualEnd ? null : endNote ?? this.endNote,
      endedManually:
          clearManualEnd ? false : endedManually ?? this.endedManually,
      endedAt: clearManualEnd ? null : endedAt ?? this.endedAt,
      endedBy: clearManualEnd ? null : endedBy ?? this.endedBy,
      loserTeamId: clearManualEnd ? null : loserTeamId ?? this.loserTeamId,
      resultType: clearManualEnd ? null : resultType ?? this.resultType,
      manualResultText:
          clearManualEnd ? null : manualResultText ?? this.manualResultText,
      statusBeforeManualEnd: clearManualEnd
          ? null
          : statusBeforeManualEnd ?? this.statusBeforeManualEnd,
    );
  }

  Map<String, dynamic> toJson() => {
        'matchId': matchId,
        'config': config.toJson(),
        'teamA': teamA.toJson(),
        'teamB': teamB.toJson(),
        'tossWinnerTeamId': tossWinnerTeamId,
        'tossDecision': tossDecision,
        'status': status.name,
        'currentInningsIndex': currentInningsIndex,
        'innings': innings.map((item) => item.toJson()).toList(),
        'events': events.map((item) => item.toJson()).toList(),
        'result': result?.toJson(),
        'awards': awards.map((award) => award.toJson()).toList(),
        'bowlingSegments':
            bowlingSegments.map((item) => item.toJson()).toList(),
        'bowlerReplacementEvents':
            bowlerReplacementEvents.map((item) => item.toJson()).toList(),
        'suspendedBowlerIds': suspendedBowlerIds,
        'teamRoleSnapshots':
            teamRoleSnapshots.map((item) => item.toJson()).toList(),
        'scheduledAt': scheduledAt,
        'startedAt': startedAt,
        'createdAt': createdAt,
        'venueName': venueName,
        'matchTimeZone': matchTimeZone,
        'manualEndOutcome': manualEndOutcome?.name,
        'endReasonCode': endReasonCode?.name,
        'endReasonText': endReasonText,
        'endNote': endNote,
        'endedManually': endedManually,
        'endedAt': endedAt,
        'endedBy': endedBy,
        'loserTeamId': loserTeamId,
        'resultType': resultType,
        'manualResultText': manualResultText,
        'statusBeforeManualEnd': statusBeforeManualEnd?.name,
      };

  factory MatchState.fromJson(Map<String, dynamic> json) => MatchState(
        matchId: json['matchId'] as String,
        config: MatchConfig.fromJson(json['config'] as Map<String, dynamic>),
        teamA: Team.fromJson(json['teamA'] as Map<String, dynamic>),
        teamB: Team.fromJson(json['teamB'] as Map<String, dynamic>),
        tossWinnerTeamId: json['tossWinnerTeamId'] as String,
        tossDecision: json['tossDecision'] as String,
        status: MatchStatus.values.firstWhere(
          (value) => value.name == json['status'],
          orElse: () => MatchStatus.live,
        ),
        currentInningsIndex: json['currentInningsIndex'] as int? ?? 0,
        innings: (json['innings'] as List<dynamic>)
            .map((item) => InningsState.fromJson(item as Map<String, dynamic>))
            .toList(),
        events: (json['events'] as List<dynamic>? ?? const [])
            .map((item) => DeliveryEvent.fromJson(item as Map<String, dynamic>))
            .toList(),
        result: json['result'] == null
            ? null
            : MatchResult.fromJson(json['result'] as Map<String, dynamic>),
        awards: (json['awards'] as List<dynamic>?)
                ?.map((award) =>
                    MatchAward.fromJson(award as Map<String, dynamic>))
                .toList() ??
            const [],
        bowlingSegments: (json['bowlingSegments'] as List<dynamic>?)
                ?.map((item) =>
                    BowlingSegment.fromJson(item as Map<String, dynamic>))
                .toList() ??
            const [],
        bowlerReplacementEvents:
            (json['bowlerReplacementEvents'] as List<dynamic>?)
                    ?.map((item) => BowlerReplacementEvent.fromJson(
                        item as Map<String, dynamic>))
                    .toList() ??
                const [],
        suspendedBowlerIds:
            (json['suspendedBowlerIds'] as List<dynamic>?)?.cast<String>() ??
                const [],
        teamRoleSnapshots: (json['teamRoleSnapshots'] as List<dynamic>?)
                ?.map((item) => MatchTeamRoleSnapshot.fromJson(
                    item as Map<String, dynamic>))
                .toList() ??
            const [],
        scheduledAt: json['scheduledAt'] as int?,
        startedAt: json['startedAt'] as int?,
        createdAt: json['createdAt'] as int?,
        venueName: json['venueName'] as String?,
        matchTimeZone: json['matchTimeZone'] as String?,
        manualEndOutcome: json['manualEndOutcome'] == null
            ? null
            : MatchEndOutcome.values
                .firstWhere((value) => value.name == json['manualEndOutcome']),
        endReasonCode: json['endReasonCode'] == null
            ? null
            : MatchEndReason.values
                .firstWhere((value) => value.name == json['endReasonCode']),
        endReasonText: json['endReasonText'] as String?,
        endNote: json['endNote'] as String?,
        endedManually: json['endedManually'] as bool? ?? false,
        endedAt: json['endedAt'] as int?,
        endedBy: json['endedBy'] as String?,
        loserTeamId: json['loserTeamId'] as String?,
        resultType: json['resultType'] as String?,
        manualResultText: json['manualResultText'] as String?,
        statusBeforeManualEnd: json['statusBeforeManualEnd'] == null
            ? null
            : MatchStatus.values.firstWhere(
                (value) => value.name == json['statusBeforeManualEnd']),
      );
}
