import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'profile_notifier.dart';
import '../common/widgets/cricket_badge_widget.dart';
import '../common/widgets/brand_logo.dart';
import '../../core/theme.dart';
import '../common/widgets/sports_ui.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return const Color(0xFF0D6EFD);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileNotifierProvider);
    final primaryColor = _parseColor(profile.primaryColorHex);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            BrandLogo(size: 32),
            SizedBox(width: 10),
            Text('Profile & Personalization'),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 104),
        children: [
          // User Header Banner Card
          AppCard(
            padding: const EdgeInsets.all(24),
            color: const Color(0xFFE8F4F0),
            child: Column(
              children: [
                CricketBadgeWidget(
                  jerseyNumber: profile.jerseyNumberDisplay,
                  style: profile.iconStyle,
                  primaryColor: primaryColor,
                  size: 96,
                ),
                const SizedBox(height: 12),
                Text(
                  profile.userName,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Chip(
                  avatar:
                      const Icon(Icons.numbers, size: 16, color: Colors.white),
                  label: Text('Jersey #${profile.jerseyNumberDisplay}',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  backgroundColor: primaryColor,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Customization Actions
          AppCard(
            padding: EdgeInsets.zero,
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: const CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.palette_rounded,
                      color: Colors.white, size: 20)),
              title: const Text('Personalize identity',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle:
                  const Text('Jersey number, badge style, and team colors'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.push('/profile/personalize'),
            ),
          ),
          const SizedBox(height: 12),

          // PDF Privacy Settings
          AppCard(
            padding: EdgeInsets.zero,
            child: SwitchListTile(
              contentPadding: const EdgeInsets.all(16),
              secondary: const Icon(Icons.picture_as_pdf_rounded,
                  color: AppColors.primary),
              title: const Text('Profile in PDF scorecards'),
              subtitle: Text(profile.includeProfileInPdf
                  ? 'Scorecards show your scorer identity.'
                  : 'Profile details are hidden from PDF exports.'),
              value: profile.includeProfileInPdf,
              onChanged: (val) {
                ref.read(profileNotifierProvider.notifier).setPdfPrivacy(val);
              },
            ),
          ),
          const SizedBox(height: 12),

          AppCard(
            padding: EdgeInsets.zero,
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: const CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Icon(Icons.app_shortcut, color: Colors.white),
              ),
              title: const Text('Launcher Icon',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Put your jersey number on the app icon'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.push('/profile/launcher-icon'),
            ),
          ),

          // Developer Options
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('DEVELOPER OPTIONS',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          ListTile(
            leading: const Icon(Icons.bug_report, color: Colors.deepOrange),
            title: const Text('Explore Demo Match'),
            subtitle: const Text('Launch isolated demo scoring session'),
            onTap: () => context.push('/demo-scoring'),
          ),
        ],
      ),
    );
  }
}
