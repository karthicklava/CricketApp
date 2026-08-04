import 'package:flutter/material.dart';

class LiveMatchRecoveryScreen extends StatelessWidget {
  final String matchId;
  final String reason;

  const LiveMatchRecoveryScreen({
    super.key,
    required this.matchId,
    required this.reason,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Resume Match')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning_amber_rounded, size: 56),
                const SizedBox(height: 16),
                const Text(
                  'Unable to resume scoring because the live match state is incomplete.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(reason, textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text('Match ID: $matchId',
                    style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () => Navigator.maybePop(context),
                  icon: const Icon(Icons.manage_search),
                  label: const Text('Review Match State'),
                ),
              ],
            ),
          ),
        ),
      );
}
