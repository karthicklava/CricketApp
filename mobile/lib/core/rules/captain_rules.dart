class CaptainRules {
  const CaptainRules._();

  static Map<String, bool> selectSingleCaptain({
    required Iterable<String> teamPlayerIds,
    required String selectedCaptainId,
  }) {
    final ids = teamPlayerIds.toSet();
    if (!ids.contains(selectedCaptainId)) {
      throw ArgumentError('Captain must belong to the selected team.');
    }
    return {
      for (final id in ids) id: id == selectedCaptainId,
    };
  }

  static String? normalizeLegacyCaptains({
    required Iterable<String> squadPlayerIds,
    required Iterable<String> captainIds,
  }) {
    final squad = squadPlayerIds.toSet();
    for (final captainId in captainIds) {
      if (squad.contains(captainId)) return captainId;
    }
    return null;
  }

  static bool isValidMatchCaptain({
    required String? captainId,
    required Set<String> playingSquadIds,
  }) =>
      captainId != null && playingSquadIds.contains(captainId);
}
