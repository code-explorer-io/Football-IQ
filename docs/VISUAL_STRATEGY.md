# Football IQ - Visual & Animation Strategy

> **Guiding Principle**: Visuals and animations reinforce game state, not decorate screens.
> Animate moments, not screens. Signal game state, not decorate.

---

## PHASE 1: GAME STATES MAPPED

### Global States (All Modes)
| State | Screen | Emotion | Animation Tier |
|-------|--------|---------|----------------|
| App Launch | SplashScreen | Anticipation | Tier 2 (800ms fade) |
| Home / Mode Select | HomeScreen | Ready | Tier 1 (subtle pulses) |
| Question Active | Various | Focus | Tier 0 (static) |
| Correct Answer | Various | Satisfaction | Tier 1 (300ms) |
| Wrong Answer | Various | Brief disappointment | Tier 1 (300ms) |
| Game Over | Results screens | Reflection | Tier 3 (800-1500ms) |
| Achievement/Unlock | Results screens | Celebration | Tier 3 (600ms) |

### Mode-Specific Critical Moments

#### Survival Mode (Emotion: TENSION)
| Moment | Intensity | Animation |
|--------|-----------|-----------|
| Question appears | Low | None needed |
| Correct → continue | Medium | Quick green flash |
| Wrong → DEATH | **HIGH** | Immediate cut/fade to black |
| High streak (10+) | Medium | Fire icons build |

#### Timed Blitz (Emotion: URGENCY)
| Moment | Intensity | Animation |
|--------|-----------|-----------|
| Normal time | Low | Steady timer |
| Low time (≤10s) | High | Red pulsing timer |
| Time expired | **HIGH** | Hard stop |
| Fast answers | Medium | Quick transitions |

#### Higher or Lower (Emotion: ANTICIPATION)
| Moment | Intensity | Animation |
|--------|-----------|-----------|
| Before guess | Medium | Hidden value "?" |
| Value reveal | High | Card flip/reveal |
| Correct guess | Medium | Green confirmation |
| Wrong guess | Medium | Red indication |

#### International Cup (Emotion: STAKES)
| Moment | Intensity | Animation |
|--------|-----------|-----------|
| Stage advancement | High | Progress celebration |
| Elimination | **HIGH** | Knockout feeling |
| Cup win | **HIGHEST** | Full celebration |

---

## PHASE 2: ANIMATION INTENSITY TIERS

### Tier 0 - Static (No Animation)
- Reading questions
- Browsing menus
- Waiting for user input

### Tier 1 - Micro Feedback (100-300ms)
- Button press (scale 0.97)
- Answer selected highlight
- Subtle glow/pulse on interactive elements

### Tier 2 - Event Feedback (300-800ms)
- Correct/wrong answer reveal
- Timer color change
- Streak increment display
- Question transitions

### Tier 3 - State Change (800-1500ms)
- Game over (especially Survival death)
- Results screen entrance
- New unlock celebration
- Level up announcement

---

## PHASE 3: BACKGROUND ENVIRONMENTS

### Background Assignment by Screen Type

| Screen Type | Background | Rationale |
|-------------|------------|-----------|
| Home Screen | `stadium_night.png` | Sets atmosphere |
| Mode Intros | `stadium_night.png` | Consistent entry |
| Quiz Questions | `dugout_bench.png` (future) | Focus environment |
| Survival Mode | `tunnel.png` (future) | Tension, darkness |
| Timed Blitz | `scoreboard.png` (future) | Urgency, clock |
| Cup Mode | `trophy_room.png` (future) | Stakes, glory |
| Results Screens | Mode-specific or `stadium_night.png` | Reflection |

### Current Implementation
- `stadium_night.png` - Default for all screens
- `StadiumBackground.classic` - Fallback (no image)

### Future Backgrounds (Priority Order)
1. `dugout_bench.png` - For question screens (like ChatGPT image)
2. `tunnel.png` - Survival mode tension
3. `trophy_room.png` - Cup mode / celebration
4. `scoreboard.png` - Timed modes urgency

---

## PHASE 4: EMOTIONAL CONTRACTS BY MODE

### Survival Mode
- **Emotion**: Tension, high stakes
- **Visuals**: Darker, minimal, focused
- **Death moment**: Immediate, decisive, NO bounce, NO humor
- **Background**: Dark tunnel or minimal

### Club Quiz / Casual
- **Emotion**: Flow, learning
- **Visuals**: Softer, encouraging
- **Wrong answers**: Gentle feedback, continue
- **Background**: Stadium/dugout (warm)

### Timed Blitz
- **Emotion**: Urgency, momentum
- **Visuals**: Timer prominent, escalating intensity
- **Low time**: Red, pulsing, tension build
- **Background**: Scoreboard/clock themed

### International Cup
- **Emotion**: High stakes, glory
- **Visuals**: Tournament bracket, progression
- **Win**: Full celebration
- **Elimination**: Decisive but recoverable
- **Background**: Trophy room

---

## PHASE 5: ASSET ROADMAP

### V1 Assets (Current + Immediate)
- [x] `stadium_night.png` - Default background
- [ ] `dugout_bench.png` - Question screens
- [ ] 1 Survival death animation (screen fade/cut)
- [ ] 1 Results entrance transition

### V2 Assets (Next Phase)
- [ ] `tunnel.png` - Survival mode
- [ ] `trophy_room.png` - Cup mode
- [ ] Confetti improvements
- [ ] Streak fire effect enhancement

### V3 Assets (Polish)
- [ ] `scoreboard.png` - Timed modes
- [ ] Mode-specific particle effects
- [ ] Sound design improvements

---

## PHASE 6: IMPLEMENTATION ORDER

1. **Logic first** - Game states are already implemented
2. **Static backgrounds** - Apply single background per screen type (DONE)
3. **Micro feedback** - Button presses, selections (DONE)
4. **Event animations** - Correct/wrong, timer warnings (PARTIALLY DONE)
5. **State-change animations** - Game over, results, unlocks (NEEDS WORK)

### Priority Fixes
1. Survival mode "death" needs stronger visual moment
2. Results screen transitions need polish
3. Mode unlock celebration needs consistency

---

## PHASE 7: CHATGPT PROMPTS FOR ASSETS

### Dugout Bench (Question Screens)
```
Photorealistic football dugout bench at night, blue leather seats, tactical board visible, water bottles, kit bags, green pitch edge visible, dramatic stadium floodlights in background, cinematic lighting, 4K, vertical mobile orientation (9:16 aspect ratio), moody atmosphere, no people, no text, no logos
```

### Stadium Tunnel (Survival Mode)
```
Photorealistic football stadium tunnel entrance at night, dark corridor looking toward bright green pitch, dramatic light at end of tunnel, wet concrete floor reflecting lights, "This is Football" atmosphere, cinematic tension, 4K, vertical mobile orientation (9:16), no people, no text
```

### Trophy Room (Cup Mode)
```
Photorealistic football trophy cabinet in dark room, golden championship trophies with dramatic spotlight, deep shadows, reflective glass case, medals visible, dark wood paneling, cinematic lighting, 4K, vertical mobile orientation (9:16), no people, no text
```

### Scoreboard (Timed Modes)
```
Photorealistic stadium scoreboard at night, glowing digital clock display, stadium lights creating lens flares in background, dramatic atmosphere, slight rain, urgent mood, 4K, vertical mobile orientation (9:16), no people, minimal text (clock only)
```

---

## QUICK REFERENCE: WHAT TO ANIMATE

### YES - Animate These Moments
- Correct/wrong answer feedback (Tier 1)
- Timer running low warning (Tier 2)
- Survival mode death (Tier 3)
- New high score (Tier 3)
- Mode unlock (Tier 3)
- Level up (Tier 2)

### NO - Don't Animate These
- Every question transition (keep simple)
- Menu browsing
- Text changes
- Background elements (keep static or very subtle)

---

## Document Version
- Created: 2025-12-30
- Last Updated: 2025-12-30
- Status: Active development guide
