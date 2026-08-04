import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../common/widgets/sports_ui.dart';

class DashboardSectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const DashboardSectionTitle({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: Color(0xFFE1F2EC),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -.3,
                  ),
              softWrap: true,
            ),
          ),
        ],
      );
}

class MatchSummaryCard extends StatelessWidget {
  final String teams;
  final String status;
  final String score;
  final String overs;
  final String currentRunRate;
  final String? requiredRunRate;
  final String? result;

  const MatchSummaryCard({
    super.key,
    required this.teams,
    required this.status,
    required this.score,
    required this.overs,
    required this.currentRunRate,
    this.requiredRunRate,
    this.result,
  });

  @override
  Widget build(BuildContext context) => _AnimatedDashboardCard(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [AppColors.primaryDark, AppColors.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      teams,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                  StatusBadge(
                    label: status,
                    tone: status.toLowerCase() == 'live'
                        ? StatusBadgeTone.live
                        : StatusBadgeTone.success,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                score,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      height: 1,
                      letterSpacing: -1.5,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                overs,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white70,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              if (result != null) ...[
                const SizedBox(height: 10),
                Text(
                  result!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFFFFD36A),
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  _RateMetric(label: 'CRR', value: currentRunRate),
                  if (requiredRunRate != null) ...[
                    const SizedBox(width: 28),
                    _RateMetric(label: 'RRR', value: requiredRunRate!),
                  ],
                ],
              ),
            ],
          ),
        ),
      );
}

class _RateMetric extends StatelessWidget {
  final String label;
  final String value;

  const _RateMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white60,
                    fontWeight: FontWeight.w700,
                  )),
          Text(value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  )),
        ],
      );
}

class BatterCard extends StatelessWidget {
  final String name;
  final int runs;
  final int balls;
  final int fours;
  final int sixes;
  final double strikeRate;
  final String status;
  final bool isStriker;
  final bool expanded;
  final VoidCallback? onTap;

  const BatterCard({
    super.key,
    required this.name,
    required this.runs,
    required this.balls,
    required this.fours,
    required this.sixes,
    required this.strikeRate,
    required this.status,
    this.isStriker = false,
    this.expanded = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => CompactBatterRow(
        name: name,
        runs: runs,
        balls: balls,
        fours: fours,
        sixes: sixes,
        strikeRate: strikeRate,
        status: status,
        isStriker: isStriker,
        expanded: expanded,
        onTap: onTap,
      );
}

class CompactBatterRow extends StatelessWidget {
  const CompactBatterRow(
      {super.key,
      required this.name,
      required this.runs,
      required this.balls,
      required this.fours,
      required this.sixes,
      required this.strikeRate,
      required this.status,
      this.isStriker = false,
      this.expanded = false,
      this.onTap});
  final String name, status;
  final int runs, balls, fours, sixes;
  final double strikeRate;
  final bool isStriker, expanded;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final normalizedStatus = status.toLowerCase();
    final didNotBat = (normalizedStatus == 'yet to bat' ||
            normalizedStatus == 'did not bat' ||
            normalizedStatus == 'dnb') &&
        balls == 0 &&
        runs == 0;
    return ExpandableScorecardRow(
      expanded: expanded,
      onTap: onTap,
      semanticLabel:
          '$name, ${didNotBat ? 'did not bat' : '$runs runs from $balls balls'}, strike rate ${strikeRate.toStringAsFixed(1)}',
      summary: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
              child: Text('$name${isStriker ? '*' : ''}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w800))),
          Text(didNotBat ? 'DNB' : '$runs ($balls)',
              style:
                  const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
          const SizedBox(width: 4),
          Icon(expanded ? Icons.expand_less : Icons.expand_more,
              size: 18, color: AppColors.textSecondary),
        ]),
        const SizedBox(height: 5),
        Row(children: [
          Expanded(
              child: Text(isStriker ? 'STRIKER' : status,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: isStriker ? FontWeight.w800 : FontWeight.w500,
                      color: isStriker
                          ? AppColors.primary
                          : AppColors.textSecondary))),
          if (!didNotBat)
            Flexible(
              child: Text(
                  '4s $fours · 6s $sixes · SR ${strikeRate.toStringAsFixed(1)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600)),
            ),
        ]),
      ]),
      details: Wrap(spacing: 18, runSpacing: 6, children: [
        _InlineDetail(label: 'Dismissal', value: status),
        _InlineDetail(label: 'Boundaries', value: '${fours + sixes}'),
        _InlineDetail(
            label: 'Boundary runs', value: '${fours * 4 + sixes * 6}'),
      ]),
    );
  }
}

class BowlerCard extends StatelessWidget {
  final String name;
  final String overs;
  final int maidens;
  final int runs;
  final int wickets;
  final double economy;
  final int wides;
  final int noBalls;
  final bool expanded;
  final VoidCallback? onTap;

  const BowlerCard({
    super.key,
    required this.name,
    required this.overs,
    required this.maidens,
    required this.runs,
    required this.wickets,
    required this.economy,
    required this.wides,
    required this.noBalls,
    this.expanded = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => CompactBowlerRow(
      name: name,
      overs: overs,
      maidens: maidens,
      runs: runs,
      wickets: wickets,
      economy: economy,
      wides: wides,
      noBalls: noBalls,
      expanded: expanded,
      onTap: onTap);
}

class CompactBowlerRow extends StatelessWidget {
  const CompactBowlerRow(
      {super.key,
      required this.name,
      required this.overs,
      required this.maidens,
      required this.runs,
      required this.wickets,
      required this.economy,
      required this.wides,
      required this.noBalls,
      this.expanded = false,
      this.onTap});
  final String name, overs;
  final int maidens, runs, wickets, wides, noBalls;
  final double economy;
  final bool expanded;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => ExpandableScorecardRow(
        expanded: expanded,
        onTap: onTap,
        semanticLabel:
            '$name, $overs overs, $maidens maidens, $runs runs, $wickets wickets, economy ${economy.toStringAsFixed(2)}',
        summary:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
                child: Text(name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w800))),
            Text('$overs–$maidens–$runs–$wickets',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
            const SizedBox(width: 4),
            Icon(expanded ? Icons.expand_less : Icons.expand_more,
                size: 18, color: AppColors.textSecondary),
          ]),
          const SizedBox(height: 5),
          Row(children: [
            Expanded(
                child: Text('Wd $wides · Nb $noBalls',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary))),
            Text('Eco ${economy.toStringAsFixed(2)}',
                style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700)),
          ]),
        ]),
        details: Wrap(spacing: 18, runSpacing: 6, children: [
          _InlineDetail(label: 'Maidens', value: '$maidens'),
          _InlineDetail(label: 'Wides', value: '$wides'),
          _InlineDetail(label: 'No balls', value: '$noBalls'),
          _InlineDetail(label: 'Wickets', value: '$wickets'),
        ]),
      );
}

class GroupedScorecardSection extends StatelessWidget {
  const GroupedScorecardSection(
      {super.key,
      required this.title,
      required this.icon,
      required this.children});
  final String title;
  final IconData icon;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => AppCard(
        padding: EdgeInsets.zero,
        elevated: false,
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
              child: Row(children: [
                Icon(icon, size: 19, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    softWrap: true,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                ),
              ])),
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const Divider(height: 1),
            children[i],
          ],
        ]),
      );
}

class ExpandableScorecardRow extends StatelessWidget {
  const ExpandableScorecardRow(
      {super.key,
      required this.summary,
      required this.details,
      required this.expanded,
      required this.semanticLabel,
      this.onTap});
  final Widget summary, details;
  final bool expanded;
  final String semanticLabel;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Semantics(
        label: semanticLabel,
        button: true,
        expanded: expanded,
        child: InkWell(
            onTap: onTap,
            child: AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        summary,
                        if (expanded) ...[const Divider(height: 18), details],
                      ])),
            )),
      );
}

class _InlineDetail extends StatelessWidget {
  const _InlineDetail({required this.label, required this.value});
  final String label, value;
  @override
  Widget build(BuildContext context) => Text('$label: $value',
      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary));
}

class PartnershipCard extends StatelessWidget {
  final int runs;
  final int balls;
  final int boundaries;
  final double runRate;

  const PartnershipCard({
    super.key,
    required this.runs,
    required this.balls,
    required this.boundaries,
    required this.runRate,
  });

  @override
  Widget build(BuildContext context) => CompactScoreStatTile(
        title: 'Partnership',
        primaryContent: Text('$runs runs · $balls balls'),
        secondaryContent: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('RR ${runRate.toStringAsFixed(2)}'),
            Text('$boundaries boundaries'),
          ],
        ),
      );
}

class ExtrasCard extends StatelessWidget {
  final int wides;
  final int noBalls;
  final int byes;
  final int legByes;
  final int penalty;

  const ExtrasCard({
    super.key,
    required this.wides,
    required this.noBalls,
    required this.byes,
    required this.legByes,
    required this.penalty,
  });

  int get total => wides + noBalls + byes + legByes + penalty;

  @override
  Widget build(BuildContext context) => CompactScoreStatTile(
        title: 'Extras',
        primaryContent: Text('Total $total'),
        secondaryContent: total == 0
            ? const Text('No extras')
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Wd $wides · Nb $noBalls'),
                  Text(
                      'B $byes · LB $legByes${penalty > 0 ? ' · P $penalty' : ''}'),
                ],
              ),
      );
}

class CompactScoreStatTile extends StatelessWidget {
  const CompactScoreStatTile({
    super.key,
    required this.title,
    required this.primaryContent,
    required this.secondaryContent,
    this.icon,
  });

  final String title;
  final Widget primaryContent;
  final Widget secondaryContent;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Container(
        key: ValueKey('score-stat-${title.toLowerCase()}'),
        constraints: const BoxConstraints(minHeight: 124),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFFE1E7E4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: AppColors.primary),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w800)),
              ),
            ]),
            const SizedBox(height: 10),
            DefaultTextStyle.merge(
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: primaryContent,
              ),
            ),
            const SizedBox(height: 6),
            DefaultTextStyle.merge(
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary, height: 1.35),
              child: secondaryContent,
            ),
          ],
        ),
      );
}

class CompactStatCard extends StatelessWidget {
  const CompactStatCard({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) =>
      AppCard(padding: const EdgeInsets.all(14), child: child);
}

class ResponsiveScoreStatTiles extends StatelessWidget {
  const ResponsiveScoreStatTiles({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 360) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var index = 0; index < children.length; index++) ...[
                  SizedBox(width: double.infinity, child: children[index]),
                  if (index != children.length - 1) const SizedBox(height: 12),
                ],
              ],
            );
          }
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var index = 0; index < children.length; index++) ...[
                  if (index > 0) const SizedBox(width: 12),
                  Expanded(child: children[index]),
                ],
              ],
            ),
          );
        },
      );
}

class CollapsibleScorecardSection extends StatefulWidget {
  const CollapsibleScorecardSection(
      {super.key,
      required this.title,
      required this.count,
      required this.child,
      this.initiallyExpanded = false});
  final String title;
  final int count;
  final Widget child;
  final bool initiallyExpanded;
  @override
  State<CollapsibleScorecardSection> createState() =>
      _CollapsibleScorecardSectionState();
}

class _CollapsibleScorecardSectionState
    extends State<CollapsibleScorecardSection> {
  late bool expanded = widget.initiallyExpanded;
  @override
  Widget build(BuildContext context) => AppCard(
        padding: EdgeInsets.zero,
        elevated: false,
        child: Column(children: [
          Material(
            color: Colors.transparent,
            child: ListTile(
                dense: true,
                minTileHeight: 52,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                title: Text(widget.title,
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text('${widget.count}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary)),
                  const SizedBox(width: 4),
                  Icon(expanded ? Icons.expand_less : Icons.chevron_right,
                      size: 20),
                ]),
                onTap: () => setState(() => expanded = !expanded)),
          ),
          AnimatedSize(
              duration: const Duration(milliseconds: 220),
              child: Offstage(
                offstage: !expanded,
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                    child: widget.child),
              )),
        ]),
      );
}

class FallOfWicketEntry {
  final String score;
  final String batter;
  final String over;

  const FallOfWicketEntry({
    required this.score,
    required this.batter,
    required this.over,
  });
}

class FallOfWicketCard extends StatelessWidget {
  final List<FallOfWicketEntry> wickets;

  const FallOfWicketCard({super.key, required this.wickets});

  @override
  Widget build(BuildContext context) {
    if (wickets.isEmpty) {
      return const EmptyStateCard(
        icon: Icons.shield_outlined,
        title: 'No wickets yet',
        message: 'Fall-of-wicket details will appear here.',
      );
    }
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: [
          for (var index = 0; index < wickets.length; index++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.wicketRedLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      wickets[index].score,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.wicketRed,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(wickets[index].batter,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                  ),
                  Text('${wickets[index].over} ov',
                      style: const TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            ),
            if (index != wickets.length - 1) const Divider(),
          ],
        ],
      ),
    );
  }
}

class MatchStatisticsCard extends StatelessWidget {
  final List<StatisticData> statistics;

  const MatchStatisticsCard({super.key, required this.statistics});

  @override
  Widget build(BuildContext context) => AppCard(
        padding: const EdgeInsets.all(20),
        child: StatisticGrid(statistics: statistics),
      );
}

class StatisticData {
  final String label;
  final String value;
  final Color? color;

  const StatisticData(this.label, this.value, {this.color});
}

class StatisticGrid extends StatelessWidget {
  final List<StatisticData> statistics;

  const StatisticGrid({super.key, required this.statistics});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 600 ? 4 : 2;
          final width = (constraints.maxWidth - (12 * (columns - 1))) / columns;
          return Wrap(
            spacing: 12,
            runSpacing: 16,
            children: [
              for (final statistic in statistics)
                SizedBox(
                  width: width,
                  child: StatisticTile(
                    label: statistic.label,
                    value: statistic.value,
                    valueColor: statistic.color,
                  ),
                ),
            ],
          );
        },
      );
}

class StatisticTile extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const StatisticTile({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  )),
          const SizedBox(height: 3),
          Text(value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: valueColor ?? AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  )),
        ],
      );
}

class EmptyStateCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const EmptyStateCard({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) => AppCard(
        elevated: false,
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                color: Color(0xFFE1F2EC),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 3),
                  Text(message,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      );
}

class _AnimatedDashboardCard extends StatelessWidget {
  final Widget child;

  const _AnimatedDashboardCard({required this.child});

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        child: child,
        builder: (context, value, child) => Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 8 * (1 - value)),
            child: child,
          ),
        ),
      );
}
