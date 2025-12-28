# Football IQ: Master Document

> One source of truth for the entire project.

---

## Table of Contents
1. [Project Overview](#1-project-overview)
2. [Monetization Strategy](#2-monetization-strategy)
3. [Technical Decisions](#3-technical-decisions)
4. [Four-Part Framework](#4-four-part-framework)
5. [Phase Checklists](#5-phase-checklists)
6. [Competitor Analysis](#6-competitor-analysis)
7. [Content Strategy](#7-content-strategy)
8. [Release Plan](#8-release-plan)

---

## 1. Project Overview

### Vision
A clean, trustworthy football quiz that feels premium compared to ad-heavy competitors. Club-first identity — pick your team and prove your fandom.

### Core Value Proposition
- **Club-first:** Not generic football trivia — deep knowledge about YOUR club
- **Zero ads in free tier:** Immediate trust signal
- **Quick sessions:** 10 questions, 60-120 seconds, satisfying results
- **One-time purchase:** No subscriptions, no commitment anxiety

### Target Users
| Persona | Behavior | Monetization |
|---------|----------|--------------|
| **Loyal Fan** | Supports one club strongly, wants to prove knowledge | Likely to pay |
| **Competitive Friend** | Compares scores, tries multiple clubs | Drives sharing |
| **Casual Browser** | Tries one quiz, may not return | Free tier user |

### Success Metrics
| Metric | Minimum | Target |
|--------|---------|--------|
| Day-1 retention | 15% | 25% |
| Quiz completion rate | 70% | 85% |
| Conversion to paid | 2% | 4% |
| App store rating | 4.0 | 4.5+ |
| Crash-free sessions | 99% | 99.5% |

---

## 2. Monetization Strategy

### Model: Freemium (No Ads)

#### Free Tier
- 1 club fully unlocked (West Ham)
- 10 questions per quiz
- Full functionality
- Zero ads
- Best score tracking

#### Paid Unlock: £2.49 (one-time)
- All clubs unlocked
- All future clubs included
- "Supporter Badge" on results screen

### Why This Model?
| Decision | Rationale |
|----------|-----------|
| Zero ads | Differentiator — competitors are ad-heavy |
| One-time purchase | Casual games don't suit subscriptions |
| £2.49 price | Impulse-buy territory, not too cheap |
| Visible locked content | Creates desire without frustration |

### Revenue Projections

| Scenario | Downloads | Conv. Rate | Revenue (Net) |
|----------|-----------|------------|---------------|
| Conservative | 10,000 | 2% | £338 |
| Moderate | 50,000 | 3% | £3,175 |
| Optimistic | 100,000 | 4% | £10,166 |

*Google takes 15% for developers under $1M revenue*

---

## 3. Technical Decisions

### Stack
| Component | Choice | Why |
|-----------|--------|-----|
| Framework | Flutter | One codebase for Android + iOS |
| State Management | Provider | Simple, built-in, maintainable |
| Data Storage | Local JSON + SharedPreferences | Offline-first, no server costs |
| Analytics | Firebase Analytics | Free, industry standard |
| Purchases | Google Play Billing | Required for Android |

### Project Structure
```
lib/
  ├── constants/
  │   ├── colors.dart
  │   └── dimensions.dart
  ├── models/
  │   ├── club.dart
  │   ├── question.dart
  │   └── quiz_result.dart
  ├── providers/
  │   └── quiz_provider.dart
  ├── screens/
  │   ├── home/
  │   ├── quiz/
  │   └── result/
  ├── services/
  │   └── question_service.dart
  └── main.dart

assets/
  ├── data/
  │   ├── west_ham.json
  │   ├── manchester_city.json
  │   └── arsenal.json
  └── images/
      └── clubs/
```

### Question JSON Format
```json
{
  "id": "whu_001",
  "question": "Who scored the winning goal in the 1980 FA Cup Final?",
  "options": ["Trevor Brooking", "Billy Bonds", "Alan Devonshire", "Frank Lampard Sr"],
  "answerIndex": 0,
  "difficulty": "hard",
  "explanation": "Trevor Brooking headed the only goal to beat Arsenal 1-0."
}
```

---

## 4. Four-Part Framework

### The Golden Rule
**One phase at a time. Don't polish what doesn't work yet.**

### The Four Phases
| Phase | Name | Goal | Done When |
|-------|------|------|-----------|
| 01 | **Foundation** | Get the skeleton in place | Can you see it running? |
| 02 | **Functionality** | Make it actually work | Does the main thing work? |
| 03 | **Polish** | Now make it look pretty | Would you show this to someone? |
| 04 | **Test** | Catch what you missed | Can a stranger use it? |

---

## 5. Phase Checklists

### Phase 1: Foundation

*Goal: Can you see it running on your phone/emulator?*

#### Setup
- [ ] Flutter project created and runs without errors
- [ ] Project structure organised
- [ ] App runs on Android emulator
- [ ] App runs on physical Android phone

#### Screens (ugly placeholders are fine)
- [ ] Splash screen — App logo/name
- [ ] Home screen — Shows 3 club cards
- [ ] Quiz intro screen — Club name, "Start Quiz" button
- [ ] Question screen — Question text, 4 answer buttons, progress
- [ ] Results screen — Score display, "Play Again" / "Change Club" buttons

#### Navigation
- [ ] Can tap a club card → goes to quiz intro
- [ ] Can tap "Start Quiz" → goes to question screen
- [ ] After 10 questions → goes to results screen
- [ ] Can return to home from results

#### Data Structure
- [ ] Question JSON format defined
- [ ] Sample questions loaded (5 per club minimum)
- [ ] Club data structure defined

#### Foundation DONE when:
> You can tap through the entire flow (Home → Club → Quiz → Questions → Results → Home) even if it looks ugly.

---

### Phase 2: Functionality

*Goal: Does the main thing actually work?*

#### Quiz Logic
- [ ] 10 random questions selected from pool (no repeats)
- [ ] Tapping an answer registers the selection
- [ ] Correct/incorrect feedback shown
- [ ] Cannot change answer after selecting
- [ ] Auto-advance to next question
- [ ] Score calculated correctly at end

#### Data & State
- [ ] Questions load from JSON files
- [ ] 40+ questions per club available
- [ ] Current quiz state tracked
- [ ] Best score per club saved locally
- [ ] Best score persists after closing app

#### Results
- [ ] Final score displayed (e.g., "7/10")
- [ ] "Fan verdict" shown (True Fan / Matchday Regular / Tourist)
- [ ] "Play Again" resets quiz with new random questions
- [ ] "Change Club" returns to home

#### Functionality DONE when:
> You can play a full quiz, get a score, see your verdict, replay with different questions, and your best score is remembered.

---

### Phase 3: Polish (Later)

- [ ] Consistent colour scheme (2-3 colours)
- [ ] Club cards look appealing
- [ ] Smooth transitions between screens
- [ ] Answer feedback animations
- [ ] Progress bar looks polished
- [ ] Results screen feels rewarding
- [ ] App icon designed

---

### Phase 4: Test (Later)

- [ ] Works on small phones
- [ ] Works on tablets
- [ ] No crashes in 20 consecutive quizzes
- [ ] Friend can complete quiz without asking questions
- [ ] All questions reviewed for accuracy

---

## 6. Competitor Analysis

### Play Store Competition
| App | Strength | Weakness (Our Opportunity) |
|-----|----------|---------------------------|
| Football Quiz! Ultimate Trivia | 4.8 rating, 3M downloads | Generic, not club-focused |
| Football Club Quiz | Simple concept | Logo guessing only, shallow |
| Football AI Quiz Master | AI-powered | Needs internet, can be wrong |
| Most quiz apps | Large question banks | Ad-heavy, poor UX |

### Our Differentiators
1. **Club-first identity** — not generic trivia
2. **Zero ads** — trust signal
3. **Deep knowledge** — not just "guess the logo"
4. **Premium feel** — clean UX

### GitHub Patterns to Use
| Pattern | Source |
|---------|--------|
| 3-screen flow | Quiz-App-Flutter |
| Provider state management | oranthony/quiz_app |
| Green/red feedback | Quiz-App-Flutter |
| Constants file | QuizzieThunder |
| Local JSON data | Multiple repos |

---

## 7. Content Strategy

### Starter Clubs
1. **West Ham** (free tier) — 40+ questions
2. **Manchester City** (paid) — 40+ questions
3. **Arsenal** (paid) — 40+ questions

### Question Categories
- Club history
- Famous players
- Memorable matches
- Managers
- Stadiums & rivalries
- Records & stats

### Quality Bar
- No ambiguous wording
- One clearly correct answer
- Plausible wrong options
- UK spelling consistency
- Mix of difficulties (easy/medium/hard)

### Content Pipeline
1. AI generates draft questions
2. You review for accuracy
3. Fix errors, improve wording
4. Bundle into JSON
5. Beta feedback identifies weak questions
6. Iterate and improve

---

## 8. Release Plan

### Version Milestones
| Version | Scope |
|---------|-------|
| v0.1 | Basic UI + 1 club + 20 questions |
| v0.2 | 3 clubs + scoring + results |
| v0.3 | 40+ questions per club + polish |
| v0.4 | In-app purchase + paywall |
| v1.0 | Production release |

### Pre-Launch Setup
- [x] GitHub repo created
- [ ] Google Play Developer account ($25)
- [ ] Privacy policy (free GitHub Pages)
- [ ] App icon designed
- [ ] Store listing screenshots

### Testing Strategy
1. **You** — Test on emulator + your phone
2. **Beta testers** — Friends test via internal track
3. **Closed beta** — Wider group via Google Play
4. **Production** — Staged rollout (10% → 50% → 100%)

---

## Current Status

| Item | Status |
|------|--------|
| PRD | Complete |
| Monetization strategy | Complete |
| Technical decisions | Complete |
| Phase checklists | Complete |
| Google Play account | Not started |
| Flutter project | Not started |
| Questions drafted | Not started |

---

## Roles

| You (Product Owner) | Claude (Developer) |
|---------------------|-------------------|
| Vision & decisions | All code |
| Review questions for accuracy | Generate draft questions |
| Test on your device | Build & debug |
| Approve phase completion | Follow the framework |
| Content quality | Technical quality |

---

## Key Decisions Log

| Date | Decision | Rationale |
|------|----------|-----------|
| 2024-12-28 | Android only for v1 | Simpler, you have Android device |
| 2024-12-28 | 3 starter clubs | West Ham (free), Man City, Arsenal (paid) |
| 2024-12-28 | Zero ads | Differentiator |
| 2024-12-28 | £2.49 unlock price | Impulse-buy sweet spot |
| 2024-12-28 | Provider for state | Simpler than GetX/Bloc |
| 2024-12-28 | Local JSON | No server costs, offline-first |
