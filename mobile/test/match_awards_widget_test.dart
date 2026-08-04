import 'package:cricket_scoring_engine/cricket_scoring_engine.dart';
import 'package:cricket_scorer/presentation/common/widgets/match_awards_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('result award cards display persisted batter and bowler records',
      (tester) async {
    const awards = [
      MatchAward(
        id: 'batter',
        matchId: 'm',
        type: MatchAwardType.bestBatter,
        playerId: 'p1',
        teamId: 'a',
        playerNameSnapshot: 'Ravi',
        teamNameSnapshot: 'Team A',
        summary: '68 runs from 42 balls',
        secondarySummary: '4s: 7 · 6s: 3 · SR: 161.90',
        rankingScore: 700,
        createdAt: 1,
      ),
      MatchAward(
        id: 'bowler',
        matchId: 'm',
        type: MatchAwardType.bestBowler,
        playerId: 'p2',
        teamId: 'b',
        playerNameSnapshot: 'Arjun',
        teamNameSnapshot: 'Team B',
        summary: '3 wickets for 18 runs',
        secondarySummary: 'Overs: 4.0 · Economy: 4.50',
        rankingScore: 80,
        createdAt: 1,
      ),
    ];
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: MatchAwardsSection(awards: awards)),
    ));

    expect(find.text('Best Batter'), findsOneWidget);
    expect(find.text('Ravi'), findsOneWidget);
    expect(find.text('Best Bowler'), findsOneWidget);
    expect(find.text('Arjun'), findsOneWidget);
  });
}
