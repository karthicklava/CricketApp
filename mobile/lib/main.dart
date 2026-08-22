import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cricket_scoring_engine/cricket_scoring_engine.dart';
import 'core/theme.dart';
import 'core/navigation/match_destination.dart';
import 'core/services/launcher_icon_service.dart';
import 'data/local/database.dart';
import 'data/repositories/team_repository.dart';
import 'data/repositories/match_repository.dart';
import 'data/repositories/completed_scorecard_repository.dart';
import 'presentation/home/home_dashboard_state.dart';
import 'presentation/home/home_dashboard_notifier.dart';
import 'presentation/scoring/scoring_screen.dart';
import 'presentation/scoring/widgets/match_result_view.dart';
import 'presentation/scorecard/scorecard_screen.dart';
import 'presentation/teams/create_team_screen.dart';
import 'presentation/teams/teams_list_screen.dart';
import 'presentation/teams/team_details_screen.dart';
import 'presentation/teams/add_players_screen.dart';
import 'presentation/teams/widgets/team_card.dart';
import 'presentation/matches/match_setup_wizard.dart';
import 'presentation/matches/widgets/draft_match_card.dart';
import 'presentation/common/widgets/draft_delete_dialog.dart';
import 'core/utils/match_datetime_formatter.dart';
import 'presentation/demo/demo_scoring_screen.dart';
import 'presentation/matches/completed_match_details_screen.dart';
import 'presentation/matches/pdf_preview_screen.dart';
import 'presentation/matches/live_match_recovery_screen.dart';
import 'presentation/profile/personalization_screen.dart';
import 'presentation/profile/profile_screen.dart';
import 'presentation/profile/launcher_icon_screen.dart';
import 'presentation/profile/profile_notifier.dart';
import 'presentation/common/widgets/cricket_badge_widget.dart';
import 'presentation/common/widgets/brand_logo.dart';
import 'presentation/common/widgets/live_match_header.dart';
import 'presentation/common/widgets/sports_ui.dart';
import 'presentation/splash/turf_score_splash_screen.dart';

// Global Providers
final databaseProvider = Provider((ref) => AppDatabase());
final sharedPrefsProvider =
    Provider<SharedPreferences>((ref) => throw UnimplementedError());

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPrefsProvider.overrideWithValue(prefs),
      ],
      child: const CricketApp(),
    ),
  );
  WidgetsBinding.instance.addPostFrameCallback((_) {
    LauncherIconService(prefs).normalizePersistedState();
  });
}

class CricketApp extends ConsumerWidget {
  const CricketApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'TurfScore',
      theme: AppTheme.lightTheme,
      routerConfig: _router(ref),
      debugShowCheckedModeBanner: false,
      builder: (context, child) => TurfScoreStartupGate(
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}

// Navigation Key setup
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

GoRouter _router(WidgetRef ref) => GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/welcome',
          builder: (context, state) => const WelcomeScreen(),
        ),
        GoRoute(
          path: '/demo-scoring',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const DemoScoringScreen(),
        ),
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) => MainScaffold(child: child),
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const HomeScreen(),
            ),
            GoRoute(
              path: '/matches',
              builder: (context, state) => const MatchesScreen(),
            ),
            GoRoute(
              path: '/score',
              builder: (context, state) => const ScoreTabScreen(),
            ),
            GoRoute(
              path: '/teams',
              builder: (context, state) => const TeamsListScreen(),
            ),
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/teams/create',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) {
            final id = state.uri.queryParameters['id'];
            return CreateTeamScreen(initialTeamId: id);
          },
        ),
        GoRoute(
          path: '/teams/details',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) =>
              TeamDetailsScreen(team: state.extra as TeamsTableData),
        ),
        GoRoute(
          path: '/teams/add-players/:teamId',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => AddPlayersScreen(
            teamId: state.pathParameters['teamId']!,
            returnToMatchSetup:
                state.uri.queryParameters['returnToMatchSetup'] == 'true',
          ),
        ),
        GoRoute(
          path: '/matches/create',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) {
            final preselectId = state.uri.queryParameters['preselectTeamId'];
            final draftId = state.uri.queryParameters['draftId'];
            return MatchSetupWizard(
              preselectTeamId: preselectId,
              draftId: draftId,
            );
          },
        ),
        GoRoute(
          path: '/matches/:matchId/scoring',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) {
            final matchId = state.pathParameters['matchId']!;
            final matchState = state.extra as MatchState?;
            if (matchState != null) {
              if (_isTerminalMatch(matchState)) {
                return _terminalMatchScreen(matchState);
              }
              final validation =
                  MatchDestinationResolver.validateLiveState(matchState);
              if (validation != null) {
                return LiveMatchRecoveryScreen(
                    matchId: matchId, reason: validation);
              }
              return LiveScoringScreen(
                  initialMatchState: matchState, deviceId: 'device_123');
            }
            return FutureBuilder<MatchState?>(
              future: ref.read(matchRepositoryProvider).getMatchState(matchId),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Scaffold(
                      body: Center(child: CircularProgressIndicator()));
                }
                if (snapshot.hasError || snapshot.data == null) {
                  return LiveMatchRecoveryScreen(
                    matchId: matchId,
                    reason: snapshot.hasError
                        ? snapshot.error.toString()
                        : 'The saved match state could not be found.',
                  );
                }
                if (_isTerminalMatch(snapshot.data!)) {
                  return _terminalMatchScreen(snapshot.data!);
                }
                final validation = MatchDestinationResolver.validateLiveState(
                  snapshot.data,
                );
                if (validation != null) {
                  return LiveMatchRecoveryScreen(
                    matchId: matchId,
                    reason: validation,
                  );
                }
                return LiveScoringScreen(
                    initialMatchState: snapshot.data!, deviceId: 'device_123');
              },
            );
          },
        ),
        GoRoute(
          path: '/scoring',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) {
            final matchState = state.extra as MatchState?;
            if (matchState != null) {
              return LiveScoringScreen(
                initialMatchState: matchState,
                deviceId: 'device_123',
              );
            }
            return FutureBuilder<MatchesTableData?>(
              future: ref.read(matchRepositoryProvider).getActiveMatch(),
              builder: (context, snapshot) {
                final active = snapshot.data;
                if (active == null) {
                  return const Scaffold(
                      body: Center(child: Text('No active match found.')));
                }
                return FutureBuilder<MatchState?>(
                  future: ref
                      .read(matchRepositoryProvider)
                      .getMatchState(active.id),
                  builder: (context, snap2) {
                    if (!snap2.hasData) {
                      return const Scaffold(
                          body: Center(child: CircularProgressIndicator()));
                    }
                    if (_isTerminalMatch(snap2.data!)) {
                      return _terminalMatchScreen(snap2.data!);
                    }
                    return LiveScoringScreen(
                        initialMatchState: snap2.data!, deviceId: 'device_123');
                  },
                );
              },
            );
          },
        ),
        GoRoute(
          path: '/scorecard',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) {
            final engine = state.extra as CricketScoringEngine;
            return ScorecardScreen(engine: engine);
          },
        ),
        GoRoute(
          path: '/matches/history/:matchId',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) {
            final matchId = state.pathParameters['matchId']!;
            final repository = CompletedScorecardRepository(
              ref.read(matchRepositoryProvider),
            );
            return FutureBuilder<CompletedMatchScorecard>(
              future: repository.loadCompletedScorecard(matchId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Scaffold(
                      body: Center(child: CircularProgressIndicator()));
                }
                return CompletedMatchDetailsScreen(
                  matchState: snapshot.data!.matchState,
                );
              },
            );
          },
        ),
        GoRoute(
          path: '/matches/history/:matchId/pdf',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) {
            final matchId = state.pathParameters['matchId']!;
            final repository = CompletedScorecardRepository(
              ref.read(matchRepositoryProvider),
            );
            return FutureBuilder<CompletedMatchScorecard>(
              future: repository.loadCompletedScorecard(matchId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Scaffold(
                    appBar: AppBar(title: const Text('PDF Scorecard')),
                    body: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          snapshot.error.toString(),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                }
                if (!snapshot.hasData) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                return PdfPreviewScreen(
                  matchState: snapshot.data!.matchState,
                );
              },
            );
          },
        ),
        GoRoute(
          path: '/profile/personalize',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const PersonalizationScreen(),
        ),
        GoRoute(
          path: '/profile/launcher-icon',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const LauncherIconScreen(),
        ),
      ],
    );

bool _isTerminalMatch(MatchState state) =>
    MatchDestinationResolver.isReadOnlyStatus(state.status);

Widget _terminalMatchScreen(MatchState state) {
  if (state.status == MatchStatus.completed) {
    final engine = CricketScoringEngine(state);
    return MatchResultView(matchState: state, engine: engine);
  }
  return CompletedMatchDetailsScreen(matchState: state);
}

class MainScaffold extends StatelessWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    int getIndex() {
      if (location == '/') return 0;
      if (location.startsWith('/matches')) return 1;
      if (location.startsWith('/score')) return 2;
      if (location.startsWith('/teams')) return 3;
      if (location.startsWith('/profile')) return 4;
      return 0;
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: PremiumBottomNavigation(
        selectedIndex: getIndex(),
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go('/');
              break;
            case 1:
              context.go('/matches');
              break;
            case 2:
              context.go('/score');
              break;
            case 3:
              context.go('/teams');
              break;
            case 4:
              context.go('/profile');
              break;
          }
        },
      ),
    );
  }
}

// --- Welcome Screen ---

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.sports_cricket,
                  size: 90, color: AppColors.primary),
              const SizedBox(height: 24),
              const Text(
                'Welcome to TurfScore',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Create your first team and add players to begin scoring.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => context.push('/teams/create'),
                  child: const Text('Create Your First Team',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.push('/demo-scoring'),
                child: const Text('Explore Demo',
                    style: TextStyle(color: Colors.grey, fontSize: 15)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Reactive Home Screen Dashboard ---

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeDashboardStateProvider);

    // 1. Loading State: Do NOT prematurely display 0-team empty state
    if (homeState.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // 2. Stage 1: No Teams (0 teams in SQLite)
    if (homeState.stage == HomeStage.noTeams) {
      return const WelcomeScreen();
    }

    final profile = ref.watch(profileNotifierProvider);
    Color primaryColor = const Color(0xFF0D6EFD);
    try {
      primaryColor =
          Color(int.parse(profile.primaryColorHex.replaceFirst('#', '0xFF')));
    } catch (_) {}

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            BrandLogo(size: 34),
            SizedBox(width: 10),
            Text('TurfScore'),
          ],
        ),
        actions: [
          IconButton(
            icon: CricketBadgeWidget(
              jerseyNumber: profile.jerseyNumberDisplay,
              style: profile.iconStyle,
              primaryColor: primaryColor,
              size: 32,
            ),
            tooltip: 'Profile & Settings',
            onPressed: () => context.push('/profile'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          // Active Match / Resume Banner if present
          if (homeState.activeMatch != null) ...[
            AppCard(
              color: AppColors.primary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FutureBuilder<MatchState?>(
                    future: ref
                        .read(matchRepositoryProvider)
                        .getMatchState(homeState.activeMatch!.id),
                    builder: (context, snapshot) {
                      final matchState = snapshot.data;
                      if (matchState == null || matchState.innings.isEmpty) {
                        return const Text('Match ready to resume',
                            style: TextStyle(color: Colors.white70));
                      }
                      return LiveMatchSummaryCard.fromMatchState(
                        matchState,
                        variant: LiveMatchCardVariant.homeFeatured,
                        darkSurface: true,
                        onResume: () => context.push(
                          MatchDestinationResolver.routeFor(
                            matchId: homeState.activeMatch!.id,
                            status: homeState.activeMatch!.status,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Stage 2: Exactly 1 Team Created
          if (homeState.stage == HomeStage.oneTeam) ...[
            Card(
              color: AppColors.primary,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your first team is ready!',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Create one more team to set up your first match.',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: AppCtaStyle.height,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primary),
                        icon: const Icon(Icons.group_add),
                        label: const Text('CREATE SECOND TEAM',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: () => context.push('/teams/create'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Display Created Team Card
            if (homeState.teams.isNotEmpty) ...[
              _buildSectionHeader(
                title: 'My Teams',
                count: homeState.teams.length,
                showViewAll: homeState.teams.length > 3,
                onViewAll: () => context.go('/teams'),
              ),
              const SizedBox(height: 10),
              _buildTeamCard(context, ref, homeState.teams.first),
              const SizedBox(height: 16),
            ],

            // Restricted Match Creation Warning
            Card(
              color: Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: const [
                    Icon(Icons.info_outline, color: Colors.orange),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'You need at least two teams to create a match.',
                        style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Stage 3 & Match Ready Dashboard
          if (homeState.stage == HomeStage.readyForMatch ||
              homeState.stage == HomeStage.matchInProgress) ...[
            if (homeState.activeMatch == null)
              Row(
                children: [
                  Expanded(
                    child: _buildActionCard(
                      context,
                      title: 'Create Match',
                      icon: Icons.stadium_rounded,
                      color: AppColors.primary,
                      onTap: () => context.push('/matches/create'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionCard(
                      context,
                      title: 'Create Team',
                      icon: Icons.groups_3_rounded,
                      color: AppColors.accent,
                      onTap: () => context.push('/teams/create'),
                    ),
                  ),
                ],
              )
            else
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  'New match creation is unavailable while this match is live.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            const SizedBox(height: 24),

            // Teams Overview
            _buildSectionHeader(
              title: 'My Teams',
              count: homeState.teams.length,
              showViewAll: homeState.teams.length > 3,
              onViewAll: () => context.go('/teams'),
            ),
            const SizedBox(height: 10),
            ...homeState.teams
                .take(3)
                .map((team) => _buildTeamCard(context, ref, team)),
            const SizedBox(height: 24),
          ],

          // Draft Matches Section
          if (homeState.activeMatch == null && homeState.drafts.isNotEmpty) ...[
            _buildSectionHeader(
              title: 'Draft Matches',
              count: homeState.drafts.length,
              showViewAll: homeState.drafts.length > 2,
              onViewAll: () => context.go('/matches'),
            ),
            const SizedBox(height: 10),
            ...homeState.drafts.take(2).map((m) => DraftMatchCard(
                  key: ValueKey('home-draft-card-${m.id}'),
                  match: m,
                  onResume: () => context.push('/matches/create?draftId=${m.id}'),
                  onDelete: () async {
                    try {
                      await ref
                          .read(matchRepositoryProvider)
                          .deleteDraftMatch(m.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Draft deleted'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to delete draft: $e')),
                        );
                      }
                    }
                  },
                )),
            const SizedBox(height: 24),
          ],

          // Recent Matches Section
          if (homeState.stage == HomeStage.readyForMatch ||
              homeState.stage == HomeStage.matchInProgress) ...[
            Builder(
              builder: (context) {
                final sortedRecent =
                    List<MatchesTableData>.from(homeState.recentMatches)
                      ..sort((a, b) {
                        final timeA = a.endedAt ?? a.startedAt ?? a.createdAt;
                        final timeB = b.endedAt ?? b.startedAt ?? b.createdAt;
                        return timeB.compareTo(timeA);
                      });
                final hasMoreThan3 = sortedRecent.length > 3;
                final displayMatches = sortedRecent.take(3).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                      title: 'Recent Matches',
                      showViewAll: hasMoreThan3,
                      onViewAll: () => context.go('/matches'),
                    ),
                    const SizedBox(height: 10),
                    if (sortedRecent.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: 24, horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.08),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.sports_cricket_rounded,
                                color: AppColors.primary,
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'No matches yet',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Create your first match and start scoring.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6B7280),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 14),
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side:
                                    const BorderSide(color: AppColors.primary),
                                shape: const StadiumBorder(),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                              ),
                              icon: const Icon(Icons.add_rounded, size: 18),
                              label: const Text(
                                'Create Match',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              onPressed: () => context.push('/matches/create'),
                            ),
                          ],
                        ),
                      )
                    else
                      ...displayMatches
                          .map((m) => _buildRecentMatchCard(context, m)),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }

  Widget _buildTeamCard(
      BuildContext context, WidgetRef ref, TeamsTableData team) {
    return FutureBuilder<List<PlayersTableData>>(
      future: ref.read(teamRepositoryProvider).getTeamPlayers(team.id),
      builder: (context, snapshot) {
        final players = snapshot.data ?? [];
        return TeamCard(
          team: team,
          players: players,
          onTap: () => context.push('/teams/details', extra: team),
          onAddPlayers: () => context.push('/teams/add-players/${team.id}'),
          onEditTeam: () => context.push('/teams/create?id=${team.id}'),
        );
      },
    );
  }

  Widget _buildActionCard(BuildContext context,
      {required String title,
      required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return Semantics(
      button: true,
      label: title,
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        child: Column(
          children: [
            CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.1),
                radius: 20,
                child: Icon(icon, color: color, size: 22)),
            const SizedBox(height: 8),
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    int? count,
    required bool showViewAll,
    required VoidCallback onViewAll,
  }) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        if (count != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
        ],
        const Spacer(),
        if (showViewAll)
          InkWell(
            onTap: onViewAll,
            borderRadius: BorderRadius.circular(6),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View All',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: 2),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 14,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRecentMatchCard(BuildContext context, MatchesTableData m) {
    final dateMillis = m.endedAt ?? m.startedAt ?? m.createdAt;
    final dateStr = MatchDateTimeFormatter.date(
      DateTime.fromMillisecondsSinceEpoch(dateMillis),
    );
    final destination = MatchDestinationResolver.resolveStatus(m.status);
    final isCompleted = destination == MatchDestination.completedScorecard;
    final statusLabel = m.status == 'completed'
        ? 'Completed'
        : m.status == 'noResult'
            ? 'No result'
            : m.resultType == 'teamForfeit'
                ? 'Forfeit'
                : m.status;

    final statusTone = isCompleted
        ? StatusBadgeTone.success
        : m.status == 'abandoned' || m.status == 'cancelled'
            ? StatusBadgeTone.danger
            : StatusBadgeTone.warning;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          key: ValueKey('recent-match-card-${m.id}'),
          onTap: () => context.push(
            MatchDestinationResolver.routeFor(
              matchId: m.id,
              status: m.status,
            ),
          ),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        m.matchName ?? 'Match ${m.id}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color(0xFF111827),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    StatusBadge(
                      label: statusLabel,
                      tone: statusTone,
                    ),
                  ],
                ),
                if (m.resultText != null && m.resultText!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    m.resultText!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      '${m.format.toUpperCase()} • ${m.totalOvers != null ? "${m.totalOvers} Overs • " : ""}$dateStr',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    if (m.venueName != null && m.venueName!.trim().isNotEmpty) ...[
                      const Spacer(),
                      Flexible(
                        child: Text(
                          m.venueName!.trim(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9CA3AF),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MatchesScreen extends ConsumerStatefulWidget {
  const MatchesScreen({super.key});

  @override
  ConsumerState<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends ConsumerState<MatchesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all';
  bool _sortNewestFirst = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final matchesAsync = ref.watch(matchRepositoryProvider).getAllMatches();

    return Scaffold(
      appBar: AppBar(title: const Text('Match History')),
      body: FutureBuilder<List<MatchesTableData>>(
        future: matchesAsync,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var matches = snapshot.data ?? [];

          // Filtering
          if (_selectedFilter == 'completed') {
            matches = matches.where((m) => m.status == 'completed').toList();
          } else if (_selectedFilter == 'draft') {
            matches = matches
                .where((m) =>
                    MatchDestinationResolver.resolveStatus(m.status) ==
                        MatchDestination.setup ||
                    MatchDestinationResolver.resolveStatus(m.status) ==
                        MatchDestination.liveScoring ||
                    MatchDestinationResolver.resolveStatus(m.status) ==
                        MatchDestination.inningsBreak)
                .toList();
          }

          // Search query
          final query = _searchController.text.trim().toLowerCase();
          if (query.isNotEmpty) {
            matches = matches.where((m) {
              final name = (m.matchName ?? '').toLowerCase();
              final venue = (m.venueName ?? '').toLowerCase();
              return name.contains(query) || venue.contains(query);
            }).toList();
          }

          // Sorting
          matches.sort((a, b) => _sortNewestFirst
              ? b.createdAt.compareTo(a.createdAt)
              : a.createdAt.compareTo(b.createdAt));

          return Column(
            children: [
              // Search & Filter Header
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    PremiumSearchBar(
                      controller: _searchController,
                      hintText: 'Search matches, teams, or venues',
                      onChanged: (val) => setState(() {}),
                      onClear: () {
                        _searchController.clear();
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ChoiceChip(
                          label: const Text('All'),
                          selected: _selectedFilter == 'all',
                          onSelected: (val) =>
                              setState(() => _selectedFilter = 'all'),
                        ),
                        const SizedBox(width: 6),
                        ChoiceChip(
                          label: const Text('Completed'),
                          selected: _selectedFilter == 'completed',
                          onSelected: (val) =>
                              setState(() => _selectedFilter = 'completed'),
                        ),
                        const SizedBox(width: 6),
                        ChoiceChip(
                          label: const Text('Drafts / Active'),
                          selected: _selectedFilter == 'draft',
                          onSelected: (val) =>
                              setState(() => _selectedFilter = 'draft'),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(_sortNewestFirst
                              ? Icons.sort_by_alpha
                              : Icons.history),
                          tooltip: _sortNewestFirst
                              ? 'Sort: Newest First'
                              : 'Sort: Oldest First',
                          onPressed: () => setState(
                              () => _sortNewestFirst = !_sortNewestFirst),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Expanded(
                child: matches.isEmpty
                    ? EmptyStateWidget(
                        icon: Icons.calendar_month_rounded,
                        title: 'No matches yet',
                        message:
                            'Create a match to start scoring. Completed games and scorecards will stay available here.',
                        actionLabel: 'Create Match',
                        onAction: () => context.push('/matches/create'),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: matches.length,
                        itemBuilder: (ctx, idx) {
                          final m = matches[idx];
                          if (m.status == 'draft') {
                            return DraftMatchCard(
                              key: ValueKey('draft-list-card-${m.id}'),
                              match: m,
                              onResume: () =>
                                  context.push('/matches/create?draftId=${m.id}'),
                              onDelete: () async {
                                try {
                                  await ref
                                      .read(matchRepositoryProvider)
                                      .deleteDraftMatch(m.id);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Draft deleted'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content:
                                              Text('Failed to delete draft: $e')),
                                    );
                                  }
                                }
                              },
                            );
                          }
                          final dateStr =
                              DateTime.fromMillisecondsSinceEpoch(m.createdAt)
                                  .toIso8601String()
                                  .split('T')
                                  .first;
                          final destination =
                              MatchDestinationResolver.resolveStatus(m.status);
                          final isLive =
                              destination == MatchDestination.liveScoring ||
                                  destination == MatchDestination.inningsBreak;
                          final isCompleted = destination ==
                              MatchDestination.completedScorecard;
                          final statusColor = isCompleted
                              ? Colors.green
                              : isLive
                                  ? Colors.red.shade700
                                  : Colors.orange.shade700;
                          final statusLabel = isLive
                              ? (destination == MatchDestination.inningsBreak
                                  ? 'Innings break'
                                  : 'Live')
                              : m.status == 'noResult'
                                  ? 'No result'
                                  : m.resultType == 'teamForfeit'
                                      ? 'Forfeit'
                                      : m.status;
                          final statusTone = isLive
                              ? StatusBadgeTone.live
                              : isCompleted
                                  ? StatusBadgeTone.success
                                  : m.status == 'abandoned' ||
                                          m.status == 'cancelled'
                                      ? StatusBadgeTone.danger
                                      : StatusBadgeTone.warning;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: InkWell(
                              onTap: () => context.push(
                                MatchDestinationResolver.routeFor(
                                  matchId: m.id,
                                  status: m.status,
                                ),
                              ),
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: statusColor,
                                      child: Icon(
                                        isCompleted
                                            ? Icons.emoji_events
                                            : isLive
                                                ? Icons.play_arrow
                                                : Icons.edit,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(children: [
                                            Expanded(
                                              child: Text(
                                                m.matchName ?? 'Match ${m.id}',
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            StatusBadge(
                                              label: statusLabel,
                                              tone: statusTone,
                                            ),
                                            if (m.status == 'draft') ...[
                                              const SizedBox(width: 4),
                                              PopupMenuButton<String>(
                                                icon: const Icon(Icons.more_vert, size: 20),
                                                padding: EdgeInsets.zero,
                                                constraints: const BoxConstraints(),
                                                onSelected: (action) async {
                                                  if (action == 'resume') {
                                                    context.push('/matches/create?draftId=${m.id}');
                                                  } else if (action == 'delete') {
                                                    final confirm = await showDeleteDraftConfirmationDialog(
                                                      context,
                                                      matchName: m.matchName ?? 'Draft Match',
                                                    );
                                                    if (confirm) {
                                                      try {
                                                        await ref.read(matchRepositoryProvider).deleteDraftMatch(m.id);
                                                        if (context.mounted) {
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            const SnackBar(content: Text('Draft match deleted.')),
                                                          );
                                                        }
                                                      } catch (e) {
                                                        if (context.mounted) {
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            SnackBar(content: Text('Failed to delete draft: $e')),
                                                          );
                                                        }
                                                      }
                                                    }
                                                  }
                                                },
                                                itemBuilder: (ctx) => [
                                                  const PopupMenuItem(
                                                    value: 'resume',
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.play_arrow, color: AppColors.primary),
                                                        SizedBox(width: 8),
                                                        Text('Resume Match'),
                                                      ],
                                                    ),
                                                  ),
                                                  PopupMenuItem(
                                                    value: 'delete',
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.delete_outline, color: Colors.red.shade700),
                                                        SizedBox(width: 8),
                                                        Text('Delete Draft', style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold)),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ]),
                                          Text(
                                            '${m.format.toUpperCase()} • $dateStr • ${m.venueName ?? "Local Field"}',
                                          ),
                                          if (m.endedManually)
                                            Text(
                                              '${m.resultText ?? 'Match ended'}${m.endReasonText == null ? '' : ' — ${m.endReasonText}'}',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          if (isLive)
                                            FutureBuilder<MatchState?>(
                                              future: ref
                                                  .read(matchRepositoryProvider)
                                                  .getMatchState(m.id),
                                              builder: (context, state) {
                                                final live = state.data;
                                                if (live == null ||
                                                    live.innings.isEmpty) {
                                                  return const SizedBox
                                                      .shrink();
                                                }
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 8),
                                                  child: LiveMatchSummaryCard
                                                      .fromMatchState(
                                                    live,
                                                    variant:
                                                        LiveMatchCardVariant
                                                            .historyCompact,
                                                    darkSurface: false,
                                                  ),
                                                );
                                              },
                                            ),
                                          const SizedBox(height: 8),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: TextButton.icon(
                                              onPressed: () => context.push(
                                                MatchDestinationResolver
                                                    .routeFor(
                                                  matchId: m.id,
                                                  status: m.status,
                                                ),
                                              ),
                                              icon: Icon(isLive
                                                  ? Icons.play_circle
                                                  : isCompleted
                                                      ? Icons.scoreboard
                                                      : Icons.edit_note),
                                              label: Text(
                                                MatchDestinationResolver
                                                    .actionLabel(m.status),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class ScoreTabScreen extends ConsumerWidget {
  const ScoreTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeMatchAsync =
        ref.watch(matchRepositoryProvider).getActiveMatch();

    return Scaffold(
      appBar: AppBar(title: const Text('Live Score')),
      body: FutureBuilder<MatchesTableData?>(
        future: activeMatchAsync,
        builder: (context, snapshot) {
          final active = snapshot.data;
          if (active == null) {
            return EmptyStateWidget(
              icon: Icons.scoreboard_rounded,
              title: 'No live match',
              message:
                  'Create a match to unlock live scoring, player figures, and ball-by-ball updates.',
              actionLabel: 'Create Match',
              onAction: () => context.push('/matches/create'),
            );
          }

          return FutureBuilder<MatchState?>(
            future: ref.read(matchRepositoryProvider).getMatchState(active.id),
            builder: (context, matchSnapshot) {
              if (!matchSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final engine = CricketScoringEngine(matchSnapshot.data!);
              return ScorecardScreen(engine: engine);
            },
          );
        },
      ),
    );
  }
}
