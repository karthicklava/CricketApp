import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cricket_scorer/presentation/common/widgets/live_match_header.dart';

Widget _host(Widget child, {double width = 360}) => MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(width: width, child: child),
        ),
      ),
    );

LiveMatchSummaryCard _card({
  LiveMatchCardVariant variant = LiveMatchCardVariant.homeFeatured,
  bool chase = false,
  bool completed = false,
  MatchConnectionState connection = MatchConnectionState.online,
}) =>
    LiveMatchSummaryCard(
      battingTeamName: 'SHI',
      bowlingTeamName: 'VK',
      inningsNumber: chase ? 2 : 1,
      score: completed ? '47/1' : '0/0',
      overs: completed ? '2.5' : '0.0',
      totalOvers: 3,
      currentRunRate: 0,
      requiredRunRate: chase ? 11 : null,
      target: chase ? 22 : null,
      runsRequired: chase ? 22 : null,
      ballsRemaining: chase ? 12 : null,
      variant: variant,
      connectionState: connection,
      isCompleted: completed,
      resultText: completed ? 'SHI won by 9 wickets' : null,
      darkSurface: false,
    );

void main() {
  testWidgets(
      'live status uses a red badge with right-aligned innings metadata',
      (tester) async {
    await tester.pumpWidget(_host(_card()));
    await tester.pump(const Duration(milliseconds: 900));

    expect(find.byType(LiveMatchStatusBadge), findsOneWidget);
    expect(find.text('LIVE MATCH'), findsOneWidget);
    final badge = tester.widget<Container>(
      find.byKey(const ValueKey('live-match-status-badge')),
    );
    final decoration = badge.decoration! as BoxDecoration;
    expect(decoration.color, const Color(0xFFE53935));
    final rowRight = tester
        .getTopRight(find.byKey(const ValueKey('live-summary-header-row')))
        .dx;
    final metadataRight = tester
        .getTopRight(find.byKey(const ValueKey('live-summary-header-meta')))
        .dx;
    expect(metadataRight, rowRight);
  });

  testWidgets('first innings hides chase metrics', (tester) async {
    await tester.pumpWidget(_host(_card()));
    expect(find.text('SHI batting'), findsOneWidget);
    expect(find.textContaining('Need'), findsNothing);
    expect(find.textContaining('RRR'), findsNothing);
  });

  testWidgets('second innings groups chase and run rates', (tester) async {
    await tester.pumpWidget(_host(_card(chase: true)));
    expect(find.text('Need 22 runs from 12 balls'), findsOneWidget);
    expect(find.text('Target 22'), findsOneWidget);
    expect(find.text('CRR 0.00'), findsOneWidget);
    expect(find.text('RRR 11.00'), findsOneWidget);
  });

  testWidgets('completed state hides live chase information', (tester) async {
    await tester.pumpWidget(_host(_card(chase: true, completed: true)));
    expect(find.text('COMPLETED'), findsOneWidget);
    expect(find.text('SHI won by 9 wickets'), findsOneWidget);
    expect(find.textContaining('Need'), findsNothing);
    expect(find.textContaining('RRR'), findsNothing);
  });

  testWidgets('history variant is shorter than featured variant',
      (tester) async {
    await tester.pumpWidget(_host(Column(children: [
      KeyedSubtree(key: const Key('featured'), child: _card(chase: true)),
      KeyedSubtree(
          key: const Key('compact'),
          child:
              _card(chase: true, variant: LiveMatchCardVariant.historyCompact)),
    ])));
    expect(tester.getSize(find.byKey(const Key('compact'))).height,
        lessThan(tester.getSize(find.byKey(const Key('featured'))).height));
  });

  testWidgets('narrow offline card does not overflow', (tester) async {
    await tester.pumpWidget(_host(
      _card(chase: true, connection: MatchConnectionState.savedOffline),
      width: 320,
    ));
    expect(find.text('Saved offline'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('team score and CRR share the left alignment grid',
      (tester) async {
    await tester.pumpWidget(_host(_card()));
    final teamLeft = tester
        .getTopLeft(
          find.byKey(const ValueKey('live-summary-batting-team')),
        )
        .dx;
    final scoreLeft = tester
        .getTopLeft(
          find.byKey(const ValueKey('live-summary-score-0/0')),
        )
        .dx;
    final crrLeft = tester
        .getTopLeft(
          find.byKey(const ValueKey('live-summary-crr')),
        )
        .dx;
    expect(scoreLeft, teamLeft);
    expect(crrLeft, teamLeft);
  });

  testWidgets('overs remains anchored to the right edge after score updates',
      (tester) async {
    await tester.pumpWidget(_host(_card()));
    final initialRight = tester
        .getTopRight(
          find.byKey(const ValueKey('live-summary-overs')),
        )
        .dx;

    await tester.pumpWidget(_host(LiveMatchSummaryCard(
      battingTeamName: 'A VERY LONG BATTING TEAM NAME',
      bowlingTeamName: 'VK',
      inningsNumber: 1,
      score: '123/10',
      overs: '19.5',
      totalOvers: 20,
      currentRunRate: 6.2,
      variant: LiveMatchCardVariant.homeFeatured,
      darkSurface: false,
    )));
    await tester.pump(const Duration(milliseconds: 90));
    final updatedRight = tester
        .getTopRight(
          find.byKey(const ValueKey('live-summary-overs')),
        )
        .dx;
    expect(updatedRight, initialRight);
    expect(tester.takeException(), isNull);
  });
}
