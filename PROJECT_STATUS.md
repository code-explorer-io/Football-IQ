# Football IQ - Project Status

**Last Updated:** 2024-12-28

## READ THIS FIRST
When starting a new session, have Claude read this file to get full context.

---

## Current State: V1 Complete - Ready for Distribution

### App Overview
Football quiz app with "premium pub quiz" aesthetic. Sports betting app confidence, not childish. Adult gamification.

### Game Modes (5 total)
1. **Quiz Your Club** - Club-specific questions (Arsenal, Man City, West Ham)
2. **PL Legends** - Premier League legends trivia
3. **Survival Mode** - One wrong answer ends the game, streak-based
4. **Higher or Lower** - Compare player stats
5. **Timed Blitz** - 60 seconds, answer as many as possible (NEW - replaced Iconic Moments)

### Key Features Implemented
- **Football IQ Rating** (0-99 like FIFA) - tracks performance across sessions
- **Form Guide** (W/D/L) - last 5 results shown as boxes
- **Achievements** - 20+ football-themed (Clean Sheet, Hat Trick, Century Maker, etc.)
- **Haptic Feedback** - subtle vibrations on interactions
- **Confetti** - celebrations for perfect scores/new bests
- **Google Fonts** - Montserrat (headers) + Inter (body)

### Tech Stack
- Flutter/Dart
- SharedPreferences for local persistence
- No backend (all local for V1)

---

## Distribution Plan

### Android
- **Google Play Developer Account:** PENDING APPROVAL (paid $25, waiting)
- Once approved: Use **Internal Testing** track
- Add tester emails, they get Play Store link
- Skip APK route - Play Store is cleaner

### iOS
- **Apple Developer Account:** Need to sign up ($99/year)
- **Codemagic:** Cloud CI/CD that builds iOS without a Mac
  - Sign up at codemagic.io
  - Connect GitHub repo
  - Connect Apple Developer account
  - Auto-builds and uploads to TestFlight
- No Mac needed - Codemagic handles it

---

## Tomorrow's Tasks
1. Check if Google Play approved
2. If approved: Set up Internal Testing, add tester emails
3. Sign up for Apple Developer ($99)
4. Set up Codemagic account and connect to GitHub
5. Configure Codemagic to build iOS and push to TestFlight

---

## File Structure (Key Files)
```
lib/
  models/
    game_mode.dart        # Game mode definitions
  screens/
    home_screen.dart      # Main menu with stats row
    timed_blitz_screen.dart  # NEW - 60 second blitz mode
    survival_mode_screen.dart
    higher_or_lower_screen.dart
    question_screen.dart
    results_screen.dart
  services/
    score_service.dart    # Best scores, blitz scores, streaks
    stats_service.dart    # Football IQ, form guide
    achievement_service.dart
    haptic_service.dart
  theme/
    app_theme.dart        # Colors, typography
  widgets/
    form_guide.dart       # W/D/L display, IQ badge
    animated_button.dart
assets/
  data/
    survival_mode.json    # Also used by Timed Blitz
    premier_league_legends.json
    higher_or_lower.json
    arsenal.json / manchester_city.json / west_ham.json
```

---

## Design Philosophy
- "Sports betting app confidence" - premium, adult, restrained
- No childish colors or excessive emojis
- Dark theme (#1A1A2E background)
- Gold accents for achievements
- Football terminology (Clean Sheet, not "Perfect Score")

---

## Notes
- User has Windows PC, no Mac
- Codemagic is the solution for iOS builds without Mac
- Focus on Android friends first for testing
- iOS via Codemagic + TestFlight once Apple Developer account is set up
