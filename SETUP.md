# Development Environment Setup - Football IQ

> Complete guide for setting up Flutter development on Windows for the Football IQ project.
>
> **Last Updated**: 21 January 2026
> **Status**: ✅ Fully Working

---

## Quick Start

### Prerequisites Checklist

- [ ] Windows 11 (or Windows 10)
- [ ] Admin access to install software
- [ ] ~10GB free disk space
- [ ] Internet connection

### Install Order

1. **Git for Windows** → 2. **Java JDK** → 3. **Android Studio** → 4. **Flutter**

---

## Current Working Configuration (21 Jan 2026)

### ✅ What's Installed

| Component | Version | Location |
|-----------|---------|----------|
| **Git** | 2.52.0.windows.1 | `C:\Program Files\Git` |
| **Java JDK** | 17.0.17 | Eclipse Adoptium Temurin |
| **Android Studio** | Latest (2025.x) | `C:\Program Files\Android\Android Studio` |
| **Android SDK** | API 36 | `C:\Users\Code Explorer\AppData\Local\Android\Sdk` |
| **Flutter** | 3.38.5 (stable) | `C:\Flutter\flutter` |

### Android SDK Components

```
✅ Android SDK Platform 36 (revision 2)
✅ Android SDK Build-Tools 36.1.0
✅ Android SDK Platform-Tools 36.0.2
✅ Android Emulator 36.3.10
✅ Google Play x86_64 System Image (API 36.1)
✅ Android Emulator Hypervisor Driver
✅ Sources for Android 36
✅ Virtual Device: Medium_Phone_API_36.1
✅ SDK Licenses: Accepted
```

### Environment Variables

```powershell
# User Environment Variables
ANDROID_HOME = C:\Users\Code Explorer\AppData\Local\Android\Sdk

# User PATH additions:
C:\Flutter\flutter\bin
C:\Users\Code Explorer\AppData\Local\Android\Sdk\platform-tools
C:\Program Files\Git\cmd
```

---

## Step-by-Step Installation

### 1. Install Git for Windows

**Download**: https://git-scm.com/download/win

**Installation Steps**:
1. Run installer **as Administrator** (right-click → Run as administrator)
2. Important selections during install:
   - ✅ "Git from the command line and also from 3rd-party software"
   - ✅ Use Windows' default console window
   - ✅ Default settings for everything else

**Verify**:
```bash
git --version
# Should output: git version 2.52.0.windows.1 (or newer)
```

**Configure** (required for commits):
```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

---

### 2. Install Java JDK 17

**Download**: Eclipse Adoptium - https://adoptium.net/

**Install**:
1. Download JDK 17 (LTS)
2. Run installer with default settings
3. Installer automatically sets `JAVA_HOME` and PATH

**Verify**:
```bash
java -version
# Should output: openjdk version "17.0.17"
```

---

### 3. Install Android Studio

**Download**: https://developer.android.com/studio

**Installation**:
1. Run installer **as Administrator**
2. Install to default location: `C:\Program Files\Android\Android Studio`
3. On first launch, Android Studio will:
   - Download Android SDK automatically
   - Install SDK components
   - Create a virtual device

**During Setup Wizard**:
- ✅ Standard installation
- ✅ Download all recommended components
- ⚠️ **If downloads fail with network errors**:
  - Check Windows Firewall
  - Allow Android Studio through firewall
  - Retry download

**SDK Installation Path**:
```
C:\Users\<YourUsername>\AppData\Local\Android\Sdk
```

**Set Environment Variable**:
```powershell
# Run in PowerShell
[Environment]::SetEnvironmentVariable('ANDROID_HOME', 'C:\Users\Code Explorer\AppData\Local\Android\Sdk', 'User')
```

---

### 4. Install Flutter

**Download**: https://flutter.dev/docs/get-started/install/windows

**Installation Steps**:
1. Download Flutter SDK ZIP
2. Extract to `C:\Flutter\flutter` (create folder if needed)
3. Add Flutter to PATH:

```powershell
# Run in PowerShell
[Environment]::SetEnvironmentVariable('Path', [Environment]::GetEnvironmentVariable('Path', 'User') + ';C:\Flutter\flutter\bin', 'User')
```

4. **Restart VS Code** (or any open terminals)

5. Run Flutter doctor:
```bash
flutter doctor -v
```

**Expected Output**:
```
[√] Flutter (Channel stable, 3.38.5)
[√] Windows Version
[√] Android toolchain
[√] Chrome
[√] Connected device
[√] Network resources
```

**Configure Flutter for Android SDK**:
```bash
flutter config --android-sdk "C:\Users\Code Explorer\AppData\Local\Android\Sdk"
```

**Add Flutter safe directory for Git**:
```bash
git config --global --add safe.directory C:/Flutter/flutter
```

---

## Running the Football-IQ App

### Get Dependencies
```bash
cd C:\Users\Code Explorer\Documents\GitHub\Football-IQ
flutter pub get
```

### Run on Web (Fastest for Testing)
```bash
flutter run -d chrome
```

### Run on Android Emulator
```bash
# List available devices
flutter devices

# Start emulator (if not running)
# Open Android Studio → Device Manager → Start emulator

# Run app
flutter run
```

### Run on Physical Device
1. Enable Developer Options on Android phone
2. Enable USB Debugging
3. Connect via USB
4. Run `flutter devices` to verify
5. Run `flutter run`

---

## Common Issues & Solutions

### Issue: "git is not recognized"

**Symptoms**:
- `git --version` fails
- Flutter can't run (`flutter doctor` fails)

**Solutions**:
1. Verify Git is installed: Check `C:\Program Files\Git\cmd\git.exe` exists
2. Verify PATH: Run `echo %PATH%` and look for `C:\Program Files\Git\cmd`
3. **Restart VS Code completely** (not just terminal)
4. If still failing: Reinstall Git **as Administrator**

---

### Issue: Git Fork Bomb Error

**Symptoms**:
```
BUG (fork bomb): C:\Program Files\Git\bin\git.exe
```

**Root Cause**: Multiple Git installations or PATH conflicts

**Solution**:
1. Uninstall all Git installations (Settings → Apps)
2. Check for and remove GitHub Desktop's bundled Git from PATH
3. Fresh install Git from https://git-scm.com/download/win **as Administrator**
4. Restart VS Code
5. Re-run: `git config --global --add safe.directory C:/Flutter/flutter`

**Verified Fix**: 21 Jan 2026 - This resolved the fork bomb completely

---

### Issue: Android SDK Not Found

**Symptoms**:
- `flutter doctor` shows "Android SDK not found"
- `[X] Android toolchain`

**Solution**:
1. Verify SDK exists: `C:\Users\<Username>\AppData\Local\Android\Sdk`
2. Set `ANDROID_HOME` environment variable (see Step 3 above)
3. Tell Flutter where SDK is:
   ```bash
   flutter config --android-sdk "C:\Users\Code Explorer\AppData\Local\Android\Sdk"
   ```
4. Restart terminal

---

### Issue: cmdline-tools Missing

**Symptoms**:
- `flutter doctor` shows "cmdline-tools component is missing"

**Solution**:
1. Open Android Studio
2. Tools → SDK Manager
3. SDK Tools tab
4. Check "Android SDK Command-line Tools (latest)"
5. Click Apply

**Note**: This warning is non-critical - you can still build apps without it.

---

### Issue: Flutter Cache Corruption

**Symptoms**:
- `flutter` commands fail
- `Dart SDK not found` errors

**Solution**:
```bash
flutter clean
rm -rf C:\Flutter\flutter\bin\cache
flutter doctor
```

This forces Flutter to re-download the Dart SDK and rebuild its cache.

---

### Issue: Android Studio Download Timeout

**Symptoms**:
```
java.net.SocketTimeoutException: Read timed out
java.net.UnknownHostException: dl.google.com
```

**Solutions**:
1. **Firewall**: Allow Android Studio through Windows Firewall
   - Settings → Windows Defender Firewall
   - Allow an app → Add `studio64.exe`

2. **Retry**: The download often succeeds on retry

3. **Network**: Check internet connection, try different network

---

## Flutter Commands Reference

### Daily Development

```bash
# Check everything is working
flutter doctor

# Get/update dependencies
flutter pub get

# Run the app (auto-detects devices)
flutter run

# Run on specific device
flutter devices              # List available devices
flutter run -d <device-id>   # Run on specific device

# Hot reload (while app is running)
# Press 'r' in terminal

# Hot restart (while app is running)
# Press 'R' in terminal

# Analyze code for issues
flutter analyze

# Clean and rebuild (fixes most cache issues)
flutter clean && flutter pub get
```

### Building for Release

```bash
# Build APK for testing
flutter build apk

# Build App Bundle for Play Store
flutter build appbundle

# Build with verbose output (for debugging)
flutter build appbundle --verbose
```

### Hot Reload vs Hot Restart

| Command | Key | When to Use |
|---------|-----|-------------|
| Hot Reload | `r` | UI changes, small code tweaks |
| Hot Restart | `R` | State changes, new variables |
| Full Restart | `q` then `flutter run` | New dependencies, native code |

---

## Verification Commands

Run these to confirm everything is set up correctly:

```bash
# Git
git --version
where git

# Java
java -version

# Flutter
flutter --version
flutter doctor -v

# Android SDK
adb --version

# In project directory
cd C:\Users\Code Explorer\Documents\GitHub\Football-IQ
git status
flutter pub get
flutter analyze
```

**All should run without errors.**

---

## Troubleshooting Tips

### General Debugging Strategy

1. **Read error messages carefully** - Flutter errors are usually helpful
2. **Check the file and line number** in errors
3. **Run `flutter clean`** - solves 50% of mysterious issues
4. **Restart VS Code** - especially after PATH changes
5. **Check `flutter doctor`** - identifies most setup issues

### When Stuck

1. Run `flutter clean && flutter pub get`
2. Restart VS Code completely
3. Check GitHub issues for the error message
4. Verify all PATH variables are set correctly

### Performance

- **Use web for quick testing** (`flutter run -d chrome`)
- **Hot reload is instant** - use `r` constantly during UI work
- **Only use hot restart (`R`)** when hot reload doesn't work

---

## Project-Specific Notes

### Football-IQ Structure

```
Football-IQ/
├── lib/
│   ├── main.dart              # App entry point
│   ├── screens/               # 13 screen files
│   ├── services/              # Business logic
│   ├── models/                # Data models
│   ├── widgets/               # Reusable components
│   └── theme/                 # AppTheme, colors, typography
├── assets/
│   ├── data/                  # JSON question data
│   ├── images/                # Backgrounds, icons
│   └── sounds/                # Audio files
└── android/                   # Android native code
```

### Key Dependencies

```yaml
# From pubspec.yaml
- flutter: SDK
- firebase_core: 3.15.0
- firebase_analytics: 11.6.0
- purchases_flutter: 9.10.2    # RevenueCat
- shared_preferences: 2.2.2
- google_fonts: 6.1.0
- audioplayers: 6.1.0
- lottie: 3.3.1
```

---

## Historical Issues (Archive)

### Git PATH Issues (Jan 1, 2025)
- **Issue**: Claude Code couldn't find Git Bash
- **Solution**: Set `CLAUDE_CODE_GIT_BASH_PATH` environment variable
- **Details**: See GIT_PATH_TROUBLESHOOTING.md (archived)

### Git Fork Bomb (Jan 21, 2026)
- **Issue**: Git commands failed with fork bomb error
- **Root Cause**: Multiple Git installations conflicting
- **Solution**: Clean reinstall of Git as Administrator
- **Status**: ✅ Resolved permanently

### Android SDK Download Failures (Jan 21, 2026)
- **Issue**: Network timeouts during SDK component download
- **Solution**: Firewall exception + retry
- **Status**: ✅ Completed successfully

---

## Resources

- **Flutter Docs**: https://docs.flutter.dev
- **Git Download**: https://git-scm.com/download/win
- **Android Studio**: https://developer.android.com/studio
- **RevenueCat Docs**: https://www.revenuecat.com/docs
- **Firebase Console**: https://console.firebase.google.com

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

*This document consolidates setup knowledge from multiple sessions. For UI/UX strategy, see [VISUAL_STRATEGY.md](VISUAL_STRATEGY.md). For project overview, see [docs/FOOTBALL_IQ.md](docs/FOOTBALL_IQ.md).*
