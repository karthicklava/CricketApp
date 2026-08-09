import 'package:cricket_scorer/presentation/scoring/widgets/match_result_view.dart';
import 'package:cricket_scoring_engine/cricket_scoring_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const teamA = Team(id: 'a', name: 'Shield11', shortName: 'SHI');
const teamB = Team(id: 'b', name: 'Vengai Kings', shortName: 'VK');

Widget hero(MatchResult result, {ThemeMode themeMode = ThemeMode.light}) =>
    MaterialApp(
      themeMode: themeMode,
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      home: Scaffold(
        body: SizedBox(
          width: 320,
          child: VictoryHeroBanner(
            result: result,
            resultText: result.resultString,
            teamA: teamA,
            teamB: teamB,
            manuallyEnded: false,
          ),
        ),
      ),
    );

void main() {
  testWidgets('victory hero highlights winner and run margin', (tester) async {
    await tester.pumpWidget(hero(const MatchResult(
      winnerTeamId: 'a',
      resultString: 'Shield11 won by 5 runs',
      winByRuns: 5,
    )));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('victory-hero-banner')), findsOneWidget);
    expect(
        find.byKey(const ValueKey('gold-trophy-illustration')), findsOneWidget);
    expect(find.text('MATCH COMPLETE'), findsOneWidget);
    expect(find.text('Shield11'), findsOneWidget);
    expect(find.text('WON BY 5 RUNS'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('wicket victory uses premium wicket-margin hierarchy',
      (tester) async {
    await tester.pumpWidget(hero(const MatchResult(
      winnerTeamId: 'b',
      resultString: 'Vengai Kings won by 6 wickets',
      winByWickets: 6,
    )));
    await tester.pumpAndSettle();

    expect(find.text('Vengai Kings'), findsOneWidget);
    expect(find.text('WON BY 6 WICKETS'), findsOneWidget);
  });

  testWidgets('tie uses a distinct illustration in dark mode', (tester) async {
    await tester.pumpWidget(
      hero(
        const MatchResult(
          winnerTeamId: '',
          resultString: 'Match tied',
          isTie: true,
        ),
        themeMode: ThemeMode.dark,
      ),
    );
    await tester.pumpAndSettle();

    expect(
        find.byKey(const ValueKey('tie-result-illustration')), findsOneWidget);
    expect(
        find.byKey(const ValueKey('gold-trophy-illustration')), findsNothing);
    expect(find.text('FINAL RESULT'), findsOneWidget);
    expect(find.text('MATCH TIED'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
