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
}
