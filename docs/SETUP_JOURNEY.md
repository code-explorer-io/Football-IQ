# Football IQ: Setup Journey & Lessons Learned

> A complete record of tools installed, problems encountered, and solutions found.
> Useful for future projects and teaching others how to build Flutter apps for the Play Store.

---

## Environment Summary

| Tool | Version | Purpose |
|------|---------|---------|
| Flutter | 3.10.x | Cross-platform app framework |
| Dart | (bundled with Flutter) | Programming language |
| Android Studio | Latest | Android SDK, emulator, build tools |
| Java/OpenJDK | 17.0.17 | Required for Android builds |
| Node.js | 24.11.0 | Required for Firebase CLI |
| npm | 11.6.1 | Package manager for Node tools |
| Firebase CLI | 15.1.0 | Firebase project management |
| FlutterFire CLI | 1.3.1 | Firebase + Flutter integration |
| Git | Latest | Version control |

---

## What We Installed & Why

### 1. Flutter SDK
**Why:** The core framework for building the app. Write once, deploy to Android + iOS.

**Location:** `C:\Flutter\flutter`

**Install:** Download from flutter.dev, extract, add to PATH.

---

### 2. Android Studio
**Why:** Provides Android SDK, emulator, and build tools. Even if you code in VS Code, you need this.

**What it includes:**
- Android SDK
- Android Emulator
- Gradle build system
- Platform tools (adb, etc.)

---

### 3. Java/OpenJDK 17
**Why:** Android build system (Gradle) requires Java. Version 17 is currently recommended.

**Location:** `C:\Program Files\Eclipse Adoptium\jdk-17.0.17.10-hotspot`

---

### 4. Node.js + npm
**Why:** Firebase CLI is a Node.js tool. npm installs it globally.

**Install:** Download from nodejs.org (LTS version recommended).

---

### 5. Firebase CLI
**Why:** Manages Firebase projects from command line. Required by FlutterFire CLI.

**Install:** `npm install -g firebase-tools`

**Login:** `firebase login` (opens browser for Google auth)

---

### 6. FlutterFire CLI
**Why:** Auto-configures Firebase for Flutter projects. Generates config files for all platforms.

**Install:** `dart pub global activate flutterfire_cli`

**Usage:** `flutterfire configure` (in project directory)

---

### 7. Git
**Why:** Version control. Also required by Flutter itself for some operations.

**Critical:** Must be properly installed with PATH configured.

---

## Problems Encountered & Solutions

### Problem 1: "Unable to find git in your PATH"

**Symptom:** Flutter commands fail with git errors.

**Root Cause:** Git installed but `git.exe` not in system PATH, or Flutter's PowerShell scripts can't find it.

**Solution that DIDN'T work:**
- Reinstalling Git multiple times
- Manually adding Git to PATH

**Solution that WORKED (Permanent):**
```powershell
[System.Environment]::SetEnvironmentVariable("FLUTTER_PREBUILT_ENGINE_VERSION", "1527ae0ec577a4ef50e65f6fefcfc1326707d9bf", "User")
```

**Why it works:** This environment variable tells Flutter to skip the git-based engine version lookup and use the cached version directly. Setting it at "User" level makes it permanent across all terminals.

**Note:** When you update Flutter to a new version, you may need to update this value. Get the new version from `C:\Flutter\flutter\bin\internal\engine.version`.

**Lesson:** Before reinstalling anything, look for workarounds. Read the error messages carefully - they often point to specific scripts that can be bypassed.

---

### Problem 2: "BUG (fork bomb)" Error

**Symptom:** Terminal shows "BUG (fork bomb): C:\Program Files\Git\bin\git.exe" and crashes.

**Root Cause:** Flutter's `update_engine_version.ps1` PowerShell script has a conflict with certain Git PATH configurations on Windows.

**Solution:** Same as Problem 1 - use the `FLUTTER_PREBUILT_ENGINE_VERSION` environment variable.

---

### Problem 3: PowerShell Script Execution Disabled

**Symptom:** `npm : File cannot be loaded because running scripts is disabled`

**Solution:**
```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

---

### Problem 4: "Developer Mode" Required for Symlinks

**Symptom:** Flutter warns about symlink support after `pub get`.

**Solution:**
1. Run `start ms-settings:developers` in PowerShell
2. Turn ON "Developer Mode" in Windows Settings

---

### Problem 5: Windows Defender SmartScreen Warning

**Symptom:** "Windows protected your PC" when running Firebase CLI installer.

**Why it happens:** Downloaded executables without Microsoft code signing trigger this warning.

**Solution:** Click "More info" → "Run anyway" (if from trusted source like Google/Firebase).

---

## Troubleshooting Framework

When something breaks, follow this order:

1. **Read the error message carefully** - What file/script is failing? What line number?

2. **Try non-destructive fixes first:**
   - Environment variables
   - Config file changes
   - Running from different terminal (PowerShell vs CMD vs Git Bash)

3. **Search for the specific error** - Include the exact error text.

4. **Check if it's a known issue** - Flutter GitHub issues, Stack Overflow.

5. **Reinstall only as last resort** - And if you do, uninstall completely first.

---

## Project Configuration Files

### Firebase Config Files (auto-generated by FlutterFire CLI)

| File | Location | Purpose |
|------|----------|---------|
| `google-services.json` | `android/app/` | Android Firebase config |
| `GoogleService-Info.plist` | `ios/Runner/` | iOS Firebase config |
| `firebase_options.dart` | `lib/` | Dart config for all platforms |

### Key Project Files

| File | Purpose |
|------|---------|
| `pubspec.yaml` | Flutter dependencies |
| `android/app/build.gradle.kts` | Android build config |
| `android/build.gradle.kts` | Root Android config |
| `lib/main.dart` | App entry point |

---

## Flutter Packages Used

| Package | Version | Purpose |
|---------|---------|---------|
| `shared_preferences` | ^2.2.2 | Local storage for scores/settings |
| `google_fonts` | ^6.1.0 | Custom typography |
| `confetti` | ^0.7.0 | Celebration animations |
| `firebase_core` | ^3.9.0 | Firebase initialization |
| `firebase_analytics` | ^11.4.2 | User analytics |
| `flutter_launcher_icons` | ^0.14.3 | App icon generation |

---

## Accounts Required

| Service | Cost | Purpose |
|---------|------|---------|
| Google Play Developer | $25 (one-time) | Publish to Android |
| Apple Developer | $99/year | Publish to iOS |
| Firebase | Free | Analytics, crash reporting |
| GitHub | Free | Code repository |

---

## Useful Commands Reference

```bash
# Flutter basics
flutter pub get              # Install dependencies
flutter run                  # Run app on device/emulator
flutter build appbundle      # Build Android release
flutter clean                # Clear build cache

# Firebase
firebase login               # Authenticate with Google
flutterfire configure        # Setup Firebase for project

# Git (when working)
git status                   # Check changes
git add .                    # Stage all changes
git commit -m "message"      # Commit
git push                     # Push to remote

# Workaround for Flutter git issues on Windows
$env:FLUTTER_PREBUILT_ENGINE_VERSION = "1527ae0ec577a4ef50e65f6fefcfc1326707d9bf"
```

---

## What's Still Needed

| Item | Status | Notes |
|------|--------|-------|
| Firebase Analytics code | In progress | Service created, need to add event tracking |
| RevenueCat | Not started | For in-app purchases |
| Apple Developer account | Waiting | Payment pending |
| Codemagic | Not started | iOS cloud builds |

---

*Last updated: 2024-12-30*
