import 'package:cricket_scoring_engine/cricket_scoring_engine.dart';
import 'package:cricket_scorer/presentation/scoring/widgets/next_batter_selection_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('next-batter selection blocks dismissal until confirmation',
      (tester) async {
    String? selectedId;
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        return Scaffold(
          body: ElevatedButton(
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              isDismissible: false,
              enableDrag: false,
              builder: (_) => NextBatterSelectionBottomSheet(
                eligibleBatters: const [Player(id: 'a3', name: 'A3')],
                onConfirmed: (playerId) async {
                  selectedId = playerId;
                  return true;
                },
              ),
            ),
            child: const Text('Open'),
          ),
        );
      }),
    ));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(4, 4));
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('SELECT NEXT BATTER'), findsOneWidget);

    await tester.tap(find.byType(RadioListTile<String>));
    await tester.pump();
    await tester.tap(find.text('CONFIRM BATTER'));
    await tester.pumpAndSettle();
    expect(selectedId, 'a3');
    expect(find.text('SELECT NEXT BATTER'), findsNothing);
  });

  testWidgets('next-batter transition exposes undo last ball', (tester) async {
    var undone = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: NextBatterSelectionBottomSheet(
          eligibleBatters: const [Player(id: 'a3', name: 'A3')],
          onConfirmed: (_) async => true,
          onUndoLastBall: () async {
            undone = true;
            return true;
          },
        ),
      ),
    ));

    expect(find.text('UNDO LAST BALL'), findsOneWidget);
    await tester.tap(find.text('UNDO LAST BALL'));
    await tester.pump();
    expect(undone, isTrue);
  });

  testWidgets('long batter list keeps confirm action visible on small screens',
      (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final batters = List.generate(
      20,
      (index) => Player(id: 'p$index', name: 'Player ${index + 1}'),
    );
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: NextBatterSelectionBottomSheet(
          eligibleBatters: batters,
          onConfirmed: (_) async => true,
          onUndoLastBall: () async => true,
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('next-batter-scrollable-list')),
        findsOneWidget);
    expect(find.byKey(const ValueKey('next-batter-sticky-footer')),
        findsOneWidget);
    expect(find.text('CONFIRM BATTER'), findsOneWidget);
    expect(tester.takeException(), isNull);

    final confirmButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'CONFIRM BATTER'),
    );
    expect(confirmButton.onPressed, isNull);

    await tester.tap(find.text('Player 1'));
    await tester.pump();
    final enabledButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'CONFIRM BATTER'),
    );
    expect(enabledButton.onPressed, isNotNull);
  });

  testWidgets('search filters the independently scrollable batter list',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: NextBatterSelectionBottomSheet(
          eligibleBatters: const [
            Player(id: 'a3', name: 'Karthick'),
            Player(id: 'a4', name: 'Ragu'),
          ],
          onConfirmed: (_) async => true,
        ),
      ),
    ));

    await tester.enterText(
        find.byKey(const ValueKey('next-batter-search')), 'rag');
    await tester.pump();

    expect(find.text('Ragu'), findsOneWidget);
    expect(find.text('Karthick'), findsNothing);
  });
}
