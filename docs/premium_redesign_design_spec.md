# Cricket Scorer — Premium Mobile Redesign Specification

Status: Proposed for approval  
Product principle: fastest safe path from opening the app to recording the next ball  
Default preset: Stadium Classic  
Default theme mode: System

## 1. Experience principles

1. **Score first.** Live score, match state, and the next valid action always lead.
2. **One-handed scoring.** Frequent actions live in the lower thumb zone and remain visible.
3. **Local first, visibly safe.** UI updates optimistically; persistence and sync status are calm and explicit.
4. **Progressive disclosure.** Primary information is visible; advanced actions use sheets and menus.
5. **Premium restraint.** Neutral space, navy structure, emerald action, and rare gold recognition.
6. **Accessible by meaning.** Icons, text, shape, and colour communicate state together.
7. **One system, many screens.** Screens compose shared tokens and components rather than owning styles.

## 2. Revised information architecture

```text
App
├── Launch
│   ├── Splash (local initialization only)
│   └── Welcome / first-team onboarding
├── Home
│   ├── Active match / quick resume
│   ├── Continue setup
│   ├── Quick actions
│   ├── Recent matches
│   └── Team summary
├── Matches
│   ├── Live
│   ├── Draft
│   ├── Completed
│   └── Archived
│       └── Match details
│           ├── Full scorecard
│           ├── PDF preview
│           └── Share
├── Score (contextual destination)
│   ├── Resume active match
│   └── Create match
│       ├── Teams
│       ├── Match rules
│       ├── Squad
│       ├── Toss
│       ├── Opening players
│       └── Confirmation
│           └── Live scoring
│               ├── Delivery details sheets
│               ├── Wicket entry
│               ├── Bowler selection
│               ├── Over summary
│               ├── Innings break
│               └── Match result
├── Teams
│   ├── My teams
│   ├── Players
│   ├── Team statistics
│   ├── Team details
│   └── Create / edit team and players
└── Profile
    ├── User profile
    ├── Jersey and badge
    ├── Appearance
    ├── Feedback and accessibility
    ├── Backup and sync
    └── Settings
```

The Score tab is a resolver, not a standalone demo screen. It opens the active match when one exists and otherwise starts match creation. Demo content is removed from production navigation.

## 3. Navigation structure

Use a Material 3 `NavigationBar` on phones and a `NavigationRail` on wide tablet layouts.

| Position | Label | Outline icon | Selected icon | Destination |
|---|---|---|---|---|
| 1 | Home | `home_outlined` | `home_rounded` | `/` |
| 2 | Matches | `history_outlined` | `history_rounded` | `/matches` |
| 3 | Score | `sports_cricket_outlined` | `sports_cricket_rounded` | contextual resolver |
| 4 | Teams | `groups_outlined` | `groups_rounded` | `/teams` |
| 5 | Profile | `person_outline_rounded` | `person_rounded` | `/profile` |

The centre Score destination receives a restrained emerald container, but keeps the same size, baseline, and semantics as other tabs. Each tab retains its own navigation stack. Opening and closing scorecards must not discard an active scoring session.

## 4. Colour system

### Core palette

| Token | Light | Dark | Use |
|---|---|---|---|
| `brand.navy` | `#0B1F33` | `#0B1F33` | branded headers, live panels |
| `brand.emerald` | `#00A86B` | `#20C986` | primary actions, active status |
| `brand.gold` | `#F5B942` | `#F5C45B` | winners and premium recognition only |
| `surface.canvas` | `#F5F7FA` | `#081827` | app background |
| `surface.card` | `#FFFFFF` | `#102A43` | cards and sheets |
| `surface.raised` | `#FFFFFF` | `#173A59` | elevated dark surfaces |
| `text.primary` | `#17212B` | `#F8FAFC` | primary content |
| `text.secondary` | `#64748B` | `#B8C5D1` | supporting content |
| `text.muted` | `#94A3B8` | `#8EA0B2` | tertiary metadata |
| `border.subtle` | `#E2E8F0` | `#294963` | separators and outlines |
| `semantic.success` | `#16A36A` | `#36C98C` | saved/synced/success |
| `semantic.warning` | `#F59E0B` | `#F7B84B` | attention and offline |
| `semantic.error` | `#DC3545` | `#FF6472` | errors and wicket |
| `semantic.info` | `#2684FF` | `#68A7FF` | informational states |
| `semantic.disabled` | `#AAB4C0` | `#627386` | unavailable controls |

Target visual distribution is 70% neutral surfaces, 20% navy structure, 8% emerald action/status, and at most 2% gold recognition. Team colours may tint a 5–10% background or a narrow accent; they never recolour scoring controls.

### Curated presets

Presets change brand accents, not semantic colours or content hierarchy.

| Preset | Primary structure | Action accent | Recognition |
|---|---|---|---|
| Stadium Classic | Navy | Emerald | Gold |
| Championship | Navy | Warm gold | Emerald |
| Pitch Green | `#123C32` | `#2E8B57` | `#D6B25E` |
| Night Match | `#081827` | `#2684FF` | Gold |
| Team Spirit | Navy | approved team accent | Gold |

Every preset must pass WCAG AA for normal text and WCAG AAA where feasible for scoring data.

## 5. Light and dark themes

Light mode uses the off-white canvas, white cards, navy high-emphasis regions, and low elevation. Dark mode uses deep navy—not black—with lighter navy cards and subtle borders. Both modes share layout, hierarchy, and semantic meaning.

Theme mode (`system`, `light`, `dark`), preset, haptics, sound, and reduced-motion preferences are persisted locally. System brightness changes update immediately when mode is `system`. A high-contrast scoring palette remains stable across presets.

## 6. Typography scale

Primary family: **Inter**. Use bundled font assets in production so startup and offline rendering do not depend on a font download. Scores use tabular figures.

| Token | Size / line height | Weight | Use |
|---|---|---|---|
| `display.score` | 46 / 52 | 700 | live score |
| `display.result` | 30 / 36 | 700 | match result |
| `title.screen` | 26 / 32 | 700 | screen title |
| `title.section` | 20 / 26 | 600 | section heading |
| `title.card` | 17 / 23 | 600 | card title |
| `body.large` | 16 / 24 | 400 | primary body |
| `body.medium` | 14 / 21 | 400 | standard body |
| `label.large` | 15 / 20 | 600 | buttons |
| `label.medium` | 13 / 18 | 500 | metrics and chips |
| `label.small` | 12 / 16 | 500 | timestamps and support |

Text scales with platform settings. At 200% text scale, scoring controls may grow vertically or move secondary actions into a sheet, but labels may not clip or become horizontal-only scrolling content.

## 7. Icon strategy

Use Material Symbols Rounded exclusively for application UI because Material is already native to the Flutter project. Normal states are outlined; selected navigation and high-certainty statuses are filled. Default sizes are 20, 24, and 28 logical pixels with 48 logical-pixel minimum interactive containers.

Custom assets are limited to a jersey outline and app mark. They use the same rounded terminals and apparent 2px stroke as the selected library. Emoji are not UI icons. Every non-decorative icon has a tooltip and semantic label.

## 8. Spacing, shape, elevation, and motion tokens

Spacing: `4, 8, 12, 16, 20, 24, 32`  
Screen gutter: 16 on compact phones, 20 on large phones, 24–32 on tablets  
Radius: small 8, medium 12, large 16, premium 20, pill 999  
Touch target: minimum 48 × 48; primary scoring targets aim for 56–64 high  
Icon sizes: 16, 20, 24, 28, 32  
Elevation: level 0, level 1 (subtle card), level 2 (floating control/sheet); no heavy shadows  
Borders: one-pixel subtle border only where elevation or surface contrast is insufficient

Motion:

| Token | Duration | Use |
|---|---:|---|
| `motion.press` | 120ms | button press |
| `motion.score` | 180ms | changed score emphasis |
| `motion.card` | 200ms | card transition |
| `motion.sheet` | 260ms | bottom sheet |
| `motion.result` | 800ms max | one-shot result recognition |

Reduced motion removes scale, trophy, and boundary flourishes; state changes retain a short opacity transition or no animation.

## 9. Component inventory

### Foundations

`AppTheme`, `AppColorTokens`, `AppTextStyles`, `AppSpacing`, `AppRadii`, `AppElevation`, `AppMotion`, `AppIconSizes`, `AppBreakpoints`.

### Actions

`PrimaryButton`, `SecondaryButton`, `TextActionButton`, `IconActionButton`, `ScoreActionButton`, `DestructiveButton`, `StickyActionBar`.

### Content

`PremiumCard`, `ActiveMatchCard`, `MatchCard`, `TeamCard`, `PlayerCard`, `MetricTile`, `ScorePanel`, `BatterCard`, `BowlerCard`, `CurrentOverStrip`, `JerseyBadge`.

### Status and feedback

`StatusChip`, `LiveIndicator`, `SyncStatus`, `OfflineBanner`, `InlineNotice`, `ToastMessage`, `LoadingSkeleton`, `EmptyState`, `ErrorState`, `MilestoneBanner`.

### Selection and overlays

`SelectionCard`, `SquadPlayerTile`, `WizardProgress`, `AppBottomSheet`, `BowlerSelectionCard`, `FilterSheet`, `ConfirmationDialog`.

Components expose semantic labels, enabled/disabled reason text, focus behavior, and theme tokens. Screens may arrange components but may not introduce private colour constants or arbitrary radii.

## 10. Home screen wireframe

```text
┌──────────────────────────────────┐
│ Good evening, Karthick       [18]│
│ Ready for today's match?     [✓] │
├──────────────────────────────────┤
│ ┌ ACTIVE MATCH ─────── LIVE ● ┐ │
│ │ Chennai Strikers vs Warriors │ │
│ │ 85/3                  12.4 ov │ │
│ │ Target 142 · Need 57 from 44  │ │
│ │ CRR 6.71       RRR 7.77       │ │
│ │ Saved on device · just now    │ │
│ │ [ Resume Scoring            ] │ │
│ │ [ View Scorecard ]            │ │
│ └───────────────────────────────┘ │
│ Quick actions                    │
│ [Match] [Team] [History] [PDF]   │
│                                  │
│ Recent matches          View all │
│ ┌ CS 148/6     WS 141/9 ──────┐ │
│ │ Chennai won by 7 runs  [›]   │ │
│ └──────────────────────────────┘ │
│ Teams                    View all│
│ [CS  14 players] [WS  12 players]│
├──────────────────────────────────┤
│ Home  Matches  [Score] Teams Me  │
└──────────────────────────────────┘
```

If there is no active match, the active card becomes the appropriate data-derived empty state. Zero teams shows “Build Your First Team”; one team shows “One More Team Needed”; two eligible teams shows “Ready to start a match?”. Loading uses skeletons with the same geometry and never renders an empty state first.

## 11. Scoring screen wireframe

```text
┌──────────────────────────────────┐
│ ‹ CS vs WS · 2nd inns  LIVE ●  ✓│
├──────────────────────────────────┤
│          85/3                    │
│        12.4 overs                │
│ Need 57 from 44 · Target 142     │
│ CRR 6.71             RRR 7.77    │
├──────────────────────────────────┤
│ STRIKER ●  A. Kumar  42 (31)     │
│ 4s 5 · 6s 1 · SR 135.5           │
│ Non-striker  R. Dev  18 (16)     │
├──────────────────────────────────┤
│ Bowler  M. Singh    2.4-0-17-1   │
│ Econ 6.38           Change ›     │
├──────────────────────────────────┤
│ This over  [1] [•] [4] [W] [2]  │
├──────────────────────────────────┤
│ [ 0 ] [ 1 ] [ 2 ] [ 3 ]         │
│ [ 4 ] [ 5 ] [ 6 ] [ Wicket ]    │
│ [ Wide ][No Ball][ Bye ][Leg Bye]│
│ [↶ Undo]                  [More] │
└──────────────────────────────────┘
```

The upper content may scroll on a small device; the scoring action deck remains pinned above the safe area. `0–3` and `4–6/Wicket` are always visible. Extras may collapse behind one “Extras” sheet only when text scaling or very short landscape height makes four labelled buttons unsafe. First innings omits chase metrics. Complex events open a focused bottom sheet and confirm inline after commit.

At over completion, the action deck is replaced by a compact summary sheet and eligible bowler cards. Scoring remains blocked until selection; every disabled bowler includes an icon and reason. Innings completion navigates to a dedicated summary. Match completion replaces scoring controls with the result screen.

## 12. Match result wireframe

```text
┌──────────────────────────────────┐
│ Match Complete               [×] │
│              🏆                  │
│ Chennai Strikers                  │
│ won by 5 wickets                  │
│ ┌──────────────────────────────┐ │
│ │ WS 141/8        CS 142/5     │ │
│ │ 20.0 ov          18.3 ov     │ │
│ └──────────────────────────────┘ │
│ Player of the Match              │
│ A. Kumar · 72 (48)               │
│ Top batter 72  · Top bowler 3/24 │
│ Duration 1h 42m                  │
│ [ View Scorecard               ] │
│ [ PDF ] [ Share Result ]         │
│ Return Home                      │
└──────────────────────────────────┘
```

The winner’s colour appears only as a narrow accent/tint. Gold is reserved for the trophy and Player of the Match badge. If Player of the Match is not recorded, the section is omitted rather than populated with mock data.

## 13. Match history wireframe

```text
┌──────────────────────────────────┐
│ Matches                    [Filter]│
│ [Live] [Draft] [Completed] [Archive]│
│ 🔎 Search matches                │
│ July 2026                        │
│ ┌ CS             WS ──────────┐ │
│ │ 148/6          141/9        │ │
│ │ CS won by 7 runs            │ │
│ │ 24 Jul · T20 · Local Ground │ │
│ │ [Scorecard]       [PDF] [↗] │ │
│ └─────────────────────────────┘ │
│ ┌ RR             KK ──────────┐ │
│ │ Draft · setup 3 of 5   [›]  │ │
│ └─────────────────────────────┘ │
├──────────────────────────────────┤
│ Home  Matches  [Score] Teams Me  │
└──────────────────────────────────┘
```

Status tabs handle the primary split; format, venue, date, and sort live in a compact filter sheet. Lists request lightweight summaries in pages. Full delivery history loads only after opening a match.

## 14. Responsive behaviour

| Class | Width | Layout behavior |
|---|---:|---|
| Compact | `< 360` | 12–16 gutter; single column; scoring deck pinned; metadata wraps |
| Standard phone | `360–599` | single column; 16 gutter; five-item bottom navigation |
| Large phone / small tablet | `600–839` | constrained content max 720; cards may form two columns |
| Tablet | `≥ 840` | navigation rail; content max 1200; split panels |

Portrait scoring places summary above the pinned action deck. Landscape scoring uses two panes: score, players, and over on the left; the action deck on the right. Tablet scoring uses a 5:4 split and never stretches cards to full width. Insets, not fixed device heights, determine the available action region.

## 15. State and interaction model

### Loading

Home, teams, matches, and scorecards use content-shaped skeletons. Route restoration may show a compact branded loading surface, never an empty message. Skeletons are excluded from screen-reader focus and announce “Loading”.

### Saving and sync

Recording a delivery performs:

```text
Tap → validate locally → update focused score state → subtle haptic
    → persist delivery transaction → enqueue sync → update save status
```

No full-screen loader appears. A persistence failure restores the last safe state and shows: “We couldn’t save this delivery. Your previous score is safe.” with Retry. Offline is a neutral `cloud_off` status plus “Saved on this device”; synced uses `cloud_done` plus “All changes synced”.

### Feedback

Normal ball: light haptic and 180ms score emphasis.  
Boundary: light haptic and short accent sweep.  
Wicket: stronger haptic and short labelled banner.  
Undo: medium haptic and “Last delivery removed” with a brief detail.  
Milestones: non-modal banner that dismisses automatically and never covers controls.

Sound is off by default unless the existing product policy chooses otherwise. Haptics, sound, and reduced motion are user-controlled.

## 16. Accessibility review

### Required behavior

- Every target is at least 48 × 48 logical pixels; scoring targets aim for 56 × 56 or larger.
- Normal text contrast is at least 4.5:1; large text and meaningful non-text UI at least 3:1.
- Live, wicket, selected, offline, synced, and disabled states use text plus icon/shape, never colour alone.
- Score buttons announce full meanings such as “Record wide” and “Record wicket”, not abbreviations.
- Score updates use a polite live region; a completed delivery announces once, not for every metric changed.
- Focus order follows match header → score → players → current over → scoring actions.
- Bottom sheets trap focus, announce their title, expose dismissal, and return focus to the invoking control.
- Disabled bowlers remain discoverable as non-actionable cards and announce the eligibility reason.
- Dynamic text up to 200% does not clip; critical labels do not rely on ellipsis.
- Reduced motion disables all nonessential transforms and celebrations.
- High-contrast platform settings preserve borders, selected states, and focus indicators.
- Landscape and tablet layouts retain logical reading order independent of visual pane order.

### Accessibility risks to test early

The four-column scoring rows on sub-360 widths, long player names, 200% labels for “No Ball” and “Leg Bye”, bottom navigation at large text sizes, table semantics in scorecards, and dark-mode secondary text need dedicated golden, semantics, and device tests.

## 17. Implementation architecture guardrails

- Keep `cricket_scoring_engine` unchanged during presentation phases unless a separately reviewed functional defect is found.
- Preserve existing Drift tables and records. Database changes are additive migrations only.
- Move route-level screens out of the large `main.dart`; keep router composition separate from feature presentation.
- Introduce a persisted `AppearanceSettings` model without repurposing team or match data.
- Split scoring observation into focused providers: score, batters, bowler, over, match status, and sync status.
- Persist delivery events before network work; sync remains background-only.
- Replace per-card player `FutureBuilder` calls with repository summary queries/streams to avoid N+1 work.
- Add paged match-summary queries and indexes for status/date; load delivery details only for selected matches.
- Cache and downsample logos/photos for card dimensions.
- Rebuild only the score-dependent widget subtree after a delivery; isolate transient animations.
- PDF generation receives the selected `MatchState` explicitly and uses no global/current-match fallback.

## 18. Incremental delivery and approval gates

### Phase 1 — Foundation

Tokens, Inter assets, light/dark/system themes, persisted preferences, icon rules, shared states/components, responsive shell, and five-tab navigation.

Approval gate: token catalogue, light/dark component gallery, navigation behavior, contrast report, and no data migration regression.

### Phase 2 — Core journey

Splash/welcome, Home, team creation/details, match wizard, and live scoring shell/actions.

Approval gate: zero/one/two-team states, quick resume, small-phone scoring, optimistic delivery feedback, and unchanged scoring-engine tests.

### Phase 3 — Match lifecycle

Over summary/bowler selection, wicket/extras sheets, innings break, match result, and resume restoration.

Approval gate: eligibility reasons, innings transitions, back navigation, match completion, and reduced-motion behavior.

### Phase 4 — History and sharing

Paged history, full scorecard, branded PDF, selected-match preview, and sharing.

Approval gate: real match data parity between app and PDF, pagination performance, and offline generation.

### Phase 5 — Personalization

Jersey badge, curated presets, profile/settings, backup, and optional home widget.

Approval gate: preference persistence, preset contrast, backup safety, and no critical scoring-control customization.

## 19. Automated UI acceptance matrix

The requested 20 tests become the minimum suite:

1. zero teams → Build Your First Team;
2. one team → Create Second Team;
3. two eligible teams → Create Match;
4. active match → Resume Scoring;
5. back navigation preserves scoring state;
6. primary scoring controls remain visible at compact height/width;
7. a delivery updates without a full-screen loader;
8. dark-theme critical text meets contrast and remains readable;
9. theme mode and preset persist across app restart;
10. 200% text does not clip critical content;
11. unavailable bowlers expose a human-readable reason;
12. completed state shows the winner/result;
13. completed match appears in history;
14. PDF preview receives the selected match ID/state;
15. offline scoring shows “Saved on this device”;
16. primary interactive targets are at least 48 × 48;
17. interactive and status elements expose semantic labels;
18. reduced motion removes nonessential animations;
19. tablet scoring uses split layout without stretched cards;
20. production navigation contains no demo route or demo data.

Add unit coverage for token/preset mapping and preference serialization, widget tests for empty/loading/error states, semantics tests for scoring and bowler selection, golden tests for compact/light/dark/tablet states, and integration tests for the complete match lifecycle.

## 20. Current-product fit and known gaps

The existing product already has a separate scoring engine, Drift local persistence, Riverpod, GoRouter, sync queue, PDF generation, team/player flows, match setup, and lifecycle sheets. Those are preserved.

The redesign must address these observed presentation and performance gaps:

- only a light theme is currently supplied;
- theme, haptic, sound, and reduced-motion settings are not persisted;
- screens contain direct colours, radii, and text styles outside a shared system;
- `main.dart` owns routing and several full screen implementations;
- normal route loads use full-screen spinners;
- Home team cards fetch players individually;
- match history loads and sorts the complete table in memory;
- scoring controls mix colour meanings and abbreviations;
- the production welcome flow exposes a demo destination;
- current PDF styling uses the old green palette and lacks several requested sections;
- current result and innings-break experiences do not yet expose the full premium information set.

These gaps are implementation work, not reasons to replace existing user data or scoring logic.

## Approval decision

Approval of this document authorizes Phase 1 only. Each later phase remains independently reviewable, and presentation changes stay separated from scoring-engine changes.
