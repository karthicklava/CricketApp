import 'package:meta/meta.dart';

enum BattingStyle { notSet, rightHand, leftHand }

enum BowlingStyle {
  notSet,
  none,
  rightArmFast,
  rightArmMedium,
  leftArmFast,
  leftArmMedium,
  offSpin,
  legSpin,
  leftArmOrthodox,
  leftArmWristSpin,

  // Legacy values retained for persisted matches.
  rightArmSpin,
  leftArmSpin,
}

String battingStyleAbbreviation(BattingStyle style) => switch (style) {
      BattingStyle.rightHand => 'RHB',
      BattingStyle.leftHand => 'LHB',
      BattingStyle.notSet => 'Not Set',
    };

String battingStyleLabel(BattingStyle style) => switch (style) {
      BattingStyle.rightHand => 'Right-hand batter',
      BattingStyle.leftHand => 'Left-hand batter',
      BattingStyle.notSet => 'Batting hand not set',
    };

bool isPaceBowlingStyle(BowlingStyle style) => switch (style) {
      BowlingStyle.rightArmFast ||
      BowlingStyle.rightArmMedium ||
      BowlingStyle.leftArmFast ||
      BowlingStyle.leftArmMedium =>
        true,
      _ => false,
    };

bool isSpinBowlingStyle(BowlingStyle style) => switch (style) {
      BowlingStyle.offSpin ||
      BowlingStyle.legSpin ||
      BowlingStyle.leftArmOrthodox ||
      BowlingStyle.leftArmWristSpin ||
      BowlingStyle.rightArmSpin ||
      BowlingStyle.leftArmSpin =>
        true,
      _ => false,
    };

String bowlingStyleLabel(BowlingStyle style) {
  if (isPaceBowlingStyle(style)) return 'Fast';
  if (isSpinBowlingStyle(style)) return 'Spinner';
  return switch (style) {
    BowlingStyle.none => 'Does not bowl',
    BowlingStyle.notSet => 'Not Set',
    _ => 'Not Set',
  };
}

String playerStyleSummary(BattingStyle batting, BowlingStyle bowling) =>
    '${battingStyleAbbreviation(batting)} · ${bowlingStyleLabel(bowling)}';

@immutable
class Player {
  final String id;
  final String name;
  final BattingStyle battingStyle;
  final BowlingStyle bowlingStyle;
  final String? phoneNumber;
  final String? profileImageUrl;
  final bool isLateAddition;
  final bool isEligibleBowler;
  final bool isAvailable;
  final int? joinedAt;
  final String? joinedInningsId;
  final int? joinedOverNumber;
  final int? joinedDeliverySequence;
  final bool addedToPermanentTeam;

  const Player({
    required this.id,
    required this.name,
    this.battingStyle = BattingStyle.notSet,
    this.bowlingStyle = BowlingStyle.notSet,
    this.phoneNumber,
    this.profileImageUrl,
    this.isLateAddition = false,
    this.isEligibleBowler = true,
    this.isAvailable = true,
    this.joinedAt,
    this.joinedInningsId,
    this.joinedOverNumber,
    this.joinedDeliverySequence,
    this.addedToPermanentTeam = false,
  });

  Player copyWith({bool? isAvailable}) => Player(
        id: id,
        name: name,
        battingStyle: battingStyle,
        bowlingStyle: bowlingStyle,
        phoneNumber: phoneNumber,
        profileImageUrl: profileImageUrl,
        isLateAddition: isLateAddition,
        isEligibleBowler: isEligibleBowler,
        isAvailable: isAvailable ?? this.isAvailable,
        joinedAt: joinedAt,
        joinedInningsId: joinedInningsId,
        joinedOverNumber: joinedOverNumber,
        joinedDeliverySequence: joinedDeliverySequence,
        addedToPermanentTeam: addedToPermanentTeam,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'battingStyle': battingStyle.name,
        'bowlingStyle': bowlingStyle.name,
        'phoneNumber': phoneNumber,
        'profileImageUrl': profileImageUrl,
        'isLateAddition': isLateAddition,
        'isEligibleBowler': isEligibleBowler,
        'isAvailable': isAvailable,
        'joinedAt': joinedAt,
        'joinedInningsId': joinedInningsId,
        'joinedOverNumber': joinedOverNumber,
        'joinedDeliverySequence': joinedDeliverySequence,
        'addedToPermanentTeam': addedToPermanentTeam,
      };

  factory Player.fromJson(Map<String, dynamic> json) => Player(
        id: json['id'] as String,
        name: json['name'] as String,
        battingStyle: BattingStyle.values.firstWhere(
          (e) => e.name == json['battingStyle'],
          orElse: () => BattingStyle.notSet,
        ),
        bowlingStyle: BowlingStyle.values.firstWhere(
          (e) => e.name == json['bowlingStyle'],
          orElse: () => BowlingStyle.notSet,
        ),
        phoneNumber: json['phoneNumber'] as String?,
        profileImageUrl: json['profileImageUrl'] as String?,
        isLateAddition: json['isLateAddition'] as bool? ?? false,
        isEligibleBowler: json['isEligibleBowler'] as bool? ?? true,
        isAvailable: json['isAvailable'] as bool? ?? true,
        joinedAt: json['joinedAt'] as int?,
        joinedInningsId: json['joinedInningsId'] as String?,
        joinedOverNumber: json['joinedOverNumber'] as int?,
        joinedDeliverySequence: json['joinedDeliverySequence'] as int?,
        addedToPermanentTeam: json['addedToPermanentTeam'] as bool? ?? false,
      );
}
