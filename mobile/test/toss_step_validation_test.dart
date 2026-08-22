import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cricket_scorer/data/local/database.dart';
import 'package:cricket_scorer/presentation/matches/widgets/digital_coin_toss_widget.dart';

void main() {
  testWidgets('DigitalCoinTossWidget callback is fired only when toss is completed', (tester) async {
    DigitalCoinTossResult? tossResult;
    bool confirmTossCalled = false;
    bool tossResetCalled = false;

    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DigitalCoinTossWidget(
            teamAId: 'team_a',
            teamAName: 'Team Alpha',
            teamBId: 'team_b',
            teamBName: 'Team Beta',
            onTossCompleted: (result) {
              tossResult = result;
            },
            onTossReset: () {
              tossResetCalled = true;
              tossResult = null;
            },
            onConfirmToss: () {
              confirmTossCalled = true;
            },
          ),
        ),
      ),
    );

    // Initial State: "WHO WILL CALL?"
    expect(find.text('WHO WILL CALL?'), findsOneWidget);
    expect(tossResult, isNull);

    // Select Team Alpha as calling team
    await tester.tap(find.text('Team Alpha'));
    await tester.pumpAndSettle();

    // Stage 2 State: "CHOOSE YOUR CALL"
    expect(find.text('CHOOSE YOUR CALL'), findsOneWidget);
    expect(tossResult, isNull);

    // Select HEADS
    await tester.tap(find.text('HEADS'));
    await tester.pumpAndSettle();

    // Stage 3 State: "FLIP THE COIN"
    expect(find.text('FLIP THE COIN'), findsOneWidget);
    expect(tossResult, isNull);

    // Execute Coin Flip
    await tester.tap(find.text('FLIP THE COIN'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 1400));
    await tester.pumpAndSettle();

    // Toss completed and winner determined
    expect(tossResult, isNotNull);
    expect(tossResult!.tossCallingTeamId, 'team_a');
    expect(tossResult!.tossCall, 'HEADS');

    // Tap Re-Toss
    await tester.ensureVisible(find.text('Re-Toss'));
    await tester.tap(find.text('Re-Toss'));
    await tester.pumpAndSettle();

    // Confirm Re-Toss in bottom sheet
    await tester.tap(find.widgetWithText(FilledButton, 'Re-Toss'));
    await tester.pumpAndSettle();

    // Must reset toss state and fire onTossReset
    expect(tossResetCalled, isTrue);
    expect(tossResult, isNull);
    expect(find.text('WHO WILL CALL?'), findsOneWidget);
  });
}
