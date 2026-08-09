import 'package:cricket_scoring_engine/cricket_scoring_engine.dart';

/// Returns a deterministic presentation-order copy without mutating [players].
List<T> sortPlayerItemsByName<T>(
  Iterable<T> players, {
  required String Function(T player) nameOf,
  required String Function(T player) idOf,
  String? Function(T player)? jerseyNumberOf,
}) {
  final sorted = players.toList();
  sorted.sort((a, b) {
    final nameComparison = nameOf(a)
        .trim()
        .toLowerCase()
        .compareTo(nameOf(b).trim().toLowerCase());
    if (nameComparison != 0) return nameComparison;

    if (jerseyNumberOf != null) {
      final jerseyComparison = _compareJerseyNumbers(
        jerseyNumberOf(a),
        jerseyNumberOf(b),
      );
      if (jerseyComparison != 0) return jerseyComparison;
    }

    return idOf(a).compareTo(idOf(b));
  });
  return sorted;
}

List<Player> sortPlayersByName(Iterable<Player> players) =>
    sortPlayerItemsByName(
      players,
      nameOf: (player) => player.name,
      idOf: (player) => player.id,
    );

int comparePlayersByName(Player first, Player second) {
  final nameComparison = first.name
      .trim()
      .toLowerCase()
      .compareTo(second.name.trim().toLowerCase());
  return nameComparison != 0 ? nameComparison : first.id.compareTo(second.id);
}

int _compareJerseyNumbers(String? first, String? second) {
  final firstValue = int.tryParse(first?.trim() ?? '');
  final secondValue = int.tryParse(second?.trim() ?? '');
  if (firstValue != null && secondValue != null) {
    return firstValue.compareTo(secondValue);
  }
  if (firstValue != null) return -1;
  if (secondValue != null) return 1;
  return (first?.trim().toLowerCase() ?? '')
      .compareTo(second?.trim().toLowerCase() ?? '');
}
