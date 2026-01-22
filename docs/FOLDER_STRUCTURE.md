# Football IQ - Organized Folder Structure

## Quick Navigation

All documentation and scripts have been organized into clean folders.

### Documentation (docs/)
- **progress/** - Daily progress tracking
  - PROGRESS_2026-01-21.md
- **Development guides**
  - DEVELOPMENT_APPROACH_ANALYSIS.md - Industry comparison analysis
  - HOW_TO_ITERATE.md - Hot reload workflow guide
  - DEPLOYMENT_GUIDE.md
  - INSTALL_INSTRUCTIONS.md
  - SETUP.md
- **UI Documentation**
  - UI_ACTION_PLAN.md
  - UI_CHANGES_SUMMARY.md
  - UI_IMPLEMENTATION_PLAN.md
  - UI_IMPROVEMENT_ROADMAP.md
  - VISUAL_STRATEGY.md
- **Project Info**
  - FOOTBALL_IQ.md - Project overview
  - PHASE_STATUS.md
  - DISTRIBUTION_GUIDE.md
  - DOCUMENTATION_AUDIT.md

### Scripts (scripts/)

#### scripts/deploy/
Quick deployment and testing scripts:
- **RUN_ON_PHONE.bat** - Main hot reload script (Use this!)
- START_HERE.bat - Quick start script
- QUICK_DEPLOY.bat - Fast deployment
- DEPLOY.bat - Full deployment
- HOTPUSH.bat - Hot push changes
- install-to-phone.bat - Install APK

#### scripts/build/
Build-related scripts:
- build-apk.bat - Build APK
- CLEAN_BUILD.bat - Clean and rebuild

#### scripts/setup/
Environment setup scripts:
- DEV_MODE.bat - Toggle dev mode
- STATUS.bat - Check system status
- fix-git-path.ps1 - Fix Git PATH issues

## How to Use

### Daily Development Workflow:
1. Navigate to project root
2. Run `scripts\deploy\RUN_ON_PHONE.bat`
3. Edit code → Press `r` → See changes in 2-5 seconds!

### Read Documentation:
- Start with `docs\HOW_TO_ITERATE.md` for workflow
- Check `docs\progress\PROGRESS_2026-01-21.md` for latest updates
- See `docs\DEVELOPMENT_APPROACH_ANALYSIS.md` for industry validation

## Root Directory (Clean!)

Now only contains essential Flutter project files:
- lib/ - Source code
- android/, ios/, etc. - Platform folders
- pubspec.yaml - Dependencies
- analysis_options.yaml - Linting rules
- assets/ - Images, fonts, etc.

All documentation and scripts are now organized in docs/ and scripts/ folders!
