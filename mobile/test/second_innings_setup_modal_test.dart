import 'package:cricket_scorer/presentation/scoring/widgets/second_innings_setup_modal.dart';
import 'package:cricket_scorer/core/theme.dart';
import 'package:cricket_scoring_engine/cricket_scoring_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

MatchState inningsBreakState({bool hasEligibleBowler = true}) => MatchState(
      matchId: 'innings-break-ui',
      config: const MatchConfig(
        format: MatchFormat.custom,
        totalOvers: 2,
        maxOversPerBowler: 1,
        eligibleBowlerIds: ['a1'],
      ),
      teamA: Team(
        id: 'a',
        name: 'Shield11',
        shortName: 'SHI',
        players: [
          Player(
            id: 'a1',
            name: 'Opening Bowler',
            isEligibleBowler: hasEligibleBowler,
            isAvailable: hasEligibleBowler,
          ),
          const Player(
            id: 'a2',
            name: 'Unavailable Bowler',
            isEligibleBowler: false,
          ),
        ],
      ),
      teamB: const Team(
        id: 'b',
        name: 'Victory Kings',
        shortName: 'VK',
        players: [
          Player(id: 'b1', name: 'Batter One'),
          Player(id: 'b2', name: 'Batter Two'),
          Player(id: 'b3', name: 'Batter Three'),
        ],
      ),
      tossWinnerTeamId: 'a',
      tossDecision: 'BAT',
      status: MatchStatus.inningsBreak,
      innings: const [
        InningsState(
          inningsId: 'innings-1',
          battingTeamId: 'a',
          bowlingTeamId: 'b',
          inningsNumber: 1,
          strikerId: 'a1',
          nonStrikerId: 'a2',
          currentBowlerId: 'b1',
          totalRuns: 22,
          totalWickets: 1,
          legalBallsBowled: 12,
          isCompleted: true,
        ),
      ],
    );

Widget testApp(MatchState state) => MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: SecondInningsSetupModal(
          matchState: state,
          onStartSecondInnings: (_, __, ___) {},
          onEndMatch: () {},
          onUndoLastBall: () async => true,
        ),
      ),
    );

void main() {
  testWidgets('premium innings break keeps setup actions visible at 320dp',
      (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(testApp(inningsBreakState()));
    await tester.pumpAndSettle();

    expect(find.text('First Innings Complete'), findsOneWidget);
    expect(find.byKey(const ValueKey('first-innings-summary-card')),
        findsOneWidget);
    expect(find.byKey(const ValueKey('second-innings-target-panel')),
        findsOneWidget);
    expect(find.text('23 Runs'), findsOneWidget);
    expect(find.text('11.50'), findsOneWidget);
    expect(find.byKey(const ValueKey('second-innings-sticky-footer')),
        findsOneWidget);
    expect(find.text('Undo Last Ball'), findsOneWidget);
    expect(find.text('End Match'), findsOneWidget);
    expect(find.byIcon(Icons.undo_rounded), findsOneWidget);
    expect(find.byIcon(Icons.stop_circle_outlined), findsOneWidget);
    expect(find.byIcon(Icons.sports_baseball), findsOneWidget);
    expect(find.text('START SECOND INNINGS'), findsOneWidget);
    expect(tester.takeException(), isNull);

    final undoButton = find.descendant(
      of: find.byKey(const ValueKey('innings-break-undo-last-ball')),
      matching: find.byType(OutlinedButton),
    );
    final endButton = find.descendant(
      of: find.byKey(const ValueKey('innings-break-end-match')),
      matching: find.byType(OutlinedButton),
    );
    expect(tester.getSize(undoButton), tester.getSize(endButton));
    expect(tester.getSize(undoButton).height, AppCtaStyle.height);

    final start = tester.widget<FilledButton>(
      find.byKey(const ValueKey('start-second-innings-button')),
    );
    expect(start.onPressed, isNotNull);
  });

  testWidgets('smart defaults use A-Z batters and an eligible bowler',
      (tester) async {
    await tester.pumpWidget(testApp(inningsBreakState()));

    final striker = tester.widget<DropdownButtonFormField<String>>(
      find.descendant(
        of: find.byKey(const ValueKey('second-innings-opening-batter')),
        matching: find.byType(DropdownButtonFormField<String>),
      ),
    );
    final nonStriker = tester.widget<DropdownButtonFormField<String>>(
      find.descendant(
        of: find.byKey(const ValueKey('second-innings-non-striker')),
        matching: find.byType(DropdownButtonFormField<String>),
      ),
    );
    final bowler = tester.widget<DropdownButtonFormField<String>>(
      find.descendant(
        of: find.byKey(const ValueKey('second-innings-opening-bowler')),
        matching: find.byType(DropdownButtonFormField<String>),
      ),
    );

    expect(striker.initialValue, 'b1');
    expect(nonStriker.initialValue, 'b3');
    expect(bowler.initialValue, 'a1');
  });

  testWidgets('start remains disabled without an available eligible bowler',
      (tester) async {
    await tester
        .pumpWidget(testApp(inningsBreakState(hasEligibleBowler: false)));

    final start = tester.widget<FilledButton>(
      find.byKey(const ValueKey('start-second-innings-button')),
    );
    expect(start.onPressed, isNull);
    expect(find.text('No available eligible bowler can start the innings.'),
        findsOneWidget);
  });
}
