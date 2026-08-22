import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'turfscore_coin_widget.dart';

/// Represents the data output from a completed Digital Coin Toss
class DigitalCoinTossResult {
  final String tossCallingTeamId;
  final String tossCall; // 'HEADS' or 'TAILS'
  final String coinResult; // 'HEADS' or 'TAILS'
  final String tossWinnerTeamId;
  final String tossDecision; // 'BAT' or 'BOWL'

  const DigitalCoinTossResult({
    required this.tossCallingTeamId,
    required this.tossCall,
    required this.coinResult,
    required this.tossWinnerTeamId,
    required this.tossDecision,
  });
}

class DigitalCoinTossWidget extends StatefulWidget {
  final String teamAId;
  final String teamAName;
  final String teamBId;
  final String teamBName;

  final String? initialCallingTeamId;
  final String? initialTossCall;
  final String? initialCoinResult;
  final String? initialTossWinnerId;
  final String? initialTossDecision;

  final ValueChanged<DigitalCoinTossResult>? onTossCompleted;
  final VoidCallback? onTossReset;
  final VoidCallback? onConfirmToss;

  const DigitalCoinTossWidget({
    super.key,
    required this.teamAId,
    required this.teamAName,
    required this.teamBId,
    required this.teamBName,
    this.initialCallingTeamId,
    this.initialTossCall,
    this.initialCoinResult,
    this.initialTossWinnerId,
    this.initialTossDecision,
    this.onTossCompleted,
    this.onTossReset,
    this.onConfirmToss,
  });

  @override
  State<DigitalCoinTossWidget> createState() => _DigitalCoinTossWidgetState();
}

class _DigitalCoinTossWidgetState extends State<DigitalCoinTossWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _flipAnimation;
  late Animation<double> _heightAnimation;

  String? _callingTeamId;
  String? _tossCall; // 'HEADS' or 'TAILS'
  String? _coinResult; // 'HEADS' or 'TAILS'
  String? _tossWinnerId;
  String _tossDecision = 'BAT'; // 'BAT' or 'BOWL'

  bool _isFlipping = false;
  bool _hasCompletedToss = false;

  @override
  void initState() {
    super.initState();
    _callingTeamId = widget.initialCallingTeamId;
    _tossCall = widget.initialTossCall;
    _coinResult = widget.initialCoinResult;
    _tossWinnerId = widget.initialTossWinnerId;
    _tossDecision = widget.initialTossDecision ?? 'BAT';

    if (_coinResult != null && _tossWinnerId != null) {
      _hasCompletedToss = true;
    }

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );

    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.decelerate,
      ),
    );

    _heightAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: -70)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 45,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -70, end: 0)
            .chain(CurveTween(curve: Curves.bounceOut)),
        weight: 55,
      ),
    ]).animate(_animController);

    _animController.addListener(() {
      if (_animController.isAnimating) {
        // Subtle periodic haptic clicks during spin
        final progress = _animController.value;
        if ((progress * 12).floor() != ((progress - 0.08) * 12).floor()) {
          HapticFeedback.selectionClick();
        }
      }
    });

    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        HapticFeedback.heavyImpact();
        setState(() {
          _isFlipping = false;
          _hasCompletedToss = true;
        });
        _notifyTossChanged();
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _notifyTossChanged() {
    if (_tossWinnerId != null &&
        _callingTeamId != null &&
        _tossCall != null &&
        _coinResult != null) {
      widget.onTossCompleted?.call(
        DigitalCoinTossResult(
          tossCallingTeamId: _callingTeamId!,
          tossCall: _tossCall!,
          coinResult: _coinResult!,
          tossWinnerTeamId: _tossWinnerId!,
          tossDecision: _tossDecision,
        ),
      );
    } else {
      widget.onTossReset?.call();
    }
  }

  void _executeFlip() {
    if (_isFlipping || _callingTeamId == null || _tossCall == null) return;

    HapticFeedback.mediumImpact();

    // Random toss result generation
    final isHeads = math.Random().nextBool();
    final resultStr = isHeads ? 'HEADS' : 'TAILS';

    // Calculate toss winner
    final callingTeamWins = (_tossCall == resultStr);
    final winnerId = callingTeamWins
        ? _callingTeamId!
        : (_callingTeamId == widget.teamAId ? widget.teamBId : widget.teamAId);

    setState(() {
      _coinResult = resultStr;
      _tossWinnerId = winnerId;
      _isFlipping = true;
      _hasCompletedToss = false;
    });

    _animController.forward(from: 0);
  }

  Future<void> _requestReToss() async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.replay_rounded,
                  color: Color(0xFF0F5132),
                  size: 26,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Re-Toss Coin?',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Are you sure you want to re-toss?\nThe current toss result will be cleared so you can flip again.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF374151),
                          side: const BorderSide(color: Color(0xFFD1D5DB)),
                          shape: const StadiumBorder(),
                        ),
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF0F5132),
                          foregroundColor: Colors.white,
                          shape: const StadiumBorder(),
                          elevation: 2,
                        ),
                        onPressed: () => Navigator.of(ctx).pop(true),
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text(
                          'Re-Toss',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true && mounted) {
      HapticFeedback.lightImpact();
      setState(() {
        _callingTeamId = null;
        _tossCall = null;
        _coinResult = null;
        _tossWinnerId = null;
        _hasCompletedToss = false;
        _isFlipping = false;
      });
      _notifyTossChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    final callingTeamName = _callingTeamId == widget.teamAId
        ? widget.teamAName
        : (_callingTeamId == widget.teamBId ? widget.teamBName : '');
    final winnerTeamName = _tossWinnerId == widget.teamAId
        ? widget.teamAName
        : (_tossWinnerId == widget.teamBId ? widget.teamBName : '');
    final losingTeamName = _tossWinnerId == widget.teamAId
        ? widget.teamBName
        : widget.teamAName;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAF9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            // Stage 1: Select Calling Team
            if (_callingTeamId == null) ...[
              const Text(
                'WHO WILL CALL?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F5132),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Select the team calling the coin toss',
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildChoiceTile(
                      title: widget.teamAName,
                      icon: Icons.shield_outlined,
                      isSelected: false,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _callingTeamId = widget.teamAId);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildChoiceTile(
                      title: widget.teamBName,
                      icon: Icons.shield_outlined,
                      isSelected: false,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _callingTeamId = widget.teamBId);
                      },
                    ),
                  ),
                ],
              ),
            ]
            // Stage 2: Select Call (HEADS or TAILS)
            else if (_tossCall == null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$callingTeamName is calling',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F5132),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      setState(() => _callingTeamId = null);
                      _notifyTossChanged();
                    },
                    icon: const Icon(Icons.edit, size: 14),
                    label: const Text('Change Team', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'CHOOSE YOUR CALL',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F5132),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildChoiceTile(
                      title: 'HEADS',
                      subtitle: 'TurfScore Crest',
                      icon: Icons.monetization_on_outlined,
                      isSelected: false,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _tossCall = 'HEADS');
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildChoiceTile(
                      title: 'TAILS',
                      subtitle: 'Crossed Bats',
                      icon: Icons.sports_cricket_outlined,
                      isSelected: false,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _tossCall = 'TAILS');
                      },
                    ),
                  ),
                ],
              ),
            ]
            // Stage 3 & 4 & 5: Interactive 3D Coin Flip + Results
            else ...[
              // Setup Info Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFA5D6A7)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.stars, color: Color(0xFF0F5132), size: 18),
                    const SizedBox(width: 6),
                    Text(
                      '$callingTeamName called $_tossCall',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F5132),
                      ),
                    ),
                    if (!_hasCompletedToss && !_isFlipping) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          setState(() => _tossCall = null);
                          _notifyTossChanged();
                        },
                        child: const Icon(Icons.edit_outlined,
                            size: 16, color: Color(0xFF0F5132)),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Animated 3D Coin Container
              GestureDetector(
                onTap: (!_isFlipping && !_hasCompletedToss) ? _executeFlip : null,
                onVerticalDragEnd: (!_isFlipping && !_hasCompletedToss)
                    ? (_) => _executeFlip()
                    : null,
                child: AnimatedBuilder(
                  animation: _animController,
                  builder: (context, child) {
                    final spinTurns = 4; // 4 full 3D flips
                    final targetFaceAngle =
                        (_coinResult == 'TAILS') ? math.pi : 0.0;
                    final currentRotationY =
                        (_flipAnimation.value * spinTurns * 2 * math.pi) +
                            (_flipAnimation.value * targetFaceAngle);
                    final offsetY = _heightAnimation.value;

                    return Transform.translate(
                      offset: Offset(0, offsetY),
                      child: TurfScoreCoinWidget(
                        side: _coinResult ?? _tossCall ?? 'HEADS',
                        size: 190,
                        rotationY: _isFlipping ? currentRotationY : (_hasCompletedToss && _coinResult == 'TAILS' ? math.pi : 0),
                        rotationX: math.sin(_animController.value * math.pi * 2) * 0.15,
                        sheenProgress: _animController.value,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Action CTA / Result Announcement
              if (!_hasCompletedToss && !_isFlipping) ...[
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F5132),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 52),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _executeFlip,
                  icon: const Icon(Icons.touch_app_rounded),
                  label: const Text(
                    'FLIP THE COIN',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Tap or swipe coin to flip',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ] else if (_isFlipping) ...[
                const Text(
                  'Flipping Coin...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F5132),
                  ),
                ),
              ] else if (_hasCompletedToss) ...[
                // Announcement Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFD0E1D4)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(12),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${_coinResult!}!',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFD4AF37),
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$callingTeamName called $_tossCall.',
                        style: const TextStyle(
                            fontSize: 13, color: Colors.black87),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F5132),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '🎉 $winnerTeamName WON THE TOSS',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Decision Stage: BAT vs BOWL
                Text(
                  '$winnerTeamName, what do you choose?',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F5132),
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildChoiceChip(
                        label: '🏏 BAT',
                        isSelected: _tossDecision == 'BAT',
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _tossDecision = 'BAT');
                          _notifyTossChanged();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildChoiceChip(
                        label: '🎯 BOWL',
                        isSelected: _tossDecision == 'BOWL',
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _tossDecision = 'BOWL');
                          _notifyTossChanged();
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Summary Confirmation Box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFEBE9).withAlpha(120),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFD7CCC8)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TOSS RESULT',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Colors.black54,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$winnerTeamName won the toss and elected to ${_tossDecision.toLowerCase()}.',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${_tossDecision == 'BAT' ? winnerTeamName : losingTeamName}\nBATTING FIRST 🏏',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F5132),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '${_tossDecision == 'BAT' ? losingTeamName : winnerTeamName}\nBOWLING FIRST 🎯',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1565C0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Bottom Action Buttons: Re-Toss & Confirm
                Row(
                  children: [
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red.shade700,
                        side: BorderSide(color: Colors.red.shade300),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _requestReToss,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Re-Toss'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F5132),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          _notifyTossChanged();
                          widget.onConfirmToss?.call();
                        },
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text(
                          'CONFIRM TOSS',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceTile({
    required String title,
    String? subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F5E9) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF0F5132)
                : const Color(0xFFCBD5E1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF0F5132) : Colors.black54,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: isSelected ? const Color(0xFF0F5132) : Colors.black87,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: isSelected
                      ? const Color(0xFF0F5132).withAlpha(180)
                      : Colors.grey.shade600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F5132) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF0F5132) : Colors.grey.shade400,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF0F5132).withAlpha(60),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  )
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: isSelected ? Colors.white : const Color(0xFF0F5132),
              letterSpacing: 0.8,
            ),
          ),
        ),
      ),
    );
  }
}
