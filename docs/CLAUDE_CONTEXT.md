# Claude Session Context

> Read this file at the start of each session to understand the project.

---

## Project Summary

**Football IQ** is a mobile quiz app for football fans. Users pick their club and answer trivia questions to prove their knowledge.

**Key differentiators:**
- Club-first (not generic football trivia)
- Zero ads (trust signal vs ad-heavy competitors)
- One-time purchase (no subscriptions)
- Premium feel with clean UX

---

## Tech Stack

| Component | Choice |
|-----------|--------|
| Framework | Flutter |
| State | Provider (to be added in Phase 2) |
| Data | Local JSON files |
| Purchases | Google Play Billing (to be added) |

---

## Current Phase: Foundation (Phase 1)

**Goal:** Can you tap through the entire flow?

### Completed
- [x] Flutter project runs without errors
- [x] Splash screen
- [x] Home screen with 3 club cards
- [x] Quiz intro screen
- [x] Question screen with 4 answers
- [x] Results screen with verdict
- [x] Navigation flow works end-to-end
- [x] Question JSON format defined
- [x] 40 questions per club (120 total)

### Foundation DONE when:
> You can tap through Home -> Club -> Quiz -> Questions -> Results -> Home even if it looks ugly.

**Status: Essentially complete. Ready for Phase 2.**

---

## Project Structure

```
Football-IQ/
├── lib/
│   ├── main.dart           # App entry, theme, routing
│   ├── models/
│   │   ├── club.dart       # Club model with colors
│   │   └── question.dart   # Question model with fromJson
│   └── screens/
│       ├── splash_screen.dart
│       ├── home_screen.dart      # Club selection
│       ├── quiz_intro_screen.dart
│       ├── question_screen.dart  # Quiz gameplay
│       └── results_screen.dart   # Score + verdict
├── assets/data/
│   ├── west_ham.json       # 40 questions (FREE tier)
│   ├── manchester_city.json # 40 questions (PAID)
│   └── arsenal.json        # 40 questions (PAID)
├── docs/
│   └── CLAUDE_CONTEXT.md   # This file
└── FOOTBALL_IQ.md          # Master document (full PRD)
```

---

## Key Files to Read

1. **FOOTBALL_IQ.md** - Full PRD with all decisions, phases, monetization
2. **lib/models/club.dart** - Club definitions (West Ham free, others locked)
3. **lib/screens/question_screen.dart** - Core quiz logic

---

## Monetization

| Tier | Access |
|------|--------|
| Free | West Ham only, full functionality, zero ads |
| Paid (£2.49) | All clubs unlocked, one-time purchase |

---

## Next Phase: Functionality (Phase 2)

**Goal:** Does the main thing actually work?

- [ ] 10 random questions (no repeats within quiz)
- [ ] Correct/incorrect feedback
- [ ] Cannot change answer after selecting
- [ ] Score calculated correctly
- [ ] Best score saved locally (SharedPreferences)
- [ ] Best score persists after app close
- [ ] 40+ questions per club available

---

## Commands

```bash
# Run in Chrome (web)
flutter run -d chrome

# Run on Android device/emulator
flutter run -d android

# Get dependencies
flutter pub get

# Check Flutter setup
flutter doctor
```

---

## Decision Log

| Decision | Rationale |
|----------|-----------|
| Android first | Sean has Android device, simpler for v1 |
| Zero ads | Differentiator vs competitors |
| £2.49 one-time | Impulse-buy territory |
| Provider for state | Simpler than GetX/Bloc for this scale |
| Local JSON | No server costs, offline-first |

---

## Roles

| Sean (Product Owner) | Claude (Developer) |
|---------------------|-------------------|
| Vision & decisions | All code |
| Review questions | Generate draft questions |
| Test on device | Build & debug |
| Approve phase completion | Follow the framework |

---

*Last updated: 2024-12-28*
