# Development Setup Notes

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

### Problem (December 30, 2024)
Previous Git for Windows installation was incomplete - missing `git.exe` executables.

### Root Cause
Corrupted/partial Git installation at `C:\Program Files\Git\` that only contained helper tools (`gitk.exe`, `git-gui.exe`) but not the main `git.exe`.

### Solution Applied
1. Uninstalled incomplete Git installation
2. Fresh install of Git for Windows from https://git-scm.com/download/win
3. Selected "Git from the command line and also from 3rd-party software" during install
4. Restarted VS Code to pick up new PATH

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
