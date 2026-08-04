class BowlingRuleConfig {
  final int totalOvers;
  final int maxOversPerBowler;
  final bool wasManuallyEdited;
  final bool allowConsecutiveOvers;

  const BowlingRuleConfig({
    required this.totalOvers,
    required this.maxOversPerBowler,
    required this.wasManuallyEdited,
    required this.allowConsecutiveOvers,
  });

  static int suggestOfficialMaxOversPerBowler(int totalOvers) =>
      (totalOvers / 5).ceil().clamp(1, totalOvers);

  BowlingRuleConfig withTotalOvers(int value) {
    final manualValueIsValid = wasManuallyEdited &&
        maxOversPerBowler >= 1 &&
        maxOversPerBowler <= value;
    return BowlingRuleConfig(
      totalOvers: value,
      maxOversPerBowler: manualValueIsValid
          ? maxOversPerBowler
          : suggestOfficialMaxOversPerBowler(value),
      wasManuallyEdited: manualValueIsValid,
      allowConsecutiveOvers: allowConsecutiveOvers,
    );
  }
}
