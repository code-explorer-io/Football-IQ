# Football IQ - Visual Upgrade Plan

> **Session Summary**: Comprehensive visual storytelling plan using AI-generated backgrounds to create emotional arcs across game modes.

---

## What We Accomplished (30th-31st December)

### 30th December
- Timer feature on all questions (12s countdown, red warning at 3s)
- Fast answer bonus XP system (+5 XP per answer under 5 seconds)
- Stadium background (`stadium_night.png`) applied to ALL screens
- Dev mode unlock enabled for testing all game modes
- Visual strategy document created (`VISUAL_STRATEGY.md`)
- Game states fully mapped across all modes
- Level titles updated: Amateur → Park Footballer → Sunday League → Club Player → Semi-Pro → Professional → International → Elite → World Class → Icon → Legend

### 31st December (Code Infrastructure - COMPLETE)
- [x] `BackgroundZone` enum added to `pitch_background.dart` (stadium, tunnel, dugout, results, void_)
- [x] `PitchBackground.zone()` named constructor for zone-based backgrounds
- [x] Zone-specific overlay opacity (30%-50%) for text readability
- [x] Graceful fallback to `stadium_night.png` when zone images don't exist
- [x] ALL screens wired to correct zones:
  - Splash, Intro screens → `tunnel`
  - Question/Gameplay screens → `dugout`
  - Results screens → `results`
  - Home/Hub screens → `stadium`
- [x] Survival Mode "Void" death transition implemented (200ms fade to black → 500ms hold → fade to results)
- [x] Video splash infrastructure added (`video_player` package)
- [x] Splash screen auto-detects `tunnel.mp4` and plays if available, otherwise uses static fallback

---

## What's Left To Do (Sean's Tasks)

### Generate Images
Use ChatGPT/DALL-E with these prompts:

#### Prompt 1: Tunnel
```
Photorealistic football stadium tunnel at night, POV from inside looking toward bright green pitch at tunnel exit, dark concrete walls with subtle texture, dramatic light at the end creating god-rays, wet floor reflecting the light, intense atmosphere of anticipation, 4K quality, vertical 9:16 mobile aspect ratio, cinematic lighting, no people, no text, no logos, the feeling of walking out to play
```

#### Prompt 2: Dugout
```
Photorealistic football dugout bench at night from behind the seats looking toward the pitch, blue leather manager seats in foreground, tactical whiteboard with formations visible, water bottles and medical kit on side table, green pitch edge visible through dugout opening, stadium floodlights creating dramatic backlighting, intimate tactical atmosphere, 4K quality, vertical 9:16 mobile aspect ratio, cinematic lighting, no people, no text, no logos
```

#### Prompt 3: Empty Pitch (Optional)
```
Photorealistic empty football pitch at night after a match, pristine green grass with visible line markings, empty stadium seats in background, single spotlight creating dramatic shadows, quiet reflective atmosphere, 4K quality, vertical 9:16 mobile aspect ratio, cinematic lighting, no people, no text, no logos, the calm after the game
```

#### Prompt 4: Luma Animation (Bonus)
Take `tunnel.png` and animate with:
```
Slow walk forward through the tunnel toward the light, camera moving forward steadily, light getting brighter as we approach the pitch
```

### Add Images to Project
1. Save images to `assets/images/`:
   - `tunnel.png`
   - `dugout.png`
   - `pitch_empty.png` (optional)
   - `tunnel.mp4` (optional - for animated splash)

2. The code is ready - images will be used automatically once added!

---

## The Core Insight

**Don't animate screens. Animate moments.**
**Don't decorate the app. Signal game state.**

Every user session should tell a visual story with an emotional arc.

---

## Visual Zones (The Solution)

### Zone 1: THE STADIUM (Hub/Home)
- **Screens**: Home, Stats, Mode Selection
- **Image**: `stadium_night.png` (HAVE)
- **Feeling**: Wide, open, possibilities
- **Overlay**: Light (30% dark)

### Zone 2: THE TUNNEL (Entry/Anticipation)
- **Screens**: All Intro Screens, Splash Screen
- **Image**: `tunnel.png` (TO GENERATE)
- **Feeling**: Walking toward something, building tension
- **Overlay**: Medium (40% dark)

### Zone 3: THE DUGOUT (Active Play)
- **Screens**: ALL gameplay/question screens
- **Image**: `dugout.png` (TO GENERATE)
- **Feeling**: Intimate, focused, tactical decisions
- **Overlay**: Medium-heavy (50% dark) for text readability

### Zone 4: THE VOID (Death/Failure - Survival Only)
- **Screens**: Survival wrong answer transition
- **Image**: None - pure black (CODE IMPLEMENTED)
- **Feeling**: Abrupt, final, no comfort
- **Duration**: 200ms fade + 500ms hold

### Zone 5: THE PITCH (Results/Reflection)
- **Screens**: All Results Screens
- **Image**: `stadium_night.png` (falls back gracefully)
- **Feeling**: Game over, back to earth, assessment
- **Overlay**: Light (30% dark)

---

## The Storytelling Arc

```
TUNNEL (entering) → DUGOUT (playing) → RESULTS (reflecting)
   Anticipation    →      Focus      →     Reflection
```

For Survival Mode specifically:
```
TUNNEL → DUGOUT → VOID (death) → RESULTS
```

The **VOID** is the critical emotional beat - pure black, no comfort, decisive.

---

## Deliverables Checklist

### Sean Delivers:
- [ ] `tunnel.png` - Entry/anticipation zone
- [ ] `dugout.png` - Active gameplay zone
- [ ] `pitch_empty.png` (optional) - Results zone
- [ ] `tunnel.mp4` (bonus) - Animated splash

### Claude Delivers (COMPLETE):
- [x] Updated `PitchBackground` with zone system
- [x] All screens wired to correct zones
- [x] Survival Mode death "void" transition
- [x] Video splash infrastructure (ready for Luma video)

### End Result:
Every user session tells a visual story:
**Enter → Play → Resolve → Return**

---

## Key Principles (Don't Forget)

1. **Animate moments, not screens**
2. **Signal game state, don't decorate**
3. **Survival death = hard visual break (VOID)**
4. **Consistency within zones, variety between zones**
5. **Mode differentiation through color/UI intensity, not different backgrounds**

---

## Document Info
- Created: 30th December 2024
- Updated: 31st December 2024
- Status: Code complete, awaiting assets
- Related docs: `VISUAL_STRATEGY.md`
