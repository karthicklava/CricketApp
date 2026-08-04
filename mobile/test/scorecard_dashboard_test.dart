import 'package:cricket_scoring_engine/cricket_scoring_engine.dart';
import 'package:cricket_scorer/core/theme.dart';
import 'package:cricket_scorer/presentation/scorecard/scorecard_screen.dart';
import 'package:cricket_scorer/presentation/scorecard/widgets/scorecard_dashboard_widgets.dart';
import 'package:cricket_scorer/presentation/scorecard/widgets/responsive_scorecard_tables.dart';
import 'package:cricket_scorer/presentation/common/widgets/live_match_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const batting = Team(
  id: 'a',
  name: 'Rangers Athletic Group',
  shortName: 'RAG',
  players: [
    Player(id: 'a1', name: 'Karthick Long Batter Name'),
    Player(id: 'a2', name: 'Ragu'),
    Player(id: 'a3', name: 'Arun'),
  ],
);
const bowling = Team(
  id: 'b',
  name: 'Kings Athletic Riders',
  shortName: 'KAR',
  players: [
    Player(id: 'b1', name: 'Test Bowler'),
    Player(id: 'b2', name: 'Second Bowler'),
  ],
);

CricketScoringEngine createEngine() => CricketScoringEngine.createMatch(
      matchId: 'dashboard',
      config: const MatchConfig(
        format: MatchFormat.custom,
        totalOvers: 3,
        ballsPerOver: 6,
        maxOversPerBowler: 2,
      ),
      teamA: batting,
      teamB: bowling,
      tossWinnerTeamId: 'a',
      tossDecision: 'BAT',
      openingStrikerId: 'a1',
      openingNonStrikerId: 'a2',
      openingBowlerId: 'b1',
    );

CricketScoringEngine createCompletedChase() {
  final engine = createEngine();
  engine.recordDelivery(
    eventId: 'first-wicket',
    scorerDeviceId: 'test',
    wicket: const WicketDetail(
      type: WicketType.bowled,
      dismissedPlayerId: 'a1',
    ),
    newBatterId: 'a3',
  );
  engine.recordDelivery(
    eventId: 'second-wicket',
    scorerDeviceId: 'test',
    wicket: const WicketDetail(
      type: WicketType.bowled,
      dismissedPlayerId: 'a2',
    ),
  );
  engine.startSecondInnings(
    openingStrikerId: 'b1',
    openingNonStrikerId: 'b2',
    openingBowlerId: 'a1',
  );
  engine.recordDelivery(
    eventId: 'winning-run',
    scorerDeviceId: 'test',
    runsBatter: 1,
  );
  return engine;
}

Widget app(CricketScoringEngine engine, {TextScaler? textScaler}) =>
    MaterialApp(
      theme: AppTheme.lightTheme,
      builder: textScaler == null
          ? null
          : (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaler: textScaler),
                child: child!,
              ),
      home: ScorecardScreen(engine: engine),
    );

void main() {
  testWidgets('scorecard uses responsive mobile tables without DataTable',
      (tester) async {
    final engine = createEngine();
    engine.recordDelivery(
      eventId: 'four',
      scorerDeviceId: 'test',
      runsBatter: 4,
      isBoundaryFour: true,
    );
    engine.recordDelivery(
      eventId: 'wide',
      scorerDeviceId: 'test',
      extrasType: ExtrasType.wide,
      wideRuns: 1,
    );
    engine.recordDelivery(
      eventId: 'wicket',
      scorerDeviceId: 'test',
      wicket: const WicketDetail(
        type: WicketType.bowled,
        dismissedPlayerId: 'a1',
      ),
      newBatterId: 'a3',
    );

    await tester.pumpWidget(app(engine));
    await tester.pumpAndSettle();

    expect(find.byType(DataTable), findsNothing);
    expect(find.byType(LiveMatchHeader), findsOneWidget);
    expect(find.byType(ResponsiveBattingTable), findsOneWidget);
    expect(find.byType(ResponsiveBowlingTable), findsOneWidget);
    expect(find.byType(BattingScorecardRow), findsNWidgets(3));
    expect(find.byType(BowlingScorecardRow), findsOneWidget);
    expect(find.byType(PartnershipCard), findsOneWidget);
    expect(find.byType(ExtrasCard), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Fall of wickets'),
      300,
      scrollable: find.descendant(
        of: find.byType(ListView),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.ensureVisible(find.text('Fall of wickets'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fall of wickets'));
    await tester.pumpAndSettle();
    expect(find.byType(FallOfWicketCard), findsOneWidget);
    expect(find.text('1-5'), findsOneWidget);
    expect(find.text('Karthick Long Batter Name'), findsWidgets);
    expect(find.text('Test Bowler'), findsOneWidget);
  });

  testWidgets('bowling and partnership sections have meaningful empty states',
      (tester) async {
    await tester.pumpWidget(app(createEngine()));
    await tester.pumpAndSettle();

    expect(find.byType(DataTable), findsNothing);
    expect(find.text('No bowler has bowled yet'), findsOneWidget);
    expect(find.text('No active partnership'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Fall of wickets'),
      300,
      scrollable: find.descendant(
        of: find.byType(ListView),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.ensureVisible(find.text('Fall of wickets'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fall of wickets'));
    await tester.pumpAndSettle();
    expect(find.text('No wickets yet'), findsOneWidget);
  });

  testWidgets('DNB players use one compact section after batting rows',
      (tester) async {
    final engine = createEngine();
    engine.recordDelivery(
      eventId: 'run',
      scorerDeviceId: 'test',
      runsBatter: 1,
    );
    await tester.pumpWidget(app(engine));
    await tester.pumpAndSettle();

    expect(find.byType(BattingScorecardRow), findsNWidgets(2));
    expect(find.byType(DidNotBatRow), findsOneWidget);
    expect(find.textContaining('To Bat:'), findsOneWidget);
  });

  testWidgets('dashboard remains responsive at 320px with large text',
      (tester) async {
    tester.view.physicalSize = const Size(320, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final engine = createEngine();
    engine.recordDelivery(
      eventId: 'run',
      scorerDeviceId: 'test',
      runsBatter: 1,
    );

    await tester.pumpWidget(
      app(engine, textScaler: const TextScaler.linear(1.4)),
    );
    await tester.pumpAndSettle();

    expect(find.byType(LiveMatchHeader), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('completed chase uses result header and hides live equation',
      (tester) async {
    final engine = createCompletedChase();
    expect(engine.state.status, MatchStatus.completed);
    expect(engine.state.result?.winByWickets, 1);

    await tester.pumpWidget(app(engine));
    await tester.pumpAndSettle();

    expect(find.byType(ScorecardMatchHeader), findsOneWidget);
    expect(find.byType(LiveMatchHeader), findsNothing);
    expect(find.text('KAR · 2nd Innings'), findsOneWidget);
    expect(find.text('Kings Athletic Riders won by 1 wicket'), findsOneWidget);
    expect(find.text('COMPLETED'), findsOneWidget);
    final header = find.byType(ScorecardMatchHeader);
    expect(
      find.descendant(of: header, matching: find.textContaining('Batting')),
      findsNothing,
    );
    expect(find.descendant(of: header, matching: find.textContaining('Need')),
        findsNothing);
    expect(find.descendant(of: header, matching: find.textContaining('RRR')),
        findsNothing);
    expect(find.textContaining('Balls remaining'), findsNothing);
  });

  testWidgets('live chase uses singular run and ball grammar', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LiveMatchHeader(
            teamA: batting,
            teamB: bowling,
            battingTeam: batting,
            bowlingTeam: bowling,
            inningsNumber: 2,
            currentScore: '46/1',
            overs: '2.5',
            totalOvers: 3,
            target: 47,
            crr: 16,
            rrr: 6,
            runsNeeded: 1,
            ballsRemaining: 1,
          ),
        ),
      ),
    );

    expect(find.text('Target 47 · Need 1 run from 1 ball'), findsOneWidget);
  });
}
