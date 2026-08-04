import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cricket_scoring_engine/cricket_scoring_engine.dart';
import '../scoring/widgets/score_summary_card.dart';
import '../scoring/widgets/scoring_action_grid.dart';
import '../scoring/widgets/wicket_bottom_sheet.dart';
import '../../core/theme.dart';

class DemoScoringScreen extends StatefulWidget {
  const DemoScoringScreen({super.key});

  @override
  State<DemoScoringScreen> createState() => _DemoScoringScreenState();
}

class _DemoScoringScreenState extends State<DemoScoringScreen> {
  late CricketScoringEngine _engine;

  @override
  void initState() {
    super.initState();
    // Isolated demo data fixture
    final teamA = const Team(
      id: 'demo_team_a',
      name: 'Demo XI (Hawks)',
      shortName: 'HWK',
      players: [
        Player(id: 'dp1', name: 'Alex Hales'),
        Player(id: 'dp2', name: 'Jason Roy'),
        Player(id: 'dp3', name: 'Jos Buttler'),
      ],
    );

    final teamB = const Team(
      id: 'demo_team_b',
      name: 'Demo XI (Eagles)',
      shortName: 'EAG',
      players: [
        Player(id: 'dp4', name: 'Trent Boult'),
        Player(id: 'dp5', name: 'Tim Southee'),
      ],
    );

    _engine = CricketScoringEngine.createMatch(
      matchId: 'demo_match_999',
      config: MatchConfig.t20(),
      teamA: teamA,
      teamB: teamB,
      tossWinnerTeamId: teamA.id,
      tossDecision: 'BAT',
      openingStrikerId: 'dp1',
      openingNonStrikerId: 'dp2',
      openingBowlerId: 'dp4',
    );
  }

  void _recordRun(int runs) {
    setState(() {
      _engine.recordDelivery(
        eventId: 'demo_${DateTime.now().microsecondsSinceEpoch}',
        scorerDeviceId: 'demo_device',
        runsBatter: runs,
        isBoundaryFour: runs == 4,
        isBoundarySix: runs == 6,
      );
    });
  }

  void _recordExtras(ExtrasType type) {
    setState(() {
      _engine.recordDelivery(
        eventId: 'demo_${DateTime.now().microsecondsSinceEpoch}',
        scorerDeviceId: 'demo_device',
        extrasType: type,
      );
    });
  }

  void _undo() {
    setState(() {
      _engine.undoLastDelivery();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = _engine.state;
    final inn = state.activeInnings;
    final battingTeam =
        inn.battingTeamId == state.teamA.id ? state.teamA : state.teamB;
    final bowlingTeam =
        inn.battingTeamId == state.teamA.id ? state.teamB : state.teamA;

    final striker = battingTeam.players.firstWhere((p) => p.id == inn.strikerId,
        orElse: () => Player(id: inn.strikerId, name: 'Striker'));
    final nonStriker = battingTeam.players.firstWhere(
        (p) => p.id == inn.nonStrikerId,
        orElse: () => Player(id: inn.nonStrikerId, name: 'Non-Striker'));
    final bowler = bowlingTeam.players.firstWhere(
        (p) => p.id == inn.currentBowlerId,
        orElse: () => Player(
            id: inn.currentBowlerId ?? '', name: 'Awaiting next bowler'));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: const Text('DEMO MATCH (Isolated)'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.exit_to_app, color: Colors.white),
            label: const Text('EXIT DEMO',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            onPressed: () {
              context.pop();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Demo Banner Warning
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: Colors.deepOrange.shade100,
            child: Row(
              children: const [
                Icon(Icons.info_outline, color: Colors.deepOrange),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'DEMO MODE — Data is not saved to your real match history.',
                    style: TextStyle(
                        color: Colors.deepOrange,
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                  ),
                ),
              ],
            ),
          ),

          ScoreSummaryCard(
            matchState: state,
            syncStatusText: 'Demo Mode',
            isOnline: false,
          ),

          Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${striker.name} *',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(nonStriker.name,
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 15)),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Bowler: ${bowler.name}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15)),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),

          ScoringActionGrid(
            onRunPressed: _recordRun,
            onWicketPressed: () {},
            onExtrasPressed: _recordExtras,
            onUndoPressed: _undo,
            onMorePressed: () {},
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
