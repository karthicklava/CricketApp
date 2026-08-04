import 'package:meta/meta.dart';

enum MatchFormat { t10, t20, fiftyOvers, testMatch, custom }

enum BowlerLimitMode {
  localAutomatic,
  officialFormat,
  customEqualLimit,
  customPerBowler,
  unlimited,
}

@immutable
class LatePlayerRules {
  final bool allowLatePlayers;
  final bool allowLateBatters;
  final bool allowLateBowlers;
  final bool allowPermanentTeamAddition;
  final int? maximumSquadSize;

  const LatePlayerRules({
    this.allowLatePlayers = true,
    this.allowLateBatters = true,
    this.allowLateBowlers = true,
    this.allowPermanentTeamAddition = true,
    this.maximumSquadSize,
  });

  Map<String, dynamic> toJson() => {
        'allowLatePlayers': allowLatePlayers,
        'allowLateBatters': allowLateBatters,
        'allowLateBowlers': allowLateBowlers,
        'allowPermanentTeamAddition': allowPermanentTeamAddition,
        'maximumSquadSize': maximumSquadSize,
      };

  factory LatePlayerRules.fromJson(Map<String, dynamic>? json) =>
      LatePlayerRules(
        allowLatePlayers: json?['allowLatePlayers'] as bool? ?? true,
        allowLateBatters: json?['allowLateBatters'] as bool? ?? true,
        allowLateBowlers: json?['allowLateBowlers'] as bool? ?? true,
        allowPermanentTeamAddition:
            json?['allowPermanentTeamAddition'] as bool? ?? true,
        maximumSquadSize: json?['maximumSquadSize'] as int?,
      );
}

@immutable
class MatchConfig {
  final MatchFormat format;
  final int totalOvers;
  final int ballsPerOver;
  final int maxOversPerBowler;
  final BowlerLimitMode bowlerLimitMode;
  final List<String> eligibleBowlerIds;
  final Map<String, int> perBowlerMaxOvers;
  final Map<String, int> perBowlerMaximumLegalBalls;
  final int? bowlingRulesConfirmedAt;
  final int wideRuns;
  final int noBallRuns;
  final bool reballOnWide;
  final bool reballOnNoBall;
  final bool freeHitOnNoBall;
  final bool legByesEnabled;
  final bool byesEnabled;

  /// Legacy import field. Live innings use their persisted squad snapshot.
  @Deprecated('Use InningsState.maximumWickets')
  final int? maxWickets;
  final bool allowConsecutiveOvers;
  final bool allowMidOverBowlerReplacement;
  final bool allowTacticalMidOverReplacement;
  final List<int> powerplayOvers;
  final LatePlayerRules latePlayerRules;

  const MatchConfig({
    required this.format,
    required this.totalOvers,
    this.ballsPerOver = 6,
    required this.maxOversPerBowler,
    this.bowlerLimitMode = BowlerLimitMode.localAutomatic,
    this.eligibleBowlerIds = const [],
    this.perBowlerMaxOvers = const {},
    this.perBowlerMaximumLegalBalls = const {},
    this.bowlingRulesConfirmedAt,
    this.wideRuns = 1,
    this.noBallRuns = 1,
    this.reballOnWide = true,
    this.reballOnNoBall = true,
    this.freeHitOnNoBall = true,
    this.legByesEnabled = true,
    this.byesEnabled = true,
    this.maxWickets,
    this.allowConsecutiveOvers = false,
    this.allowMidOverBowlerReplacement = true,
    this.allowTacticalMidOverReplacement = false,
    this.powerplayOvers = const [],
    this.latePlayerRules = const LatePlayerRules(),
  });

  bool isBowlerConfigured(String playerId) =>
      eligibleBowlerIds.isEmpty || eligibleBowlerIds.contains(playerId);

  /// Null means unlimited. Limits are persisted in legal balls so custom
  /// balls-per-over matches and mid-over replacements remain exact.
  int? maximumLegalBallsFor(String playerId) {
    if (bowlerLimitMode == BowlerLimitMode.unlimited) return null;
    final explicitBalls = perBowlerMaximumLegalBalls[playerId];
    if (explicitBalls != null) return explicitBalls;
    final overs = bowlerLimitMode == BowlerLimitMode.customPerBowler
        ? (perBowlerMaxOvers[playerId] ?? maxOversPerBowler)
        : maxOversPerBowler;
    return overs * ballsPerOver;
  }

  factory MatchConfig.t20() {
    return const MatchConfig(
      format: MatchFormat.t20,
      totalOvers: 20,
      ballsPerOver: 6,
      maxOversPerBowler: 4,
      bowlerLimitMode: BowlerLimitMode.officialFormat,
      wideRuns: 1,
      noBallRuns: 1,
      reballOnWide: true,
      reballOnNoBall: true,
      freeHitOnNoBall: true,
      legByesEnabled: true,
      byesEnabled: true,
      powerplayOvers: [6],
    );
  }

  factory MatchConfig.t10() {
    return const MatchConfig(
      format: MatchFormat.t10,
      totalOvers: 10,
      ballsPerOver: 6,
      maxOversPerBowler: 2,
      bowlerLimitMode: BowlerLimitMode.officialFormat,
      wideRuns: 1,
      noBallRuns: 1,
      reballOnWide: true,
      reballOnNoBall: true,
      freeHitOnNoBall: true,
      legByesEnabled: true,
      byesEnabled: true,
      powerplayOvers: [3],
    );
  }

  factory MatchConfig.fiftyOvers() {
    return const MatchConfig(
      format: MatchFormat.fiftyOvers,
      totalOvers: 50,
      ballsPerOver: 6,
      maxOversPerBowler: 10,
      bowlerLimitMode: BowlerLimitMode.officialFormat,
      wideRuns: 1,
      noBallRuns: 1,
      reballOnWide: true,
      reballOnNoBall: true,
      freeHitOnNoBall: true,
      legByesEnabled: true,
      byesEnabled: true,
      powerplayOvers: [10, 40, 50],
    );
  }

  Map<String, dynamic> toJson() => {
        'format': format.name,
        'totalOvers': totalOvers,
        'ballsPerOver': ballsPerOver,
        'maxOversPerBowler': maxOversPerBowler,
        'bowlerLimitMode': bowlerLimitMode.name,
        'eligibleBowlerIds': eligibleBowlerIds,
        'perBowlerMaxOvers': perBowlerMaxOvers,
        'perBowlerMaximumLegalBalls': perBowlerMaximumLegalBalls,
        'bowlingRulesConfirmedAt': bowlingRulesConfirmedAt,
        'wideRuns': wideRuns,
        'noBallRuns': noBallRuns,
        'reballOnWide': reballOnWide,
        'reballOnNoBall': reballOnNoBall,
        'freeHitOnNoBall': freeHitOnNoBall,
        'legByesEnabled': legByesEnabled,
        'byesEnabled': byesEnabled,
        'maxWickets': maxWickets,
        'allowConsecutiveOvers': allowConsecutiveOvers,
        'allowMidOverBowlerReplacement': allowMidOverBowlerReplacement,
        'allowTacticalMidOverReplacement': allowTacticalMidOverReplacement,
        'powerplayOvers': powerplayOvers,
        'latePlayerRules': latePlayerRules.toJson(),
      };

  factory MatchConfig.fromJson(Map<String, dynamic> json) {
    return MatchConfig(
      format: MatchFormat.values.firstWhere(
        (e) => e.name == json['format'],
        orElse: () => MatchFormat.t20,
      ),
      totalOvers: json['totalOvers'] as int? ?? 20,
      ballsPerOver: json['ballsPerOver'] as int? ?? 6,
      maxOversPerBowler: json['maxOversPerBowler'] as int? ?? 4,
      bowlerLimitMode: BowlerLimitMode.values.firstWhere(
        (value) => value.name == json['bowlerLimitMode'],
        orElse: () => BowlerLimitMode.localAutomatic,
      ),
      eligibleBowlerIds: (json['eligibleBowlerIds'] as List<dynamic>?)
              ?.map((value) => value as String)
              .toList() ??
          const [],
      perBowlerMaxOvers:
          Map<String, int>.from(json['perBowlerMaxOvers'] as Map? ?? const {}),
      perBowlerMaximumLegalBalls: Map<String, int>.from(
          json['perBowlerMaximumLegalBalls'] as Map? ?? const {}),
      bowlingRulesConfirmedAt: json['bowlingRulesConfirmedAt'] as int?,
      wideRuns: json['wideRuns'] as int? ?? 1,
      noBallRuns: json['noBallRuns'] as int? ?? 1,
      reballOnWide: json['reballOnWide'] as bool? ?? true,
      reballOnNoBall: json['reballOnNoBall'] as bool? ?? true,
      freeHitOnNoBall: json['freeHitOnNoBall'] as bool? ?? true,
      legByesEnabled: json['legByesEnabled'] as bool? ?? true,
      byesEnabled: json['byesEnabled'] as bool? ?? true,
      maxWickets: json['maxWickets'] as int?,
      allowConsecutiveOvers: json['allowConsecutiveOvers'] as bool? ?? false,
      allowMidOverBowlerReplacement:
          json['allowMidOverBowlerReplacement'] as bool? ?? true,
      allowTacticalMidOverReplacement:
          json['allowTacticalMidOverReplacement'] as bool? ?? false,
      powerplayOvers: (json['powerplayOvers'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          const [],
      latePlayerRules: LatePlayerRules.fromJson(
        json['latePlayerRules'] as Map<String, dynamic>?,
      ),
    );
  }
}
