# TurfScore — Current Implementation

Last reviewed: 2 August 2026  
Scope: Flutter mobile application, Dart scoring engine, local persistence, synchronization prototype, and admin prototype.

## 1. Purpose

TurfScore is an offline-first cricket match scoring application. It supports team and squad management, ball-by-ball scoring, dynamic small-team rules, resumable live matches, completed scorecards, match awards, PDF export, and synchronization of locally recorded events.

This document describes behavior present in the current repository. It is an implementation reference, not a future product specification.

## 2. Repository architecture

| Area | Technology | Responsibility |
|---|---|---|
| `mobile` | Flutter, Riverpod, GoRouter, Drift | Android/iOS UI, local database, offline workflows, PDF and sharing |
| `packages/cricket_scoring_engine` | Pure Dart | Cricket rules, match state, scoring, innings completion, results and awards |
| `backend` | NestJS | Batch event synchronization and live-score WebSocket prototype |
| `admin` | Next.js | Administrative dashboard prototype |
| `docs` | Markdown | Product and implementation documentation |

The scoring engine does not depend on Flutter. The mobile application owns presentation and persistence and stores serialized `MatchState` snapshots produced by the engine.

## 3. Mobile navigation

The application uses five main destinations:

- Home
- Matches
- Score
- Teams
- Profile

Additional routes cover welcome/onboarding, team creation, team details, adding players, match setup, live scoring, recovery, scorecard details, PDF preview, and personalization.

The Score destination is contextual: it resumes an active match when one exists and otherwise allows match creation.

## 4. Design system and branding

The mobile presentation uses Material Design 3 with a sports-dashboard visual language.

- Primary emerald branding
- Gold recognition/accent color
- Light gray canvas and elevated white cards
- Manrope font bundled for offline use
- Rounded cards and restrained elevation
- Responsive phone and tablet navigation
- Minimum 48 logical-pixel interactive targets
- Semantic labels for compact scoring abbreviations
- Shared buttons, cards, badges, search, empty states, live-match headers and bottom navigation

Brand assets include:

- 1024 × 1024 master app mark
- SVG logo source
- Android adaptive foreground/background icons
- Android 13 monochrome icon
- iOS icon sizes
- Branded Android splash asset
- Reusable in-app brand mark

See [premium_redesign_design_spec.md](premium_redesign_design_spec.md) for design tokens and UI principles.

## 5. Team and player management

### Teams

- Create and edit teams.
- Store name, short name, city, color, logo and default captain.
- Search active teams.
- Archive teams without removing historical match data.
- Show a single empty-state Create Team action when no teams exist.

### Players

- Create and edit player profiles.
- Store jersey number, role, batting style, bowling style, captain and wicketkeeper flags.
- Assign a player to a team through a separate team-member relationship.
- Enforce one default captain per team.

### Remove from Team

Permanent roster removal is implemented as relationship archival:

- `TeamMembersTable.isActive` becomes false.
- `removedAt` records the removal time.
- The underlying player record and historical references remain intact.
- Removed players are listed separately and can be restored without duplication.

### Remove from Match

Match squad membership is independent from permanent team membership:

- A non-participating player may be removed from an active match squad.
- Participating players cannot be removed from historical match state.
- Participating players may instead be marked unavailable.
- Availability affects future batter and bowler selection while preserving the scorecard.
- Match setup clears invalid captain, striker, non-striker and opening-bowler selections after removal.

### Late players

Configured local matches can add players after match start.

- Late-player rules independently control batter and bowler additions.
- The player is added to the live team and match-squad snapshot.
- Join time, innings, over and delivery sequence are persisted.
- A late batter updates the active batting-member snapshot and dynamic wicket limit.
- An approved late bowler receives the match's default bowling limit and starts with zero figures.
- A late-player audit and synchronization event is queued.

## 6. Match setup

The setup wizard covers:

1. Team selection
2. Match details and overs
3. Playing squads, captains and bowling rules
4. Toss
5. Opening batters and opening bowler
6. Final confirmation

Draft setup state is persisted and can be resumed.

### Setup validation

- Teams must be distinct.
- Both teams must meet the configured minimum squad size.
- Each match squad is persisted independently from the permanent roster.
- Each side requires exactly one selected match captain.
- Opening striker and non-striker must be distinct squad members.
- Opening bowler must be an eligible member of the bowling squad.
- Bowling rules must be feasible for both teams.
- A database-level single-active-match constraint is checked again immediately before starting.

## 7. Dynamic wicket and innings completion rules

Maximum wickets are derived from the active persisted match squad:

```text
maximumWickets = playingMemberCount - 1
```

Examples:

| Playing members | Maximum wickets |
|---:|---:|
| 11 | 10 |
| 7 | 6 |
| 5 | 4 |
| 3 | 2 |
| 2 | 1 |

Normal match setup requires at least two players. Single-player standard innings are not silently accepted.

Each innings persists:

- `playingMemberCountSnapshot`
- `maximumWickets`
- wickets lost
- completion reason
- flow state
- completed state

The centralized `InningsCompletionEvaluator` checks:

- target reached
- all out
- scheduled overs completed
- innings completion reason

The all-out comparison uses `wicketsLost >= maximumWickets`; it does not assume ten wickets.

Only wicket-counting dismissals increment the innings wicket total. Retired hurt remains non-wicket. The same event data drives scorecards, bowling figures and PDFs.

## 8. Dynamic bowling rules

The match configuration supports:

```dart
enum BowlerLimitMode {
  localAutomatic,
  officialFormat,
  customEqualLimit,
  customPerBowler,
  unlimited,
}
```

### Local automatic

The equal limit is the smallest value that supplies enough capacity:

```text
ceil(total innings overs / eligible bowler count)
```

Examples:

| Match overs | Eligible bowlers | Suggested limit |
|---:|---:|---:|
| 3 | 3 | 1 |
| 5 | 3 | 2 |
| 5 | 2 | 3 |
| 10 | 5 | 2 |

### Official formats

- T10: two overs per bowler
- T20: four overs per bowler
- Fifty-over: ten overs per bowler

### Custom modes

- Custom equal applies one scorer-selected limit to all eligible bowlers.
- Custom per bowler stores individual limits.
- Unlimited removes the over ceiling while retaining squad, availability and consecutive-over validation.

### Capacity and scheduling validation

- Equal capacity is `eligible bowler count × maximum overs`.
- Per-bowler capacity is the sum of individual limits.
- Match start is rejected when capacity is below the innings requirement.
- Multi-over matches with consecutive overs disabled require at least two eligible bowlers.
- Eligibility is match-specific and is not inferred solely from the player's permanent role.

### Runtime enforcement

Limits are enforced using legal balls:

```text
maximum legal balls = maximum overs × balls per over
```

Wides and no-balls do not consume the allowance. This supports five-, six-, and eight-ball overs and exact mid-over replacements.

A bowler is rejected when the player:

- is outside the active bowling squad
- is not match-eligible to bowl
- is unavailable
- reached the persisted legal-ball limit
- bowled the previous over while consecutive overs are disabled

The selector shows current figures, economy, remaining overs or remaining legal balls, and the reason for an unavailable state. A one-off consecutive-over override requires explicit scorer action.

Bowling configuration is serialized inside the match state, including mode, eligible IDs, equal/per-player limits, legal-ball limits, balls per over, consecutive-over setting and confirmation timestamp.

## 9. Live scoring

### Delivery types

- Dot ball
- Runs 1–6
- Wicket
- Wide
- No ball
- Bye
- Leg bye
- Penalty runs in the engine model

Delivery events preserve batter runs, categorized extras, legality, boundary flags, wicket details, participating players, sequence, timestamps and hash linkage.

### Scoring order

A delivery is persisted and then evaluated in this order:

1. Update delivery-derived score and players.
2. Evaluate target and match completion.
3. Evaluate all-out and innings completion.
4. Evaluate over completion only if the innings remains active.
5. Enter the required next-player flow.

### Live screen layout

The scoring screen has three structural regions:

- Fixed header: batting team, bowling team, innings, score, overs, chase information and current over.
- Constrained scrolling middle: compact live batters, current bowler and secondary information.
- Fixed SafeArea footer: runs keypad, extras, Undo and More.

Scrollable content cannot render beneath the scoring keypad.

### Current over

- Uses one compact shared sequence instead of large per-delivery capsules.
- Shows persisted deliveries from only the active over.
- Includes illegal deliveries without advancing the legal-ball count.
- Wraps on small screens and supports text scaling.
- Uses accessible descriptions for abbreviations.
- Is reused by live scoring and over-completion UI.

Innings progress uses cricket notation, not decimal arithmetic:

```text
completedOvers = legalBalls ~/ ballsPerOver
ballsInCurrentOver = legalBalls % ballsPerOver
```

The active heading shows only the ordinal over number, for example `Current Over · 2`.

### Live players

The compact Live Match Info card shows:

- striker with a small star marker
- non-striker
- runs and balls
- strike rate
- current bowler
- standard `O–M–R–W` figures
- economy

## 10. Mandatory batter and bowler state machine

Persisted innings flow states are:

```dart
scoring
awaitingNextBatter
awaitingNextBowler
inningsCompleted
```

The UI is a representation of this persisted state; dialog visibility is not treated as the source of truth.

### Next batter

- The selector opens only when an eligible batter remains.
- All-out is evaluated before requesting another batter.
- Scoring remains blocked until selection is confirmed.
- A wicket on the final legal ball resolves the batter before the next bowler.

### Next bowler

At over completion:

- the final legal delivery remains persisted
- the previous over is completed
- strike is rotated
- current bowler and active-over ID are cleared
- flow state becomes `awaitingNextBowler`
- scoring controls are disabled
- no new over is created until a valid bowler is confirmed

The mandatory sheet blocks outside tap, swipe-to-dismiss and normal Back dismissal. Returning Home preserves the awaiting state, and Resume Match restores the same flow.

The repository and engine reject all delivery types when the match, innings, flow state, active over, current bowler or result state is invalid.

## 11. Undo

- Undo reverses the latest persisted delivery.
- Score, wickets, extras, batter figures, bowler figures and strike are restored from event-derived state.
- Undoing the final ball of a completed over restores the previous active over and bowler.
- The flow returns from `awaitingNextBowler` to `scoring` when the over is no longer complete.
- Undo is separate from roster removal recovery and cannot undo a terminal manual match outcome.

## 12. Innings transition and results

### First innings

When the innings completes, the application stores the score and target and enters innings break.

### Chase result

- Reaching the target completes the match immediately.
- Wicket margin uses the chasing squad's dynamic maximum wickets.
- All out or completed overs below target gives the defending team a runs victory.
- Equal scores at innings completion produce a tie.

### Dynamic result examples

For a three-player chasing side:

- maximum wickets: 2
- target reached after one wicket: won by 1 wicket
- all out for 15 chasing 21 after the first side made 20: defending side won by 5 runs

The completed match disables scoring and persists its result and awards.

## 13. Single active match

Only one active match is allowed locally.

Active states include ready/setup-complete, live scoring, innings break and paused/mandatory selection states represented by the live match snapshot.

Enforcement occurs at:

- Home and contextual Score navigation
- Create Match entry
- Start Match action
- repository validation
- a partial unique SQLite index covering active statuses

When active, Home prioritizes Resume Match and hides the normal create action. Completion, abandonment, no result and cancellation release the lock only after the terminal transaction succeeds.

## 14. Manual End Match

End Match is available from the live scoring More menu and supports:

- Abandoned
- No Result
- Team Forfeit
- Match Cancelled
- Manually Completed

Reasons include rain, bad light, wet outfield, unsafe ground, injury, insufficient players, withdrawal, time limit, equipment, dispute, technical issue and Other. Other requires a note.

The flow requires outcome selection, reason selection, review and final confirmation. Forfeit requires the forfeiting/winning teams. Manual completion requires an explicit result rather than silently deriving an unsupported result.

The terminal transaction preserves:

- current and partial innings scores
- deliveries and active over data
- batter and bowler figures
- squads and match rules
- end reason, note, result metadata and timestamp
- audit event and synchronization queue entry

Terminal matches leave Resume Match, release the active-match lock, appear in Match History, and support scorecard/PDF access.

Reopen Match restores the saved live state only when no other active match exists and writes a reopen audit event.

## 15. Home, history and live identification

All live match surfaces use a shared `LiveMatchHeader` presentation model.

- The batting team is explicitly highlighted.
- The bowling team uses secondary styling.
- The active innings is shown.
- Score and legal-ball over notation stay adjacent to the batting team.
- First innings omits chase information.
- Second innings may show target, runs/balls needed, CRR and RRR.

This presentation is used by Home resume cards, active match cards, live scoring and scorecard headers.

Match History distinguishes live and terminal records. Active records route to live scoring; completed or manually ended records route to saved match details.

## 16. Scorecards and statistics

The Detailed Scorecard and live preview use compact mobile dashboard components instead of spreadsheet-style tables.

- Compact match summary
- Sticky/compact innings selector
- Grouped batting rows
- Grouped bowling rows
- Expandable player detail with one expanded row at a time
- Partnership summary
- Extras breakdown
- Fall-of-wickets timeline
- Over-by-over delivery sequences
- Meaningful empty states
- Responsive phone/tablet layouts

Statistics include batter runs, balls, boundaries and strike rate; bowler legal-ball overs, maidens, conceded runs, wickets and economy; partnerships; extras; and fall of wickets.

## 17. Match awards

Normally completed matches calculate and persist:

- Best Batter
- Best Bowler

Awards use player and team name snapshots, statistical summaries and a ranking score. One record per match and award type is enforced. Abandoned, cancelled, no-result and active matches do not automatically receive performance awards.

## 18. PDF and sharing

PDF generation supports completed and manually ended matches.

Included information:

- branding, teams, date, venue and toss
- match status and final result
- manual end reason and note
- completed and partial innings
- batting and bowling figures
- extras and wickets
- delivery/over summaries
- dynamic all-out notation
- awards for eligible completed matches

Historical scorecards use persisted match/player snapshots so later roster archival does not remove old player names.

The manual-end summary can be shared through the platform share sheet.

## 19. Offline persistence

The Drift database schema is currently version 11. Version 11 adds persisted
match-specific wicketkeeper IDs for both squads.

| Table | Purpose |
|---|---|
| `TeamsTable` | Teams and default captain |
| `PlayersTable` | Player profiles |
| `TeamMembersTable` | Active/archived permanent roster relationships |
| `MatchesTable` | Match metadata, state snapshot, terminal result and setup draft |
| `DeliveriesTable` | Immutable/reversible ball-by-ball events |
| `ScoringAuditTable` | Match and roster audit events |
| `MatchSquadMembersTable` | Match-specific squad snapshots and availability |
| `MatchAwardsTable` | Persisted best-player awards |
| `SyncQueueTable` | Idempotent offline synchronization queue |

Critical writes use transactions, including delivery persistence, undo, late-player updates, manual ending/reopening and terminal result storage.

Match configuration—including dynamic wicket and bowling rules—is stored in `MatchesTable.stateJson`. This avoids a separate schema migration for each rule field while retaining full restart/resume fidelity.

## 20. Synchronization

The mobile sync manager queues locally generated events and retries them later.

Current server prototype behavior:

- `POST /api/v1/matches/:matchId/events/sync`
- sorts a batch by event sequence
- treats duplicate event IDs idempotently
- rejects sequence gaps/conflicts
- returns accepted/rejected IDs and latest sequence
- exposes a Socket.IO `live-score` namespace with match rooms and score-update broadcasts

The current backend event store and sequence tracking are in memory. Durable production storage, authentication, authorization and multi-instance conflict coordination remain backend work.

## 21. Recovery and restart behavior

On app restart or Resume Match, the application restores the serialized match state, including:

- score and innings
- active batters and current bowler
- legal-ball counts and current over
- mandatory batter/bowler flow
- dynamic wicket limits
- dynamic bowling limits
- match squad and availability
- result or manual terminal state

Completed and terminal matches do not reopen live scoring. Incomplete/corrupt live snapshots route to a recovery screen rather than silently starting a new setup.

## 22. Automated test coverage

### Scoring engine

Coverage includes:

- normal scoring and strike rotation
- extras and legality
- wickets and undo
- dynamic all-out and results
- legal-ball over notation
- mandatory next-bowler and wicket-on-final-ball transitions
- live figures and resume
- match squad participation and availability
- late players
- dynamic bowling rules
- manual end/reopen
- match awards

Current result: **67 engine tests passing**.

### Flutter application

Coverage includes:

- team and captain flows
- roster archival and restoration
- match setup validation
- single active match database rule
- repository delivery validation and persisted resume
- late-player persistence and sync queue
- manual end atomicity and idempotency
- scorecard dashboard responsiveness
- PDF content
- mandatory batter/bowler modal behavior
- live player and scoring layouts at compact widths
- branding assets and sports design system
- awards persistence and widgets

Current result: **70 Flutter tests passing**.

### Backend

The sync service has a focused service test covering event synchronization behavior.

## 23. Known limitations and follow-up work

- The backend synchronization store is currently in memory and is not production durable.
- Authentication and scorer authorization are not implemented in the shown backend prototype.
- Match templates are described by the product direction but do not yet have a dedicated persisted template repository/UI.
- Bowling-rule override data can use general scoring audit persistence, but a dedicated strongly typed `BOWLING_LIMIT_CHANGED` repository workflow and complete Resolve Bowling Rules screen remain follow-up work.
- Drafts receive current bowling-rule calculation during setup; a dedicated migration/recovery wizard for already-live legacy one-over configurations remains follow-up work.
- Notification and lock-screen live-match widgets are future surfaces; the shared live-header model is ready to support them but they are not implemented.
- Physical-device manual regression remains necessary across small Android phones, large phones, iPhone and tablet form factors.
- Static analysis currently reports existing lint configuration/deprecation warnings, including an unresolved `flutter_lints` include; the tested application has no compilation errors from the documented feature work.

## 24. Validation commands

From `packages/cricket_scoring_engine`:

```bash
flutter test
```

From `mobile`:

```bash
flutter test
flutter analyze
```

When the Drift schema changes:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## 25. Core implementation references

- Engine entry point: `packages/cricket_scoring_engine/lib/src/engine.dart`
- Match rules: `packages/cricket_scoring_engine/lib/src/models/match_config.dart`
- Innings completion: `packages/cricket_scoring_engine/lib/src/services/innings_completion_evaluator.dart`
- Bowling rules: `packages/cricket_scoring_engine/lib/src/rules/bowling_rules.dart`
- Live figures: `packages/cricket_scoring_engine/lib/src/services/live_figures_service.dart`
- Match awards: `packages/cricket_scoring_engine/lib/src/services/match_awards_service.dart`
- Local schema: `mobile/lib/data/local/database.dart`
- Match persistence: `mobile/lib/data/repositories/match_repository.dart`
- Match setup: `mobile/lib/presentation/matches/match_setup_wizard.dart`
- Live scoring: `mobile/lib/presentation/scoring/scoring_screen.dart`
- Scorecard: `mobile/lib/presentation/scorecard/scorecard_screen.dart`
- PDF generation: `mobile/lib/core/services/scorecard_pdf_service.dart`
- Sync manager: `mobile/lib/data/sync/sync_manager.dart`
