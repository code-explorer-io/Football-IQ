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
9. [Current Status](#current-status)
10. [Nice-to-Have Ideas](#10-nice-to-have-ideas-brainstorm)

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

### Content Pipeline Strategy
**Build ahead, release strategically.**

| Phase | What users see | What we have ready |
|-------|----------------|-------------------|
| Launch | 1 game mode (Quiz Your Club) | 3-4 modes built and tested |
| Week 2 | "New! Barclays Men" | Already done, just switched on |
| Week 4 | "New! Iconic Moments" | Already done |
| Week 6 | "New! Kit Sponsors" | Already done |

**Why this works:**
- App Store loves updates — regular releases push rankings
- Re-engagement — "New mode dropped" brings users back
- Perceived momentum — app feels alive and growing
- Quality control — not rushing while live
- Flexible timing — release when ready, no pressure

**Technical implementation:**
Each game mode controlled by config flag. Flip to `true` → appears in app.

### Game Modes (Planned)
| Mode | Description | Status |
|------|-------------|--------|
| Quiz Your Club | Deep knowledge about your team | v1.0 |
| Barclays Men | Name the Premier League legends | Backlog |
| Iconic Moments | Questions about famous matches | Backlog |
| Kit Sponsors | Guess the shirt sponsor by year | Backlog |
| Nostalgia Round | "Which year did..." format | Backlog |

### Pre-Launch Setup
- [x] GitHub repo created
- [x] Google Play Developer account ($25)
- [ ] Privacy policy (free GitHub Pages)
- [ ] App icon designed
- [ ] Store listing screenshots

### Testing Strategy (Google Play)
| Track | Audience | Review | Use case |
|-------|----------|--------|----------|
| Internal testing | Up to 100 (email invite) | None - instant | First 2-3 friends |
| Closed testing | Invite-only groups | Light (~hours) | 5-10 testers |
| Open testing | Anyone with link | Full review | 50+ testers |
| Production | Everyone | Full review | Public launch |

### iOS Deployment (Post-Android)
- Apple Developer account ($99/year)
- Build via Codemagic (cloud Mac service)
- Distribute via TestFlight
- No Mac hardware required

### Store Listing

**Short description (80 chars):**
```
Think you know football? Test yourself.
```

**Full description:**
```
How much do you really know about football?

Football IQ tests your knowledge with questions that separate the casuals from the diehards. No generic trivia - just real football knowledge.

MULTIPLE GAME MODES
• Quiz Your Club - Pick your team, prove your knowledge
• Barclays Men - Name the legends of the Premier League era
• More modes coming soon

PICK YOUR CLUB
Choose from West Ham, Manchester City, Arsenal and more. Questions cover history, legends, memorable matches, and records.

TEST YOURSELF
• 10 questions per quiz
• Mixed difficulty
• Track your best scores

NO ADS. EVER.

Built by fans, for fans.
```

---

## Current Status

| Item | Status |
|------|--------|
| PRD | Complete |
| Monetization strategy | Complete |
| Technical decisions | Complete |
| Phase checklists | Complete |
| Google Play account | Complete |
| Flutter + Android Studio | Complete |
| Questions drafted | Complete (120 questions) |
| Android emulator | In progress |
| Flutter project | Not started |

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
| 2024-12-28 | Content pipeline | Build modes ahead, release strategically |
| 2024-12-28 | iOS via Codemagic | No Mac needed, cloud builds |

---

## 10. Nice-to-Have Ideas (Brainstorm)

*Future features to explore. Not committed, just captured.*

### Engagement Features
| Idea | Description | Complexity |
|------|-------------|------------|
| **Daily Streak** | Duolingo-style streak counter, play daily to maintain | Low |
| **Fact of the Day** | Random football fact on home screen, refreshes daily | Low |
| **Weekly Challenge** | New themed quiz each week (e.g., "90s Strikers Week") | Medium |

### Social Features
| Idea | Description | Complexity |
|------|-------------|------------|
| **Share Score Card** | Generate image of results for Instagram/WhatsApp | Medium |
| **Head-to-Head** | Challenge a friend, compare scores on same questions | High |
| **Leaderboards** | Global/friends ranking per club | High (needs server) |

### Game Modes (Wild Ideas)
| Idea | Description | Complexity |
|------|-------------|------------|
| **Blitz Mode** | 30 seconds, answer as many as possible | Medium |
| **Survival Mode** | One wrong answer and you're out | Low |
| **Audio Round** | Play commentary clips, identify the moment | High |
| **Picture Round** | Blurred player photos, guess who | Medium |
| **Transfer Chain** | "Player X went from ___ to ___ to ___" | Medium |
| **Derby Day** | Questions only about rivalry matches | Low |
| **World Cup Mode** | International tournament questions | Low (content) |
| **Retro Kits** | Show old kit, guess year/sponsor | Medium |

### Monetization Ideas
| Idea | Description | Complexity |
|------|-------------|------------|
| **Club Packs** | Buy individual clubs instead of all | Low |
| **Season Pass** | Annual unlock for all new content | Medium |
| **Merch Integration** | Link to club stores from results | Low |

### Viral Mechanics
| Idea | Description | Complexity |
|------|-------------|------------|
| **"I scored X on Y club"** | Shareable results with club branding | Medium |
| **Rival Roast** | Score well on rival club, get banter text to share | Low |
| **Prove Your Mate Wrong** | Send challenge link to specific quiz | Medium |

### Polish Ideas
| Idea | Description | Complexity |
|------|-------------|------------|
| **Club Themes** | Colours change based on selected club | Medium |
| **Achievement Badges** | "Completed all clubs", "10 streak", etc. | Medium |
| **Sound Effects** | Crowd roar for correct, groan for wrong | Low |
| **Haptic Feedback** | Vibration on answer selection | Low |
