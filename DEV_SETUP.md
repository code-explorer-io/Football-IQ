# Development Setup Notes - Football IQ Flutter App

> **A Beginner's Guide to Building a Flutter App from Zero to Google Play**
>
> This document chronicles our journey building Football IQ, including every issue we encountered and how we resolved them. If you're a beginner building your first Flutter app, this is the guide we wish we had.

---

## 📚 Table of Contents

1. [Current Status](#current-status)
2. [Development Environment Setup](#development-environment-setup)
3. [Git Issue History & Resolution](#git-issue-history--resolution)
4. [GitHub Desktop Troubleshooting](#github-desktop-troubleshooting)
5. [Flutter Commands Reference](#flutter-commands-reference)
6. [App Architecture Overview](#app-architecture-overview)
7. [Feature Implementation Log](#feature-implementation-log)
8. [Common Errors & Solutions](#common-errors--solutions)
9. [Tips for Beginners](#tips-for-beginners)

---

## Current Status (December 30, 2024 - VERIFIED WORKING)

### Git: ✅ FULLY WORKING

| Component | Status | Details |
|-----------|--------|---------|
| Git Installation | ✅ PASS | `C:\Program Files\Git` (fresh install) |
| Git Version | ✅ PASS | 2.52.0.windows.1 |
| `git.exe` (cmd) | ✅ EXISTS | `C:\Program Files\Git\cmd\git.exe` |
| `git.exe` (bin) | ✅ EXISTS | `C:\Program Files\Git\bin\git.exe` |
| `git.exe` (mingw64) | ✅ EXISTS | `C:\Program Files\Git\mingw64\bin\git.exe` |
| System PATH | ✅ PASS | `C:\Program Files\Git\cmd` in System PATH |
| CMD terminal | ✅ PASS | `git --version` works |
| PowerShell | ✅ PASS | `git --version` works |
| Git Bash | ✅ PASS | `git --version` works |
| Remote access | ✅ PASS | Can reach GitHub repositories |

### Flutter: ✅ FULLY WORKING

| Component | Status | Details |
|-----------|--------|---------|
| Flutter Version | ✅ PASS | 3.38.5 (stable channel) |
| Flutter Location | ✅ PASS | `C:\Flutter\flutter\bin` |
| Dart SDK | ✅ PASS | Downloaded and working |
| Windows Version | ✅ PASS | Windows 11 Home 64-bit, 25H2 |
| Chrome | ✅ PASS | Available for web development |
| Network | ✅ PASS | Can reach pub.dev and other resources |

### Android: ⚠️ MINOR ISSUE (Non-blocking)

| Component | Status | Details |
|-----------|--------|---------|
| Android SDK | ✅ PASS | Version 36.1.0 |
| Android SDK Location | ✅ PASS | `C:\Users\seanm\AppData\Local\Android\Sdk` |
| adb.exe | ⚠️ MISSING | Not in platform-tools (fix via SDK Manager) |
| Connected devices | ✅ PASS | 3 devices available |

**To fix adb**: Open Android Studio → SDK Manager → SDK Tools → Check "Android SDK Platform-Tools" → Apply

### Visual Studio: ❌ NOT INSTALLED (Only needed for Windows desktop apps)

Not required for Android/iOS/Web development.

---

## Git Issue History & Resolution

> **IMPORTANT**: We've hit Git issues multiple times. This section documents everything we learned.

### Issue #1: Missing git.exe (December 30, 2024 - Morning)

**Symptoms:**
- `git --version` returns "git is not recognized"
- `flutter doctor` shows Git not found
- VS Code terminal can't run git commands

**Root Cause:**
Corrupted/partial Git installation at `C:\Program Files\Git\` that only contained helper tools (`gitk.exe`, `git-gui.exe`) but not the main `git.exe`.

**How We Diagnosed:**
```cmd
dir "C:\Program Files\Git\cmd"        # Check if git.exe exists
dir "C:\Program Files\Git\bin"        # Check alternative location
where git                              # Shows which git would be used
```

**Solution Applied:**
1. Uninstalled incomplete Git installation via Windows Settings → Apps
2. Fresh install of Git for Windows from https://git-scm.com/download/win
3. During install, selected "Git from the command line and also from 3rd-party software"
4. **CRITICAL**: Restarted VS Code completely (not just terminal - the whole app)
5. Verified with `git --version`

### Issue #2: GitHub Desktop ENOENT Error (December 30, 2024 - Evening)

**Symptoms:**
- GitHub Desktop shows "Can't find Football-IQ"
- Error: `ENOENT: Git failed to execute. This can occur...`
- Repository appears grayed out or missing

**Root Cause:**
GitHub Desktop loses reference to repositories when:
- Git is reinstalled
- PATH environment changes
- Windows updates modify environment

**Key Insight:**
Git command line still works even when GitHub Desktop fails! Don't let the GUI stop you.

**Solution Applied:**
Used command line to commit and push while GitHub Desktop was broken:
```cmd
cd C:\Users\seanm\Projects\Football-IQ
git status
git add .
git commit -m "Your commit message"
git push
```

**To Fix GitHub Desktop Later:**
1. Click "Locate..." button and point to project folder, OR
2. File → Add Local Repository → Browse to project, OR
3. Fresh install: Uninstall, delete `%APPDATA%\GitHub Desktop`, reinstall

### Verification Commands
```cmd
where git
git --version
flutter doctor
```

Expected output:
- `where git` → `C:\Program Files\Git\cmd\git.exe`
- `git --version` → `git version 2.52.0.windows.1`
- `flutter doctor` → `[✓] Flutter (Channel stable, 3.38.5, ...)`

### Prevention Tips
1. After any Git changes, always restart VS Code completely
2. Keep command line skills sharp - GUIs fail, CLI doesn't
3. Commit frequently so you never lose much work
4. If weird Git errors appear, first try: restart VS Code and run `git --version`

---

## Important: Session Refresh After Git Changes

**CRITICAL**: If Git is reinstalled or PATH is modified:
1. **Close VS Code completely** (not just the terminal)
2. **Reopen VS Code**
3. Open a new terminal and verify with `git --version`

Terminals inherit PATH at launch time. They don't automatically pick up environment variable changes.

---

## Development Paths

| Tool | Location |
|------|----------|
| Git | `C:\Program Files\Git\cmd\git.exe` |
| Flutter | `C:\Flutter\flutter\bin\flutter` |
| Dart SDK | `C:\Flutter\flutter\bin\cache\dart-sdk` |
| Android SDK | `C:\Users\seanm\AppData\Local\Android\Sdk` |
| Java (JDK) | `C:\Program Files\Eclipse Adoptium\jdk-17.0.17.10-hotspot` |

---

## Running the App

```cmd
flutter run
```

**Controls while running:**
- `r` - Hot reload
- `R` - Hot restart
- `q` - Quit

---

## Troubleshooting

### "git is not recognized"
1. Verify Git is installed: Check `C:\Program Files\Git\cmd\git.exe` exists
2. Verify PATH: Run `echo %PATH%` and look for `C:\Program Files\Git\cmd`
3. Restart VS Code completely

### "Dart SDK not found"
1. Run `flutter doctor` - it will auto-download the Dart SDK
2. If still failing, run `flutter clean` then `flutter pub get`

### Flutter cache corruption
```cmd
flutter clean
rd /s /q C:\Flutter\flutter\bin\cache
flutter doctor
```
This will re-download all Flutter dependencies.

---

## GitHub Desktop Troubleshooting

### Problem: "Can't find Football-IQ" or ENOENT Error

**Symptoms:**
- GitHub Desktop shows "Can't find [repository name]"
- Error message: `ENOENT: Git failed to execute. This can occur...`
- Repository appears grayed out or missing

**Root Cause:**
GitHub Desktop sometimes loses its reference to local repositories, especially after:
- Moving the project folder
- Git reinstallation
- PATH environment changes
- Windows updates

**Solutions:**

#### Option 1: Relocate the Repository
1. In GitHub Desktop, click "Locate..." button
2. Navigate to your project folder (e.g., `C:\Users\seanm\Projects\Football-IQ`)
3. Select the folder and click "Select Folder"

#### Option 2: Re-add the Repository
1. File → Add Local Repository
2. Browse to your project folder
3. Click "Add repository"

#### Option 3: Use Command Line (Most Reliable)
When GitHub Desktop fails, git command line still works:
```cmd
cd C:\Users\seanm\Projects\Football-IQ
git status
git add .
git commit -m "Your commit message"
git push
```

#### Option 4: Fresh GitHub Desktop Install
1. Uninstall GitHub Desktop
2. Delete `%APPDATA%\GitHub Desktop` folder
3. Reinstall from https://desktop.github.com/

**Important:** Git command line operations always work even when GitHub Desktop has issues. Don't let GUI problems stop your progress!

---

## Flutter Commands Reference

### Daily Development Commands

```cmd
# Check everything is working
flutter doctor

# Get/update dependencies
flutter pub get

# Run the app (will auto-detect devices)
flutter run

# Run on specific device
flutter devices              # List available devices
flutter run -d <device-id>   # Run on specific device

# Analyze code for issues
flutter analyze

# Clean and rebuild (fixes most cache issues)
flutter clean && flutter pub get
```

### Hot Reload vs Hot Restart

| Command | Key | When to Use |
|---------|-----|-------------|
| Hot Reload | `r` | UI changes, small code tweaks |
| Hot Restart | `R` | State changes, new variables, structural changes |
| Full Restart | `q` then `flutter run` | New dependencies, native code changes |

### Build Commands

```cmd
# Build APK for testing
flutter build apk

# Build App Bundle for Play Store
flutter build appbundle

# Build with verbose output (for debugging)
flutter build appbundle --verbose
```

---

## App Architecture Overview

### Folder Structure

```
lib/
├── main.dart                 # App entry point, Firebase init
├── screens/                  # All screen widgets
│   ├── splash_screen.dart    # Lottie animation intro
│   ├── home_screen.dart      # Main menu, mode selection
│   ├── question_screen.dart  # Quiz Your Club gameplay
│   ├── results_screen.dart   # Quiz results display
│   ├── higher_or_lower_screen.dart
│   ├── timed_blitz_screen.dart
│   ├── survival_mode_screen.dart
│   └── cup_mode_screen.dart
├── services/                 # Business logic
│   ├── analytics_service.dart  # Firebase Analytics wrapper
│   ├── sound_service.dart      # Audio playback
│   └── unlock_service.dart     # Mode progression logic
├── theme/
│   └── app_theme.dart        # Colors, text styles
└── widgets/                  # Reusable components
    ├── animated_button.dart
    ├── animated_answer_button.dart
    └── pitch_background.dart
```

### Key Design Patterns

**1. StatefulWidget with Animation**
```dart
class MyScreen extends StatefulWidget {
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen>
    with SingleTickerProviderStateMixin {  // For animations
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();  // Always clean up!
    super.dispose();
  }
}
```

**2. SharedPreferences for Local Storage**
```dart
// Save data
final prefs = await SharedPreferences.getInstance();
await prefs.setInt('best_score', 10);

// Load data
final bestScore = prefs.getInt('best_score') ?? 0;
```

**3. Singleton Services**
```dart
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();
}
```

---

## Feature Implementation Log

### December 30, 2024

**Unlock Progression System**
- Created `UnlockService` to manage mode gating
- Unlock conditions:
  - Quiz Your Club: Always unlocked (starter mode)
  - Higher or Lower: Complete 1 Quiz Your Club game
  - Timed Blitz: Score 70%+ in any mode
  - Survival Mode: Achieve 10+ streak
  - Cup Mode: Complete all other modes

**UI Polish & Animations**
- Shimmer effect on unlock buttons
- Glow animation on unlocked mode cards
- Pulse animation for streak-at-risk warning
- Lottie soccer ball animation on splash screen

**Broadcast Aesthetic Copy Audit**
- "NEW BEST!" → "NEW RECORD" (letter-spaced)
- "Play Again" → "Kick Off Again"
- Emoji verdicts → Material icons (professional look)

### Earlier Features
- Firebase Analytics integration
- RevenueCat in-app purchases
- XP/Level gamification system
- Streak tracking with SharedPreferences

---

## Common Errors & Solutions

### 1. "Dart SDK not found"
**Solution:**
```cmd
flutter doctor      # Auto-downloads SDK
flutter clean
flutter pub get
```

### 2. "pub get failed"
**Possible causes:**
- Network issues → Check internet connection
- Corrupted cache → Run `flutter clean`
- Version conflicts → Check `pubspec.yaml` for compatible versions

### 3. "Could not find a file named 'pubspec.yaml'"
**Solution:** Make sure you're in the project root directory:
```cmd
cd C:\Users\seanm\Projects\Football-IQ
flutter pub get
```

### 4. Build fails with "Gradle error"
**Solution:**
```cmd
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter build appbundle
```

### 5. "No connected devices"
**Solutions:**
1. Start Android emulator from Android Studio
2. Connect physical device with USB debugging enabled
3. Run `flutter devices` to verify detection

### 6. Hot reload not working
**Likely cause:** Structural code changes require hot restart (`R`) or full restart

### 7. "setState() called after dispose()"
**Solution:** Check `mounted` before setState:
```dart
if (mounted) {
  setState(() {
    // your state changes
  });
}
```

---

## Tips for Beginners

### 1. Start Simple, Iterate Often
Don't try to build everything at once. Get a basic version working, then add features one at a time.

### 2. Commit Frequently
Make small, focused commits. If something breaks, you can easily revert.
```cmd
git add .
git commit -m "Add score display to results screen"
```

### 3. Read Error Messages Carefully
Flutter error messages are usually helpful. Look for:
- The file and line number
- The actual error (often at the top)
- Suggested fixes (often at the bottom)

### 4. Use `flutter doctor` Liberally
When in doubt, run `flutter doctor`. It checks your entire setup.

### 5. Hot Reload is Your Friend
Press `r` constantly while developing UI. See changes instantly.

### 6. Don't Fear the Command Line
When GUIs fail (GitHub Desktop, Android Studio), the command line still works. Learn these basics:
- `cd` - change directory
- `git status` - see what's changed
- `flutter run` - run your app

### 7. Keep pubspec.yaml Clean
Only add dependencies you actually need. More packages = more potential conflicts.

### 8. Test on Real Devices
Emulators are convenient, but always test on real devices before publishing. Performance and behavior can differ.

### 9. Back Up Everything
- Use git for code
- Export your keystore file and store it safely (you need it for Play Store updates!)
- Document your API keys securely

### 10. When Stuck, Clean and Rebuild
90% of mysterious issues are fixed by:
```cmd
flutter clean
flutter pub get
flutter run
```

---

## Quick Reference Card

| Task | Command |
|------|---------|
| Check setup | `flutter doctor` |
| Install packages | `flutter pub get` |
| Run app | `flutter run` |
| Hot reload | Press `r` |
| Hot restart | Press `R` |
| Quit | Press `q` |
| Clean project | `flutter clean` |
| Analyze code | `flutter analyze` |
| Build APK | `flutter build apk` |
| Build for Play Store | `flutter build appbundle` |
| Git status | `git status` |
| Git commit | `git add . && git commit -m "message"` |
| Git push | `git push` |

---

*Last updated: December 30, 2024*
