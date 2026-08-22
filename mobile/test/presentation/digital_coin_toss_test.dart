import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cricket_scoring_engine/cricket_scoring_engine.dart';
import 'package:cricket_scorer/presentation/matches/widgets/digital_coin_toss_widget.dart';
import 'package:cricket_scorer/presentation/matches/widgets/turfscore_coin_widget.dart';

void main() {
  const teamAId = 'team_a_123';
  const teamAName = 'Shield11';
  const teamBId = 'team_b_456';
  const teamBName = 'Rag Kings';

  group('DigitalCoinTossWidget Tests', () {
    testWidgets('renders initial Who Will Call state', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DigitalCoinTossWidget(
              teamAId: teamAId,
              teamAName: teamAName,
              teamBId: teamBId,
              teamBName: teamBName,
            ),
          ),
        ),
      );

      expect(find.text('WHO WILL CALL?'), findsOneWidget);
      expect(find.text(teamAName), findsOneWidget);
      expect(find.text(teamBName), findsOneWidget);
    });

    testWidgets('transitions to Choose Your Call when team selected', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DigitalCoinTossWidget(
              teamAId: teamAId,
              teamAName: teamAName,
              teamBId: teamBId,
              teamBName: teamBName,
            ),
          ),
        ),
      );

      await tester.tap(find.text(teamAName));
      await tester.pumpAndSettle();

      expect(find.text('CHOOSE YOUR CALL'), findsOneWidget);
      expect(find.text('HEADS'), findsOneWidget);
      expect(find.text('TAILS'), findsOneWidget);
    });

    testWidgets('displays interactive coin when call is selected', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DigitalCoinTossWidget(
              teamAId: teamAId,
              teamAName: teamAName,
              teamBId: teamBId,
              teamBName: teamBName,
            ),
          ),
        ),
      );

      // Select Calling Team
      await tester.tap(find.text(teamAName));
      await tester.pumpAndSettle();

      // Select Call
      await tester.tap(find.text('HEADS'));
      await tester.pumpAndSettle();

      expect(find.text('FLIP THE COIN'), findsOneWidget);
      expect(find.byType(TurfScoreCoinWidget), findsOneWidget);
    });

    testWidgets('flips coin, completes toss and allows BAT/BOWL decision', (WidgetTester tester) async {
      DigitalCoinTossResult? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DigitalCoinTossWidget(
              teamAId: teamAId,
              teamAName: teamAName,
              teamBId: teamBId,
              teamBName: teamBName,
              onTossCompleted: (r) => result = r,
            ),
          ),
        ),
      );

      // Step 1: Select Team
      await tester.tap(find.text(teamAName));
      await tester.pumpAndSettle();

      // Step 2: Select HEADS
      await tester.tap(find.text('HEADS'));
      await tester.pumpAndSettle();

      // Step 3: Tap Flip Button
      await tester.tap(find.text('FLIP THE COIN'));
      await tester.pump(); // Start animation

      // Fast forward flip animation (1.3s)
      await tester.pump(const Duration(milliseconds: 1400));
      await tester.pumpAndSettle();

      expect(find.textContaining('WON THE TOSS'), findsOneWidget);
      expect(find.text('🏏 BAT'), findsOneWidget);
      expect(find.text('🎯 BOWL'), findsOneWidget);
      expect(result, isNotNull);
      expect(result!.tossCallingTeamId, equals(teamAId));
      expect(result!.tossCall, equals('HEADS'));
      expect(result!.coinResult, isNotNull);
      expect(result!.tossWinnerTeamId, isNotEmpty);
    });

    testWidgets('re-toss button prompts dialog and resets toss state', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DigitalCoinTossWidget(
              teamAId: teamAId,
              teamAName: teamAName,
              teamBId: teamBId,
              teamBName: teamBName,
              initialCallingTeamId: teamAId,
              initialTossCall: 'HEADS',
              initialCoinResult: 'HEADS',
              initialTossWinnerId: teamAId,
              initialTossDecision: 'BAT',
            ),
          ),
        ),
      );

      expect(find.text('Re-Toss'), findsOneWidget);

      // Scroll to & tap Re-Toss
      await tester.ensureVisible(find.text('Re-Toss'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Re-Toss'));
      await tester.pumpAndSettle();

      // Verify Confirmation Dialog appears
      expect(find.text('Re-Toss Coin?'), findsOneWidget);
      expect(find.textContaining('Are you sure you want to re-toss?'), findsOneWidget);

      // Tap Re-Toss bottom sheet button
      await tester.tap(find.widgetWithText(FilledButton, 'Re-Toss'));
      await tester.pumpAndSettle();

      // Verify reset back to Who Will Call state
      expect(find.text('WHO WILL CALL?'), findsOneWidget);
    });
  });

  group('MatchState Digital Toss Serialization', () {
    test('serializes and deserializes digital toss fields correctly', () {
      final teamA = Team(id: 'a', name: 'Team A', shortName: 'TMA', players: const []);
      final teamB = Team(id: 'b', name: 'Team B', shortName: 'TMB', players: const []);
      final state = MatchState(
        matchId: 'm1',
        config: const MatchConfig(format: MatchFormat.t20, totalOvers: 20, maxOversPerBowler: 4),
        teamA: teamA,
        teamB: teamB,
        tossWinnerTeamId: 'a',
        tossDecision: 'BAT',
        tossCallingTeamId: 'a',
        tossCall: 'HEADS',
        coinResult: 'HEADS',
        innings: const [],
      );

      final json = state.toJson();
      expect(json['tossCallingTeamId'], equals('a'));
      expect(json['tossCall'], equals('HEADS'));
      expect(json['coinResult'], equals('HEADS'));

      final restored = MatchState.fromJson(json);
      expect(restored.tossCallingTeamId, equals('a'));
      expect(restored.tossCall, equals('HEADS'));
      expect(restored.coinResult, equals('HEADS'));
    });
  });
}
