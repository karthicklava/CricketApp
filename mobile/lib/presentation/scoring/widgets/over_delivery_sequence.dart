import 'package:cricket_scoring_engine/cricket_scoring_engine.dart';
import 'package:flutter/material.dart';
import '../../../core/theme.dart';

enum DeliveryDisplayType {
  dot,
  run,
  boundary,
  six,
  wicket,
  wide,
  noBall,
  bye,
  legBye,
  wicketWithRuns,
  penalty,
}

class DeliveryDisplayItem {
  final String deliveryId;
  final String label;
  final String semanticLabel;
  final DeliveryDisplayType type;
  final bool isLegal;
  final int sequence;

  const DeliveryDisplayItem({
    required this.deliveryId,
    required this.label,
    required this.semanticLabel,
    required this.type,
    required this.isLegal,
    required this.sequence,
  });

  factory DeliveryDisplayItem.fromEvent(DeliveryEvent event) {
    final label = event.displayLabel;
    return DeliveryDisplayItem(
      deliveryId: event.eventId,
      label: label,
      semanticLabel: _expandedLabel(event),
      type: _typeFor(event),
      isLegal: event.isLegal,
      sequence: event.sequenceInOver,
    );
  }

  static DeliveryDisplayType _typeFor(DeliveryEvent event) {
    if (event.wicket != null && event.totalRuns > 0) {
      return DeliveryDisplayType.wicketWithRuns;
    }
    if (event.wicket != null) return DeliveryDisplayType.wicket;
    if (event.wideRuns > 0) return DeliveryDisplayType.wide;
    if (event.noBallRuns > 0) return DeliveryDisplayType.noBall;
    if (event.byeRuns > 0) return DeliveryDisplayType.bye;
    if (event.legByeRuns > 0) return DeliveryDisplayType.legBye;
    if (event.penaltyRuns > 0) return DeliveryDisplayType.penalty;
    if (event.runsBatter == 0) return DeliveryDisplayType.dot;
    if (event.isBoundarySix || event.runsBatter == 6) {
      return DeliveryDisplayType.six;
    }
    if (event.isBoundaryFour || event.runsBatter == 4) {
      return DeliveryDisplayType.boundary;
    }
    return DeliveryDisplayType.run;
  }

  static String _expandedLabel(DeliveryEvent event) {
    if (event.wicket != null) {
      return event.totalRuns == 0
          ? 'Wicket'
          : '${_runs(event.totalRuns)} and wicket';
    }
    if (event.wideRuns > 0) {
      return event.additionalWideRuns == 0
          ? 'Wide'
          : 'Wide plus ${_runs(event.additionalWideRuns)}';
    }
    if (event.noBallRuns > 0) {
      final additional = event.runsBatter + event.byeRuns + event.legByeRuns;
      return additional == 0 ? 'No ball' : 'No ball plus ${_runs(additional)}';
    }
    if (event.byeRuns > 0) {
      return '${event.byeRuns} ${event.byeRuns == 1 ? "bye" : "byes"}';
    }
    if (event.legByeRuns > 0) {
      return '${event.legByeRuns} leg ${event.legByeRuns == 1 ? "bye" : "byes"}';
    }
    if (event.runsBatter == 0) return 'Dot ball';
    return _runs(event.runsBatter);
  }

  static String _runs(int value) {
    const words = {
      0: 'zero',
      1: 'one run',
      2: 'two runs',
      3: 'three runs',
      4: 'four runs',
      5: 'five runs',
      6: 'six runs',
    };
    return words[value] ?? '$value runs';
  }
}

class OverDeliverySequence extends StatelessWidget {
  final List<DeliveryDisplayItem> deliveries;
  final int ballsPerOver;
  final bool isCompleted;
  final bool animateLatest;
  final bool onDarkSurface;

  const OverDeliverySequence({
    super.key,
    required this.deliveries,
    required this.ballsPerOver,
    required this.isCompleted,
    this.animateLatest = true,
    this.onDarkSurface = false,
  });

  @override
  Widget build(BuildContext context) {
    if (deliveries.isEmpty) {
      return Text(
        'No deliveries yet',
        key: const ValueKey('empty-over-sequence'),
        style: TextStyle(
          color: onDarkSurface ? Colors.white70 : Colors.grey,
          fontSize: 13,
        ),
      );
    }

    return Semantics(
      label:
          isCompleted ? 'Completed over deliveries' : 'Current over deliveries',
      explicitChildNodes: true,
      child: Wrap(
        key: const ValueKey('over-delivery-sequence'),
        spacing: 8,
        runSpacing: 8,
        children: [
          for (var index = 0; index < deliveries.length; index++)
            _DeliveryOutcome(
              key: ValueKey(deliveries[index].deliveryId),
              item: deliveries[index],
              animate: animateLatest && index == deliveries.length - 1,
              onDarkSurface: onDarkSurface,
            ),
        ],
      ),
    );
  }
}

class CurrentOverWidget extends StatelessWidget {
  final String title;
  final String? bowlerName;
  final List<DeliveryDisplayItem> deliveries;
  final int ballsPerOver;
  final int currentOverRuns;
  final int currentOverWickets;
  final bool isCompleted;
  final bool onDarkSurface;
  final bool showSummary;

  const CurrentOverWidget({
    super.key,
    required this.title,
    this.bowlerName,
    required this.deliveries,
    required this.ballsPerOver,
    required this.currentOverRuns,
    required this.currentOverWickets,
    this.isCompleted = false,
    this.onDarkSurface = false,
    this.showSummary = true,
  });

  @override
  Widget build(BuildContext context) {
    final primary = onDarkSurface ? Colors.white : AppColors.textPrimary;
    final secondary = onDarkSurface ? Colors.white70 : AppColors.textSecondary;
    return Column(
      key: const ValueKey('current-over-widget'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: primary,
                fontWeight: FontWeight.w800,
              ),
        ),
        if (bowlerName != null && bowlerName!.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            'Bowler: $bowlerName',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: secondary,
                ),
          ),
        ],
        const SizedBox(height: 8),
        OverDeliverySequence(
          deliveries: deliveries,
          ballsPerOver: ballsPerOver,
          isCompleted: isCompleted,
          animateLatest: !isCompleted,
          onDarkSurface: onDarkSurface,
        ),
        if (showSummary && deliveries.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            'This over: $currentOverRuns runs · $currentOverWickets ${currentOverWickets == 1 ? 'wicket' : 'wickets'}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: secondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ],
    );
  }
}

class _DeliveryOutcome extends StatelessWidget {
  final DeliveryDisplayItem item;
  final bool animate;
  final bool onDarkSurface;

  const _DeliveryOutcome({
    super.key,
    required this.item,
    required this.animate,
    required this.onDarkSurface,
  });

  @override
  Widget build(BuildContext context) {
    final (foreground, emphasisColor, hasIndicator) = switch (item.type) {
      DeliveryDisplayType.dot => (
          onDarkSurface ? Colors.white70 : Colors.black54,
          Colors.transparent,
          false
        ),
      DeliveryDisplayType.run => (
          onDarkSurface ? Colors.white : Colors.black87,
          Colors.transparent,
          false
        ),
      DeliveryDisplayType.boundary => (
          onDarkSurface
              ? Colors.lightBlue.shade100
              : AppColors.boundaryFourBlue,
          Colors.transparent,
          false
        ),
      DeliveryDisplayType.six => (
          onDarkSurface ? Colors.purple.shade100 : AppColors.boundarySixPurple,
          Colors.transparent,
          false
        ),
      DeliveryDisplayType.wicket || DeliveryDisplayType.wicketWithRuns => (
          AppColors.wicketRed,
          AppColors.wicketRed,
          true
        ),
      DeliveryDisplayType.wide || DeliveryDisplayType.noBall => (
          Colors.amber.shade900,
          Colors.amber.shade700,
          true
        ),
      DeliveryDisplayType.bye || DeliveryDisplayType.legBye => (
          Colors.blue.shade800,
          Colors.blue.shade500,
          true
        ),
      DeliveryDisplayType.penalty => (
          Colors.orange.shade900,
          Colors.orange.shade700,
          true
        ),
    };

    final outcome = Semantics(
      label: 'Delivery ${item.sequence}: ${item.semanticLabel}',
      excludeSemantics: true,
      child: ConstrainedBox(
        key: const ValueKey('delivery-outcome-token'),
        constraints: const BoxConstraints(minWidth: 26, minHeight: 28),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: hasIndicator ? emphasisColor.withValues(alpha: 0.10) : null,
            border: hasIndicator
                ? Border.all(color: emphasisColor.withValues(alpha: 0.28))
                : null,
            borderRadius: hasIndicator ? BorderRadius.circular(6) : null,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
            child: Center(
              widthFactor: 1,
              heightFactor: 1,
              child: Text(
                item.label,
                maxLines: 1,
                style: TextStyle(
                  color: foreground,
                  fontSize: 14,
                  height: 1.15,
                  fontWeight: switch (item.type) {
                    DeliveryDisplayType.dot ||
                    DeliveryDisplayType.run =>
                      FontWeight.w600,
                    _ => FontWeight.w800,
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (!animate) return outcome;
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 140),
      tween: Tween(begin: 0.92, end: 1),
      builder: (context, scale, child) => Transform.scale(
        scale: scale,
        child: Opacity(opacity: scale, child: child),
      ),
      child: outcome,
    );
  }
}
