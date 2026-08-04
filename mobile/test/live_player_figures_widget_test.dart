import 'package:cricket_scoring_engine/cricket_scoring_engine.dart';
import 'package:cricket_scorer/presentation/scoring/widgets/live_player_figures_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const figures = LivePlayerFigures(
  striker: LiveBattingFigures(
    playerId: 'a1',
    playerName: 'Karthick',
    runs: 12,
    ballsFaced: 6,
    isStriker: true,
  ),
  nonStriker: LiveBattingFigures(
    playerId: 'a2',
    playerName: 'Ragu',
    runs: 24,
    ballsFaced: 10,
    isStriker: false,
  ),
  bowler: LiveBowlingFigures(
    playerId: 'b1',
    playerName: 'Arjun',
    legalBalls: 14,
    ballsPerOver: 6,
    maidens: 0,
    runsConceded: 12,
    wickets: 2,
  ),
);

void main() {
  testWidgets('shows match-snapshot roles with the striker marker',
      (tester) async {
    const state = MatchState(
      matchId: 'roles',
      config: MatchConfig(
        format: MatchFormat.custom,
        totalOvers: 1,
        maxOversPerBowler: 1,
      ),
      teamA: Team(id: 'a', name: 'Alpha', shortName: 'A', players: [
        Player(id: 'a1', name: 'Karthick'),
        Player(id: 'a2', name: 'Ragu'),
      ]),
      teamB: Team(id: 'b', name: 'Beta', shortName: 'B', players: [
        Player(id: 'b1', name: 'Arjun'),
      ]),
      tossWinnerTeamId: 'a',
      tossDecision: 'BAT',
      innings: [
        InningsState(
          inningsId: 'i',
          battingTeamId: 'a',
          bowlingTeamId: 'b',
          inningsNumber: 1,
          strikerId: 'a1',
          nonStrikerId: 'a2',
          currentBowlerId: 'b1',
        ),
      ],
      teamRoleSnapshots: [
        MatchTeamRoleSnapshot(teamId: 'a', captainPlayerId: 'a1'),
        MatchTeamRoleSnapshot(
          teamId: 'b',
          captainPlayerId: 'b1',
          wicketkeeperPlayerId: 'b1',
        ),
      ],
    );
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: LivePlayerFiguresPanel(
          figures: figures,
          matchState: state,
          onMorePressed: () {},
        ),
      ),
    ));

    expect(find.text('Karthick (C)*'), findsOneWidget);
    expect(find.text('Arjun (C & WK)'), findsOneWidget);
  });

  testWidgets('shows compact batter and fully labelled bowler figures',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: LivePlayerFiguresPanel(
            figures: figures,
            onMorePressed: () {},
          ),
        ),
      ),
    ));

    expect(find.text('Live Match Info'), findsOneWidget);
    expect(find.text('Karthick*'), findsOneWidget);
    expect(find.text('12 (6)'), findsOneWidget);
    expect(find.text('SR 200.0'), findsOneWidget);
    expect(find.text('Ragu'), findsOneWidget);
    expect(find.text('24 (10)'), findsOneWidget);
    expect(find.text('Arjun'), findsOneWidget);
    expect(find.text('2.2–0–12–2'), findsOneWidget);
    expect(find.text('Eco 5.14'), findsOneWidget);
    expect(find.text('STRIKER'), findsNothing);
    expect(find.byType(Chip), findsNothing);
    expect(
      tester.getSize(find.byKey(const ValueKey('live-players-card'))).height,
      lessThan(210),
    );
  });

  testWidgets('fits a 320 logical-pixel screen with long player names',
      (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: LivePlayerFiguresPanel(
          figures: LivePlayerFigures(
            striker: const LiveBattingFigures(
              playerId: 'a',
              playerName: 'Karthick Rajendran With A Very Long Name',
              runs: 12,
              ballsFaced: 6,
              isStriker: true,
            ),
            nonStriker: figures.nonStriker,
            bowler: figures.bowler,
          ),
          onMorePressed: () {},
        ),
      ),
    ));

    expect(tester.takeException(), isNull);
    expect(find.text('12 (6)'), findsOneWidget);
  });

  testWidgets('provides expanded player semantics', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: LivePlayerFiguresPanel(
          figures: figures,
          onMorePressed: () {},
        ),
      ),
    ));

    expect(
      find.byWidgetPredicate((widget) =>
          widget is Semantics &&
          widget.properties.label ==
              'Karthick, striker, 12 runs from 6 balls.'),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate((widget) =>
          widget is Semantics &&
          widget.properties.label ==
              'Arjun, current bowler, 2 overs and 2 balls, 0 maidens, '
                  '12 runs conceded, 2 wickets, economy 5.14.'),
      findsOneWidget,
    );
    semantics.dispose();
  });
}
