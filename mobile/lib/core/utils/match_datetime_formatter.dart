import 'package:cricket_scoring_engine/cricket_scoring_engine.dart';

enum MatchTimeSource { started, scheduled, created }

class MatchTimestampSummary {
  final DateTime matchDateTime;
  final MatchTimeSource source;
  final DateTime? endedDateTime;
  final DateTime generatedDateTime;
  final String timeZoneLabel;
  final bool hasPersistedMatchTime;

  const MatchTimestampSummary({
    required this.matchDateTime,
    required this.source,
    required this.endedDateTime,
    required this.generatedDateTime,
    required this.timeZoneLabel,
    required this.hasPersistedMatchTime,
  });
}

class MatchDateTimeFormatter {
  const MatchDateTimeFormatter._();

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static MatchTimestampSummary summary(
    MatchState state, {
    DateTime? generatedAt,
  }) {
    final source = state.startedAt != null
        ? MatchTimeSource.started
        : state.scheduledAt != null
            ? MatchTimeSource.scheduled
            : MatchTimeSource.created;
    final persistedMillis =
        state.startedAt ?? state.scheduledAt ?? state.createdAt;
    final millis = persistedMillis ?? 0;
    final matchDateTime = _local(millis);
    return MatchTimestampSummary(
      matchDateTime: matchDateTime,
      source: source,
      endedDateTime: state.endedAt == null ? null : _local(state.endedAt!),
      generatedDateTime: (generatedAt ?? DateTime.now()).toLocal(),
      timeZoneLabel: state.matchTimeZone?.trim().isNotEmpty == true
          ? state.matchTimeZone!.trim()
          : matchDateTime.timeZoneName,
      hasPersistedMatchTime: persistedMillis != null,
    );
  }

  static DateTime _local(int milliseconds) =>
      DateTime.fromMillisecondsSinceEpoch(milliseconds, isUtc: true).toLocal();

  static String date(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')} ${_months[value.month - 1]} ${value.year}';

  static String time(DateTime value) {
    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final minute = value.minute.toString().padLeft(2, '0');
    return '${hour.toString().padLeft(2, '0')}:$minute ${value.hour < 12 ? 'AM' : 'PM'}';
  }

  static String dateTime(DateTime value) => '${date(value)}, ${time(value)}';

  static List<String> pdfLines(MatchState state, MatchTimestampSummary value) {
    if (!value.hasPersistedMatchTime) {
      return [
        'Match timestamp unavailable',
        if (state.venueName?.trim().isNotEmpty == true)
          'Venue: ${state.venueName!.trim()}',
      ];
    }
    final lines = <String>['Match Date: ${date(value.matchDateTime)}'];
    switch (value.source) {
      case MatchTimeSource.started:
        lines.add('Start Time: ${time(value.matchDateTime)}');
        break;
      case MatchTimeSource.scheduled:
        lines.add('Scheduled: ${dateTime(value.matchDateTime)}');
        break;
      case MatchTimeSource.created:
        lines.add('Match record created: ${dateTime(value.matchDateTime)}');
        break;
    }
    if (value.endedDateTime != null) {
      final label =
          state.status == MatchStatus.completed ? 'End Time' : 'Ended';
      lines.add('$label: ${time(value.endedDateTime!)}');
    }
    if (state.venueName?.trim().isNotEmpty == true) {
      lines.add('Venue: ${state.venueName!.trim()}');
    }
    lines.add('Local time: ${value.timeZoneLabel}');
    return lines;
  }
}
