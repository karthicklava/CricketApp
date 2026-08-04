import 'package:cricket_scoring_engine/cricket_scoring_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cricket_scorer/presentation/scoring/widgets/score_summary_card.dart';
import 'package:cricket_scorer/presentation/scoring/widgets/scoring_action_grid.dart';
import 'package:cricket_scorer/presentation/scoring/widgets/over_delivery_sequence.dart';
import 'package:cricket_scorer/presentation/scoring/widgets/over_summary_bottom_sheet.dart';

void main() {
  const batting = Team(
    id: 'a',
    name: 'Alpha',
    shortName: 'ALP',
    players: [
      Player(id: 'a1', name: 'A One'),
      Player(id: 'a2', name: 'A Two'),
    ],
  );
  const bowling = Team(
    id: 'b',
    name: 'Beta',
    shortName: 'BET',
    players: [Player(id: 'b1', name: 'Arjun')],
  );

  testWidgets('summary identifies batting, bowling and innings teams',
      (tester) async {
    const chasingTeam = Team(
      id: 'b',
      name: 'Beta',
      shortName: 'BET',
      players: [
        Player(id: 'b1', name: 'B One'),
        Player(id: 'b2', name: 'B Two'),
      ],
    );
    final engine = CricketScoringEngine.createMatch(
      matchId: 'team-identity',
      config: const MatchConfig(
        format: MatchFormat.custom,
        totalOvers: 1,
        maxOversPerBowler: 1,
      ),
      teamA: batting,
      teamB: chasingTeam,
      tossWinnerTeamId: 'a',
      tossDecision: 'BAT',
      openingStrikerId: 'a1',
      openingNonStrikerId: 'a2',
      openingBowlerId: 'b1',
    );

    Widget summary() => MaterialApp(
          home: Scaffold(
            body: ScoreSummaryCard(
              matchState: engine.state,
              syncStatusText: 'Saved',
              isOnline: false,
            ),
          ),
        );

    await tester.pumpWidget(summary());
    expect(find.text('ALP batting'), findsOneWidget);
    expect(find.text('vs BET'), findsOneWidget);
    expect(find.text('1st Innings'), findsOneWidget);

    for (var ball = 0; ball < 6; ball++) {
      engine.recordDelivery(
        eventId: 'identity-$ball',
        scorerDeviceId: 'test',
        runsBatter: ball == 0 ? 1 : 0,
      );
    }
    engine.startSecondInnings(
      openingStrikerId: 'b1',
      openingNonStrikerId: 'b2',
      openingBowlerId: 'a1',
    );
    await tester.pumpWidget(summary());
    expect(find.text('BET batting'), findsOneWidget);
    expect(find.text('vs ALP'), findsOneWidget);
    expect(find.text('2nd Innings'), findsOneWidget);
    expect(find.textContaining('Target 2'), findsOneWidget);
  });

  testWidgets('current over shows outcome labels and one over heading',
      (tester) async {
    final engine = CricketScoringEngine.createMatch(
      matchId: 'm',
      config: MatchConfig.t20(),
      teamA: batting,
      teamB: bowling,
      tossWinnerTeamId: 'a',
      tossDecision: 'BAT',
      openingStrikerId: 'a1',
      openingNonStrikerId: 'a2',
      openingBowlerId: 'b1',
    );
    engine.recordDelivery(eventId: '1', scorerDeviceId: 'test');
    engine.recordDelivery(eventId: '2', scorerDeviceId: 'test', runsBatter: 4);
    engine.recordDelivery(
      eventId: '3',
      scorerDeviceId: 'test',
      extrasType: ExtrasType.wide,
      wideRuns: 1,
    );
    engine.recordDelivery(eventId: '4', scorerDeviceId: 'test', runsBatter: 1);
    engine.recordDelivery(
      eventId: '5',
      scorerDeviceId: 'test',
      extrasType: ExtrasType.noBall,
      noBallRuns: 1,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ScoreSummaryCard(
            matchState: engine.state,
            syncStatusText: 'Saved',
            isOnline: false,
          ),
        ),
      ),
    );

    expect(find.text('0.3 / 20 overs'), findsOneWidget);
    expect(find.text('Current Over · 1'), findsOneWidget);
    expect(find.textContaining('legal balls'), findsNothing);
    expect(find.byType(OverDeliverySequence), findsOneWidget);
    expect(find.text('1.1'), findsNothing);
    for (final label in ['0', '4', 'Wd', '1', 'Nb']) {
      expect(find.text(label), findsOneWidget);
    }
  });

  testWidgets('innings notation and active over number stay independent',
      (tester) async {
    final engine = CricketScoringEngine.createMatch(
      matchId: 'over-notation',
      config: const MatchConfig(
        format: MatchFormat.custom,
        totalOvers: 3,
        ballsPerOver: 6,
        maxOversPerBowler: 3,
        allowConsecutiveOvers: true,
      ),
      teamA: batting,
      teamB: bowling,
      tossWinnerTeamId: 'a',
      tossDecision: 'BAT',
      openingStrikerId: 'a1',
      openingNonStrikerId: 'a2',
      openingBowlerId: 'b1',
    );
    for (var ball = 0; ball < 6; ball++) {
      engine.recordDelivery(
        eventId: 'first-$ball',
        scorerDeviceId: 'test',
      );
    }
    engine.selectNextBowler('b1');
    for (var ball = 0; ball < 4; ball++) {
      engine.recordDelivery(
        eventId: 'second-$ball',
        scorerDeviceId: 'test',
        runsBatter: 4,
        isBoundaryFour: true,
      );
    }

    Widget score(MatchState state) => MaterialApp(
          home: Scaffold(
            body: ScoreSummaryCard(
              matchState: state,
              syncStatusText: 'Saved',
              isOnline: false,
            ),
          ),
        );

    expect(engine.state.activeInnings.legalBallsBowled, 10);
    await tester.pumpWidget(score(engine.state));
    expect(find.text('1.4 / 3 overs'), findsOneWidget);
    expect(find.text('Current Over · 2'), findsOneWidget);
    expect(find.text('4'), findsNWidgets(4));
    expect(find.text('This over: 16 runs · 0 wickets'), findsOneWidget);

    final resumed = MatchState.fromJson(engine.state.toJson());
    await tester.pumpWidget(score(resumed));
    expect(find.text('1.4 / 3 overs'), findsOneWidget);
    expect(find.text('Current Over · 2'), findsOneWidget);

    engine.undoLastDelivery();
    await tester.pumpWidget(score(engine.state));
    expect(find.text('1.3 / 3 overs'), findsOneWidget);
    expect(find.text('Current Over · 2'), findsOneWidget);
    expect(find.text('4'), findsNWidgets(3));
  });

  testWidgets('scoring controls fit 320px and maintain minimum targets',
      (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var recordedRuns = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: ScoringActionGrid(
              onRunPressed: (_) => recordedRuns++,
              onWicketPressed: () {},
              onExtrasPressed: (_) {},
              onUndoPressed: () {},
              onMorePressed: () {},
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    for (final label in ['0', '1', '2', '3', '4', '5', '6', 'W']) {
      expect(find.text(label), findsOneWidget);
    }
    final zeroButton = tester.getSize(find.widgetWithText(ElevatedButton, '0'));
    final wicketButton =
        tester.getSize(find.widgetWithText(ElevatedButton, 'W'));
    expect(zeroButton.width, closeTo(wicketButton.width, 0.1));
    expect(zeroButton.height, greaterThanOrEqualTo(48));
    expect(find.text('Undo'), findsOneWidget);
    expect(find.text('More'), findsOneWidget);

    await tester.tap(find.text('0'));
    await tester.tap(find.text('0'));
    expect(recordedRuns, 1);
  });

  testWidgets('new over clears completed-over outcome chips', (tester) async {
    final engine = CricketScoringEngine.createMatch(
      matchId: 'new-over',
      config: MatchConfig.t20(),
      teamA: batting,
      teamB: bowling,
      tossWinnerTeamId: 'a',
      tossDecision: 'BAT',
      openingStrikerId: 'a1',
      openingNonStrikerId: 'a2',
      openingBowlerId: 'b1',
    );
    for (var index = 0; index < 6; index++) {
      engine.recordDelivery(
        eventId: 'ball-$index',
        scorerDeviceId: 'test',
      );
    }

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ScoreSummaryCard(
            matchState: engine.state,
            syncStatusText: 'Saved',
            isOnline: false,
          ),
        ),
      ),
    );

    expect(find.text('Current Over · 2'), findsOneWidget);
    expect(find.textContaining('legal balls'), findsNothing);
    expect(find.text('No deliveries yet'), findsOneWidget);
  });

  testWidgets('completed over uses the same delivery sequence component',
      (tester) async {
    final engine = CricketScoringEngine.createMatch(
      matchId: 'summary',
      config: MatchConfig.t20(),
      teamA: batting,
      teamB: bowling,
      tossWinnerTeamId: 'a',
      tossDecision: 'BAT',
      openingStrikerId: 'a1',
      openingNonStrikerId: 'a2',
      openingBowlerId: 'b1',
    );
    for (var index = 0; index < 6; index++) {
      engine.recordDelivery(
        eventId: 'summary-$index',
        scorerDeviceId: 'test',
        runsBatter: index == 1 ? 4 : 0,
      );
    }

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OverSummaryBottomSheet(
            matchState: engine.state,
            onSelectNextBowler: () {},
            onEndMatch: () {},
          ),
        ),
      ),
    );

    expect(find.byType(OverDeliverySequence), findsOneWidget);
    expect(
        find.byKey(const ValueKey('over-delivery-sequence')), findsOneWidget);
  });

  testWidgets('delivery semantics expand abbreviated chip labels',
      (tester) async {
    final engine = CricketScoringEngine.createMatch(
      matchId: 'semantics',
      config: MatchConfig.t20(),
      teamA: batting,
      teamB: bowling,
      tossWinnerTeamId: 'a',
      tossDecision: 'BAT',
      openingStrikerId: 'a1',
      openingNonStrikerId: 'a2',
      openingBowlerId: 'b1',
    );
    engine.recordDelivery(eventId: 'dot', scorerDeviceId: 'test');
    engine.recordDelivery(
      eventId: 'wide',
      scorerDeviceId: 'test',
      extrasType: ExtrasType.wide,
      wideRuns: 1,
    );
    engine.recordDelivery(
      eventId: 'no-ball',
      scorerDeviceId: 'test',
      extrasType: ExtrasType.noBall,
      noBallRuns: 1,
      runsBatter: 1,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OverDeliverySequence(
            deliveries:
                engine.state.events.map(DeliveryDisplayItem.fromEvent).toList(),
            ballsPerOver: 6,
            isCompleted: false,
          ),
        ),
      ),
    );

    expect(find.bySemanticsLabel('Delivery 1: Dot ball'), findsOneWidget);
    expect(find.bySemanticsLabel('Delivery 2: Wide'), findsOneWidget);
    expect(
      find.bySemanticsLabel('Delivery 3: No ball plus one run'),
      findsOneWidget,
    );
  });

  testWidgets('delivery outcomes use compact inline tokens for every label',
      (tester) async {
    const labels = ['0', '1', '4', 'W', 'Wd', 'Nb', 'B2', 'LB1', 'Nb+4', '1+W'];
    final deliveries = List.generate(
      labels.length,
      (index) => DeliveryDisplayItem(
        deliveryId: 'compact-$index',
        label: labels[index],
        semanticLabel: labels[index],
        type: switch (index) {
          0 => DeliveryDisplayType.dot,
          1 => DeliveryDisplayType.run,
          2 => DeliveryDisplayType.boundary,
          3 => DeliveryDisplayType.wicket,
          4 => DeliveryDisplayType.wide,
          5 || 8 => DeliveryDisplayType.noBall,
          6 => DeliveryDisplayType.bye,
          7 => DeliveryDisplayType.legBye,
          _ => DeliveryDisplayType.wicketWithRuns,
        },
        isLegal: index != 4 && index != 5 && index != 8,
        sequence: index + 1,
      ),
    );

    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 320,
          child: OverDeliverySequence(
            deliveries: [],
            ballsPerOver: 6,
            isCompleted: false,
          ),
        ),
      ),
    ));
    expect(find.text('No deliveries yet'), findsOneWidget);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 320,
          child: OverDeliverySequence(
            deliveries: deliveries,
            ballsPerOver: 6,
            isCompleted: false,
            animateLatest: false,
          ),
        ),
      ),
    ));

    for (final label in labels) {
      expect(find.text(label), findsOneWidget);
    }
    final tokens = find.byKey(const ValueKey('delivery-outcome-token'));
    expect(tokens, findsNWidgets(labels.length));
    for (var index = 0; index < labels.length; index++) {
      expect(tester.getSize(tokens.at(index)).height, lessThanOrEqualTo(32));
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('undo removes the latest shared delivery chip', (tester) async {
    final engine = CricketScoringEngine.createMatch(
      matchId: 'undo-chip',
      config: MatchConfig.t20(),
      teamA: batting,
      teamB: bowling,
      tossWinnerTeamId: 'a',
      tossDecision: 'BAT',
      openingStrikerId: 'a1',
      openingNonStrikerId: 'a2',
      openingBowlerId: 'b1',
    );
    engine.recordDelivery(eventId: 'dot', scorerDeviceId: 'test');
    engine.recordDelivery(
      eventId: 'four',
      scorerDeviceId: 'test',
      runsBatter: 4,
      isBoundaryFour: true,
    );

    Widget score() => MaterialApp(
          home: Scaffold(
            body: ScoreSummaryCard(
              matchState: engine.state,
              syncStatusText: 'Saved',
              isOnline: false,
            ),
          ),
        );

    await tester.pumpWidget(score());
    expect(find.byKey(const ValueKey('four')), findsOneWidget);

    engine.undoLastDelivery();
    await tester.pumpWidget(score());
    expect(find.byKey(const ValueKey('four')), findsNothing);
    expect(find.byKey(const ValueKey('dot')), findsOneWidget);
  });

  testWidgets('long delivery sequences wrap with large text without clipping',
      (tester) async {
    tester.view.physicalSize = const Size(240, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final deliveries = List.generate(
      12,
      (index) => DeliveryDisplayItem(
        deliveryId: 'delivery-$index',
        label: index.isEven ? 'Wd+2' : 'Nb+4',
        semanticLabel: index.isEven ? 'Two wides' : 'No ball plus four runs',
        type: index.isEven
            ? DeliveryDisplayType.wide
            : DeliveryDisplayType.noBall,
        isLegal: false,
        sequence: index + 1,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: Scaffold(
          body: OverDeliverySequence(
            deliveries: deliveries,
            ballsPerOver: 6,
            isCompleted: false,
            animateLatest: false,
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byKey(const ValueKey('delivery-11')), findsOneWidget);
  });
}
