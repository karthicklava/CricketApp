import 'package:cricket_scoring_engine/cricket_scoring_engine.dart';
import 'package:cricket_scorer/presentation/scoring/widgets/extras_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Wide selector starts at zero additional runs', (tester) async {
    ExtraSelection? selected;
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        return Scaffold(
          body: ElevatedButton(
            onPressed: () async {
              selected = await showModalBottomSheet<ExtraSelection>(
                context: context,
                builder: (_) => const ExtrasBottomSheet(type: ExtrasType.wide),
              );
            },
            child: const Text('Open'),
          ),
        );
      }),
    ));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Wide'), findsOneWidget);
    expect(find.text('Additional Runs After Wide'), findsOneWidget);
    expect(find.textContaining('One penalty run'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);

    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    expect(selected?.runs, 0);
  });
}
