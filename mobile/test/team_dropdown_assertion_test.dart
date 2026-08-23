import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cricket_scorer/data/local/database.dart';

void main() {
  testWidgets('DropdownButtonFormField with String team IDs prevents object equality assertion crash', (tester) async {
    final team1V1 = TeamsTableData(
      id: 'team-1',
      name: 'Super Kings',
      shortName: 'SK',
      color: '#000000',
      createdAt: DateTime.now().millisecondsSinceEpoch,
      syncStatus: 'local',
    );

    // Team 1 updated in database (e.g. players added)
    final team1V2 = TeamsTableData(
      id: 'team-1',
      name: 'Super Kings',
      shortName: 'SK',
      color: '#000000',
      createdAt: DateTime.now().millisecondsSinceEpoch,
      syncStatus: 'local',
    );

    final team2 = TeamsTableData(
      id: 'team-2',
      name: 'Royal Challengers',
      shortName: 'RC',
      color: '#111111',
      createdAt: DateTime.now().millisecondsSinceEpoch,
      syncStatus: 'local',
    );

    final teams = [team1V2, team2];
    final uniqueTeamsMap = <String, TeamsTableData>{
      for (final t in teams) t.id: t
    };

    TeamsTableData? selectedTeamA = team1V1; // Old object reference in state

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return DropdownButtonFormField<String>(
                value: (selectedTeamA != null &&
                        teams.any((t) => t.id == selectedTeamA!.id))
                    ? selectedTeamA!.id
                    : null,
                items: teams
                    .map((t) => DropdownMenuItem<String>(
                          value: t.id,
                          child: Text(t.name),
                        ))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    selectedTeamA = val != null ? uniqueTeamsMap[val] : null;
                  });
                },
              );
            },
          ),
        ),
      ),
    );

    expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
    expect(find.text('Super Kings'), findsOneWidget);
  });
}
