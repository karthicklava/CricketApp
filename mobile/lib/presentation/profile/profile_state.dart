import 'package:flutter/foundation.dart';

enum CricketIconStyle {
  shield,
  jersey,
  ball,
  wickets,
  captain,
}

@immutable
class ProfileState {
  final String userName;
  final String jerseyNumberDisplay;
  final int jerseyNumberValue;
  final CricketIconStyle iconStyle;
  final String primaryColorHex;
  final bool includeProfileInPdf;

  const ProfileState({
    required this.userName,
    required this.jerseyNumberDisplay,
    required this.jerseyNumberValue,
    required this.iconStyle,
    required this.primaryColorHex,
    required this.includeProfileInPdf,
  });

  factory ProfileState.defaultProfile() => const ProfileState(
        userName: 'Guest Scorer',
        jerseyNumberDisplay: '18',
        jerseyNumberValue: 18,
        iconStyle: CricketIconStyle.shield,
        primaryColorHex: '#0D6EFD',
        includeProfileInPdf: false,
      );

  ProfileState copyWith({
    String? userName,
    String? jerseyNumberDisplay,
    int? jerseyNumberValue,
    CricketIconStyle? iconStyle,
    String? primaryColorHex,
    bool? includeProfileInPdf,
  }) {
    return ProfileState(
      userName: userName ?? this.userName,
      jerseyNumberDisplay: jerseyNumberDisplay ?? this.jerseyNumberDisplay,
      jerseyNumberValue: jerseyNumberValue ?? this.jerseyNumberValue,
      iconStyle: iconStyle ?? this.iconStyle,
      primaryColorHex: primaryColorHex ?? this.primaryColorHex,
      includeProfileInPdf: includeProfileInPdf ?? this.includeProfileInPdf,
    );
  }
}
