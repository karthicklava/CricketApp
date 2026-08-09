import 'package:cricket_scoring_engine/cricket_scoring_engine.dart';
import 'package:flutter/material.dart';

import '../../../core/theme.dart';

class ResponsiveBattingTable extends StatelessWidget {
  const ResponsiveBattingTable({
    super.key,
    required this.rows,
    required this.didNotBat,
    required this.isCompleted,
    this.displayName,
  });

  final List<BatterScorecard> rows;
  final List<BatterScorecard> didNotBat;
  final bool isCompleted;
  final String Function(String playerId, String playerName)? displayName;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final tablet = constraints.maxWidth >= 600;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ScorecardHeaderRow.batting(tablet: tablet),
              for (final row in rows)
                BattingScorecardRow(
                  row: row,
                  tablet: tablet,
                  playerDisplayName:
                      displayName?.call(row.playerId, row.playerName),
                ),
              if (didNotBat.isNotEmpty)
                DidNotBatRow(
                  players: didNotBat
                      .map((row) =>
                          displayName?.call(
                            row.playerId,
                            row.playerName,
                          ) ??
                          row.playerName)
                      .toList(),
                  label: isCompleted ? 'Did Not Bat' : 'To Bat',
                ),
            ],
          );
        },
      );
}

class ResponsiveBowlingTable extends StatelessWidget {
  const ResponsiveBowlingTable({
    super.key,
    required this.rows,
    this.displayName,
  });

  final List<BowlerScorecard> rows;
  final String Function(String playerId, String playerName)? displayName;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 360;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ScorecardHeaderRow.bowling(compact: compact),
              for (final row in rows)
                BowlingScorecardRow(
                  row: row,
                  compact: compact,
                  playerDisplayName:
                      displayName?.call(row.playerId, row.playerName),
                ),
            ],
          );
        },
      );
}

class ScorecardHeaderRow extends StatelessWidget {
  const ScorecardHeaderRow._(
      {required this.type, this.tablet = false, this.compact = false});

  factory ScorecardHeaderRow.batting({bool tablet = false}) =>
      ScorecardHeaderRow._(type: _TableType.batting, tablet: tablet);

  factory ScorecardHeaderRow.bowling({bool compact = false}) =>
      ScorecardHeaderRow._(type: _TableType.bowling, compact: compact);

  final _TableType type;
  final bool tablet;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final labels = type == _TableType.batting
        ? tablet
            ? const ['Batter', 'Dismissal', 'R', 'B', '4s', '6s', 'SR']
            : const ['Batter', 'R', 'B', '4s', '6s', 'SR']
        : const ['Bowler', 'O', 'M', 'R', 'W', 'Eco'];
    final flexes = type == _TableType.batting
        ? tablet
            ? const [7, 8, 2, 2, 2, 2, 4]
            : const [12, 2, 2, 2, 2, 4]
        : const [10, 2, 2, 2, 2, 4];
    return Container(
      key: ValueKey('${type.name}-scorecard-header'),
      constraints: const BoxConstraints(minHeight: 42),
      padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 12, vertical: 8),
      color: const Color(0xFFF1F5F3),
      child: Row(
        children: [
          for (var index = 0; index < labels.length; index++)
            Expanded(
              flex: flexes[index],
              child: Text(
                labels[index],
                textAlign: index == 0 ? TextAlign.left : TextAlign.center,
                maxLines: 1,
                style: TextStyle(
                  fontSize: compact ? 11 : 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class BattingScorecardRow extends StatelessWidget {
  const BattingScorecardRow(
      {super.key,
      required this.row,
      required this.tablet,
      this.playerDisplayName});

  final BatterScorecard row;
  final bool tablet;
  final String? playerDisplayName;

  @override
  Widget build(BuildContext context) => Semantics(
        container: true,
        label:
            '${playerDisplayName ?? row.playerName}, ${row.runs} runs from ${row.ballsFaced} balls, '
            '${row.fours} fours, ${row.sixes} sixes, strike rate '
            '${row.strikeRate.toStringAsFixed(1)}, ${row.dismissalInfo}.',
        excludeSemantics: true,
        child: Container(
          constraints: const BoxConstraints(minHeight: 64),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFE4E9E7))),
          ),
          child: Row(children: [
            Expanded(
              flex: tablet ? 7 : 12,
              child: _PlayerCell(
                name:
                    '${playerDisplayName ?? row.playerName}${!row.isDismissed ? '*' : ''}',
                detail: tablet ? null : row.dismissalInfo,
              ),
            ),
            if (tablet)
              Expanded(
                flex: 8,
                child: Text(row.dismissalInfo,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
              ),
            _NumberCell('${row.runs}', flex: 2, strong: true),
            _NumberCell('${row.ballsFaced}', flex: 2),
            _NumberCell('${row.fours}', flex: 2),
            _NumberCell('${row.sixes}', flex: 2),
            _NumberCell(row.strikeRate.toStringAsFixed(1), flex: 4),
          ]),
        ),
      );
}

class BowlingScorecardRow extends StatelessWidget {
  const BowlingScorecardRow(
      {super.key,
      required this.row,
      this.compact = false,
      this.playerDisplayName});

  final BowlerScorecard row;
  final bool compact;
  final String? playerDisplayName;

  @override
  Widget build(BuildContext context) => Semantics(
        container: true,
        label:
            '${playerDisplayName ?? row.playerName}, ${row.oversFormatted} overs, ${row.maidens} '
            'maidens, ${row.runsConceded} runs, ${row.wickets} wickets, '
            'economy ${row.economyRate.toStringAsFixed(2)}.',
        excludeSemantics: true,
        child: Container(
          constraints: const BoxConstraints(minHeight: 58),
          padding:
              EdgeInsets.symmetric(horizontal: compact ? 8 : 12, vertical: 9),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFE4E9E7))),
          ),
          child: Row(children: [
            Expanded(
              flex: 10,
              child: _PlayerCell(
                name: playerDisplayName ?? row.playerName,
                detail: 'Wd ${row.wides} · Nb ${row.noBalls}',
              ),
            ),
            _NumberCell(row.oversFormatted, flex: 2),
            _NumberCell('${row.maidens}', flex: 2),
            _NumberCell('${row.runsConceded}', flex: 2),
            _NumberCell('${row.wickets}', flex: 2, strong: true),
            _NumberCell(row.economyRate.toStringAsFixed(2), flex: 4),
          ]),
        ),
      );
}

class DidNotBatRow extends StatelessWidget {
  const DidNotBatRow({super.key, required this.players, required this.label});

  final List<String> players;
  final String label;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
        child: Text.rich(
          TextSpan(children: [
            TextSpan(
                text: '$label: ',
                style: const TextStyle(fontWeight: FontWeight.w700)),
            TextSpan(text: players.join(', ')),
          ]),
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      );
}

class ScorecardSummaryRow extends StatelessWidget {
  const ScorecardSummaryRow({
    super.key,
    required this.label,
    required this.value,
    required this.detail,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final String detail;
  final bool emphasized;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        child: Row(children: [
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label,
                  style: TextStyle(
                      fontSize: emphasized ? 16 : 14,
                      fontWeight:
                          emphasized ? FontWeight.w800 : FontWeight.w700)),
              Text(detail,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary)),
            ]),
          ),
          Text(value,
              style: TextStyle(
                  fontSize: emphasized ? 17 : 15, fontWeight: FontWeight.w800)),
        ]),
      );
}

class InningsScoreHeader extends StatelessWidget {
  const InningsScoreHeader(
      {super.key, required this.title, required this.summary});
  final String title;
  final String summary;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 19,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 3),
          Text(summary, style: const TextStyle(fontSize: 14)),
        ],
      );
}

class _PlayerCell extends StatelessWidget {
  const _PlayerCell({required this.name, this.detail});
  final String name;
  final String? detail;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Tooltip(
            message: name,
            child: Text(name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          ),
          if (detail != null) ...[
            const SizedBox(height: 3),
            Text(detail!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textSecondary)),
          ],
        ],
      );
}

class _NumberCell extends StatelessWidget {
  const _NumberCell(this.value, {required this.flex, this.strong = false});
  final String value;
  final int flex;
  final bool strong;

  @override
  Widget build(BuildContext context) => Expanded(
        flex: flex,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(value,
              maxLines: 1,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: strong ? FontWeight.w800 : FontWeight.w600)),
        ),
      );
}

enum _TableType { batting, bowling }
