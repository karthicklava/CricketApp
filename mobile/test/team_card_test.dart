import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cricket_scorer/core/theme.dart';
import 'package:cricket_scorer/data/local/database.dart';
import 'package:cricket_scorer/presentation/teams/widgets/team_card.dart';

void main() {
  final sampleTeam = TeamsTableData(
    id: 'team_1',
    name: 'Shield Eleven Cricket Club Extra Long Name',
    shortName: 'SHI',
    createdAt: 1600000000,
    syncStatus: 'localOnly',
  );

  final samplePlayers = [
    PlayersTableData(
      id: 'p1',
      name: 'Karthick R',
      role: 'allRounder',
      battingStyle: 'right',
      bowlingStyle: 'right',
      isCaptain: true,
      isWicketKeeper: false,
      createdAt: 1600000000,
      syncStatus: 'localOnly',
    ),
    for (int i = 2; i <= 12; i++)
      PlayersTableData(
        id: 'p$i',
        name: 'Player $i',
        role: 'allRounder',
        battingStyle: 'right',
        bowlingStyle: 'right',
        isCaptain: false,
        isWicketKeeper: false,
        createdAt: 1600000000,
        syncStatus: 'localOnly',
      ),
  ];

  Widget buildTestableWidget(Widget child, {Size size = const Size(360, 640)}) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: size.width,
            child: child,
          ),
        ),
      ),
    );
  }

  group('TeamCard UI & Layout Tests', () {
    testWidgets('renders compact C badge chip instead of Captain: text', (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        TeamCard(
          team: sampleTeam,
          players: samplePlayers,
          onTap: () {},
          onAddPlayers: () {},
          onEditTeam: () {},
        ),
      ));

      // Must NOT find legacy "Captain:" string anywhere
      expect(find.textContaining('Captain:'), findsNothing);

      // Must find "12 Players"
      expect(find.textContaining('12 Players'), findsOneWidget);

      // Must find compact C badge text
      expect(find.text('C'), findsOneWidget);

      // Must find captain name "Karthick R"
      expect(find.textContaining('Karthick R'), findsOneWidget);
    });

    testWidgets('handles empty roster with setup incomplete label', (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        TeamCard(
          team: sampleTeam,
          players: const [],
          onTap: () {},
          onAddPlayers: () {},
          onEditTeam: () {},
        ),
      ));

      expect(find.text('0 Players • Setup incomplete'), findsOneWidget);
      expect(find.text('C'), findsNothing);
    });

    testWidgets('remains responsive and overflow-free on narrow 320px screens', (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        TeamCard(
          team: sampleTeam,
          players: samplePlayers,
          onTap: () {},
          onAddPlayers: () {},
          onEditTeam: () {},
        ),
        size: const Size(320, 568),
      ));

      expect(find.text('C'), findsOneWidget);
      expect(find.byIcon(Icons.person_add_rounded), findsOneWidget);
      expect(find.byIcon(Icons.edit_rounded), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
