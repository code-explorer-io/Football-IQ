# Claude Session Context

> **READ THIS FILE FIRST** at the start of each session to get up to speed quickly.

---

## Quick Summary

**Football IQ** - Premium football quiz app with a "Sky Sports / Match of the Day" broadcast aesthetic.

**Current state:** V1.0.0+6 on Google Play (internal testing). RevenueCat in-app purchases integrated.

**Design philosophy:** Professional broadcast feel. No childish emojis - use Material icons. "NEW RECORD" not "NEW BEST!". "Kick Off Again" not "Play Again".

---

## What to Read at Session Start

| Priority | File | Purpose |
|----------|------|---------|
| 1 | `docs/CLAUDE_CONTEXT.md` | This file - quick context |
| 2 | `SETUP.md` | Environment setup, Git troubleshooting, Flutter commands |
| 3 | `docs/PHASE_STATUS.md` | Feature progress tracking |
| 4 | `docs/FOOTBALL_IQ.md` | Master project document |

**For architecture details:** Scan `lib/` folder structure and `pubspec.yaml` dependencies.

---

## Tech Stack

| Component | Details |
|-----------|---------|
| Framework | Flutter 3.38.5 / Dart |
| State | StatefulWidget + SharedPreferences |
| Analytics | Firebase Analytics |
| Monetization | RevenueCat (in-app purchases) |
| Animations | Lottie (splash), custom AnimationController |
| Audio | audioplayers package (SoundService) |

---

## App Architecture

### Game Modes (5 total)
1. **Quiz Your Club** - Club-specific questions (always unlocked - starter mode)
2. **Higher or Lower** - Compare player stats (unlock: complete 1 Quiz Your Club)
3. **Timed Blitz** - 60 seconds speed round (unlock: score 70%+)
4. **Survival Mode** - One wrong ends game (unlock: 10+ streak)
5. **Cup Mode** - Knockout tournament (unlock: complete all other modes)

### Key Services
- `UnlockService` - Mode gating and progression
- `XPService` - Levels and experience points
- `StreakService` - Daily streak tracking
- `AnalyticsService` - Firebase event logging
- `SoundService` - Audio playback (needs sound files)

### Gamification System
- **XP/Levels**: Long-term progression (10 XP per correct, bonuses for streaks/perfect)
- **Unlocks**: Short-term goals (complete specific tasks to unlock modes)
- **Streaks**: Daily engagement (play once per day to maintain)

---

## Development Environment

### Working Paths
| Tool | Location |
|------|----------|
| Git | `C:\Program Files\Git\cmd\git.exe` |
| Flutter | `C:\Flutter\flutter\bin\flutter` |
| Android SDK | `C:\Users\seanm\AppData\Local\Android\Sdk` |
| Java JDK | `C:\Program Files\Eclipse Adoptium\jdk-17.0.17.10-hotspot` |

### Verification Commands
```cmd
git --version          # Should show 2.52.0.windows.1
flutter doctor         # Should show all green checks
flutter devices        # List available emulators/devices
```

---

## Known Issues & Solutions

### Git Issues (CRITICAL - We've hit this multiple times!)

**Problem:** "git is not recognized" or GitHub Desktop ENOENT errors

**Root cause:** Git for Windows installation can get corrupted, leaving only helper tools without the main `git.exe`.

**Solution:**
1. Check if Git works from command line: `git --version`
2. If not: Uninstall Git, reinstall from https://git-scm.com/download/win
3. Restart VS Code completely (terminals inherit PATH at launch)
4. If GitHub Desktop fails but command line works, use command line:
   ```cmd
   git status
   git add .
   git commit -m "message"
   git push
   ```

**See `SETUP.md` for full troubleshooting guide.**

### Flutter Cache Issues
```cmd
flutter clean
flutter pub get
```

---

## Recent Changes Log

### December 30, 2024
- **RevenueCat Integration**: Added in-app purchase system for "Unlock All Modes" (£2.49)
- **Unlock Progression System**: Modes now gate based on player achievements
- **UI Polish**: Glow animations on cards, shimmer on unlock button, pulse on streak-at-risk
- **Broadcast Aesthetic**: Emoji → Material icons, refined copy ("NEW RECORD", "Kick Off Again")
- **Lottie Splash**: Animated soccer ball on app launch
- **Sound Service**: Foundation built (awaiting audio files)
- **Git Resolution**: Fixed corrupted Git installation, documented troubleshooting

### Earlier
- Firebase Analytics integration
- XP/Level gamification system
- Streak tracking with SharedPreferences
- Google Play internal testing setup

---

## Pending Tasks

### Tomorrow's Priorities
1. Add sound effect files to `assets/sounds/`
2. Test unlock progression end-to-end
3. Review Play Store readiness
4. Test on real device (not just emulator)

### Sound Files Needed
- `correct.mp3` - Confirmation tone
- `wrong.mp3` - Miss indicator
- `tick.mp3` - Timer countdown
- `win.mp3` - Victory fanfare
- `unlock.mp3` - Mode unlock celebration

---

## User Context

- Sean is on Windows PC, no Mac
- Uses Android phone for testing
- Google Play account is active (internal testing)
- Apple Developer pending ($99)
- Uses GitHub Desktop but command line works when GUI fails

---

## Key Files to Know

| File | Purpose |
|------|---------|
| `lib/main.dart` | App entry, Firebase init |
| `lib/screens/home_screen.dart` | Main menu, mode cards, gamification header |
| `lib/services/unlock_service.dart` | Mode progression logic |
| `lib/theme/app_theme.dart` | Colors, typography constants |
| `pubspec.yaml` | Dependencies |
| `android/app/build.gradle.kts` | Android build config |

---

*Last updated: January 21, 2026*
