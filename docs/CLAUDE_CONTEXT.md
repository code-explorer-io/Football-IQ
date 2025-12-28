# Claude Session Context

> **READ THIS FILE FIRST** at the start of each session.

---

## Quick Summary

**Football IQ** - Premium football quiz app. "Sports betting app confidence, not childish."

**Current state:** V1 complete, ready for distribution to testers.

**Immediate goal:** Get app into hands of Android and iOS friends for testing.

---

## The Docs Folder

| File | Purpose |
|------|---------|
| `CLAUDE_CONTEXT.md` | This file - read first for quick context |
| `PHASE_STATUS.md` | Detailed phase progress and next steps |
| `../FOOTBALL_IQ.md` | Full PRD with all decisions, monetization, content strategy |

---

## App Overview

### Game Modes (5 total)
1. **Quiz Your Club** - Club-specific questions (Arsenal, Man City, West Ham)
2. **PL Legends** - Premier League legends trivia
3. **Survival Mode** - One wrong answer ends the game
4. **Higher or Lower** - Compare player stats
5. **Timed Blitz** - 60 seconds, answer as many as possible

### Key Features
- Football IQ Rating (0-99, like FIFA player ratings)
- Form Guide (W/D/L boxes showing last 5 results)
- 20+ Achievements (football-themed: Clean Sheet, Hat Trick, etc.)
- Haptic feedback, confetti celebrations
- Dark theme (#1A1A2E), premium pub quiz aesthetic

### Tech Stack
- Flutter/Dart
- SharedPreferences (local persistence)
- No backend for V1

---

## Distribution Plan

### Android
| Item | Status |
|------|--------|
| Google Play Developer Account | Paid $25, **awaiting approval** |
| Distribution method | Internal Testing track (once approved) |
| How testers get app | Email invite → Play Store link |

### iOS (No Mac needed!)
| Item | Status |
|------|--------|
| Apple Developer Account | **Need to sign up** ($99/year) |
| Build method | **Codemagic** (cloud CI/CD with Mac servers) |
| Distribution | TestFlight |
| How it works | Push to GitHub → Codemagic builds → TestFlight |

---

## Key Decisions Made

| Decision | Why |
|----------|-----|
| Skip APK route | Wait for Google Play approval - cleaner for testers |
| Codemagic for iOS | No Mac needed, builds in cloud |
| "Timed Blitz" not "Iconic Moments" | Adds different energy (speed) vs same-vibe trivia |
| 3 answer options | Faster to read in timed modes |
| Premium pub quiz aesthetic | Adult, confident, not childish |

---

## File Structure (Key Files)

```
lib/
  models/game_mode.dart         # Game mode definitions
  screens/
    home_screen.dart            # Main menu with stats
    timed_blitz_screen.dart     # 60 second blitz mode
    survival_mode_screen.dart   # Endless until wrong
    higher_or_lower_screen.dart # Stat comparisons
  services/
    score_service.dart          # Best scores, streaks
    stats_service.dart          # Football IQ, form guide
    achievement_service.dart    # 20+ achievements
  theme/app_theme.dart          # Colors, typography
assets/data/
    survival_mode.json          # Also used by Timed Blitz
    premier_league_legends.json
    higher_or_lower.json
    arsenal.json / manchester_city.json / west_ham.json
```

---

## Tomorrow's Tasks

1. Check if Google Play developer account approved
2. If approved: Set up Internal Testing, add tester email addresses
3. Sign up for Apple Developer ($99)
4. Create Codemagic account at codemagic.io
5. Connect GitHub repo to Codemagic
6. Configure Codemagic to build iOS and push to TestFlight

---

## User Context

- Sean has Windows PC, no Mac
- Android phone for testing
- Friends on both Android and iOS need to test
- Google Play account pending
- Willing to invest $99 for Apple Developer

---

*Last updated: 2024-12-28*
