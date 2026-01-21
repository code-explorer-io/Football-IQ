# Documentation Audit & Cleanup Plan
> Session: 21 Jan 2026

---

## Current Documentation (18 .md files, 4,301 total lines)

### ✅ KEEP - Core Documentation (6 files)

| File | Lines | Purpose | Action |
|------|-------|---------|--------|
| **docs/FOOTBALL_IQ.md** | 488 | Master project document | ✅ Keep - Primary reference |
| **VISUAL_STRATEGY.md** | 218 | UI/UX design strategy | ✅ Keep - Active work |
| **docs/DISTRIBUTION_GUIDE.md** | 237 | App Store submission guide | ✅ Keep - Pre-launch critical |
| **docs/PHASE_STATUS.md** | 118 | Current project status | ✅ Keep - Track progress |
| **docs/CLAUDE_CONTEXT.md** | 174 | AI session context | ✅ Keep - Onboarding tool |
| **ai_autonomous_app_progression_playbook.md** | 368 | AI workflow guide | ✅ Keep - Productivity tool |

**Subtotal: 1,603 lines**

---

### 🔄 CONSOLIDATE - Setup/Dev Docs (4 files → 1 file)

| File | Lines | Content | Action |
|------|-------|---------|--------|
| DEV_SETUP.md | 537 | Flutter/Git setup from Dec 30 | Merge into SETUP.md |
| GIT_PATH_TROUBLESHOOTING.md | 154 | Claude Code Git Bash issues | Merge into SETUP.md |
| SETUP_SESSION_21_JAN_2026.md | 296 | Today's session notes | Merge into SETUP.md |
| docs/SETUP_JOURNEY.md | 300 | Historical setup notes | Merge into SETUP.md |

**Current: 1,287 lines across 4 files**
**Target: ~600 lines in 1 consolidated SETUP.md**

#### Proposed Structure: `SETUP.md`
```markdown
# Development Environment Setup

## Quick Start (Essential)
- Flutter installation
- Android Studio setup
- Git configuration
- Common troubleshooting

## Historical Issues (Archive)
- Git fork bomb (21 Jan 2026)
- Claude Code PATH issues (1 Jan 2025)
- Session logs (collapsed sections)
```

---

### 🗑️ DELETE - Obsolete/Redundant (4 files)

| File | Lines | Why Delete |
|------|-------|------------|
| PLAN_31_DECEMBER.md | 164 | Superseded by VISUAL_STRATEGY.md |
| docs/AUDIT_REPORT.md | 322 | One-time audit, now outdated |
| docs/AUDIT_ITERATION_LOOPS.md | 417 | Development notes, no longer relevant |
| docs/VIBECODER_GUIDE.md | 373 | Tool-specific, unused workflow |

**Lines to delete: 1,276**

---

### 📦 ARCHIVE - Auto-generated/Minimal (4 files)

| File | Lines | Purpose | Action |
|------|-------|---------|--------|
| assets/sounds/README.md | 26 | Sound credits | Keep, low overhead |
| build/.../README.md | 26 | Build artifact (duplicate) | Ignore (auto-generated) |
| ios/.../README.md | 4 | iOS launch image note | Keep (Apple requirement) |
| docs/COMMUNICATION.md | 79 | Empty/minimal | Delete or consolidate |

---

## Cleanup Actions

### Phase 1: Delete Obsolete Files
```bash
rm PLAN_31_DECEMBER.md
rm docs/AUDIT_REPORT.md
rm docs/AUDIT_ITERATION_LOOPS.md
rm docs/VIBECODER_GUIDE.md
rm docs/COMMUNICATION.md  # If empty/redundant
```

### Phase 2: Consolidate Setup Docs
1. Create new `SETUP.md` with consolidated content
2. Delete old setup files:
   ```bash
   rm DEV_SETUP.md
   rm GIT_PATH_TROUBLESHOOTING.md
   rm SETUP_SESSION_21_JAN_2026.md
   rm docs/SETUP_JOURNEY.md
   ```

### Phase 3: Update References
- Update `docs/CLAUDE_CONTEXT.md` to point to new SETUP.md
- Add note in README.md about documentation structure

---

## Final Documentation Structure

```
Football-IQ/
├── SETUP.md                          # All dev environment setup (NEW)
├── VISUAL_STRATEGY.md                # UI/UX design guide
├── ai_autonomous_app_progression_playbook.md
├── docs/
│   ├── FOOTBALL_IQ.md                # Master project doc
│   ├── PHASE_STATUS.md               # Current status
│   ├── CLAUDE_CONTEXT.md             # AI onboarding
│   └── DISTRIBUTION_GUIDE.md         # App Store process
└── assets/sounds/README.md           # Sound credits
```

**Before: 18 files, 4,301 lines**
**After: 11 files, 2,686 lines** (38% reduction)

✅ **COMPLETED: 21 Jan 2026**

---

## Benefits

✅ **Clarity**: One setup guide instead of four
✅ **Freshness**: Remove outdated audit/planning docs
✅ **Discoverability**: Clear doc hierarchy
✅ **Maintenance**: Fewer files to keep updated

---

*Ready to execute? Let me know and I'll run the cleanup.*
