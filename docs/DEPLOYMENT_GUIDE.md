# Football IQ - Deployment Guide

## Quick Reference

Your Flutter development workflow is now **FULLY OPERATIONAL**. Choose the method that fits your needs:

---

## Method 1: Dev Mode (Hot Reload) - FASTEST for Active Development

**Use this when making frequent changes and testing.**

### Command:
```
DEV_MODE.bat
```

### What it does:
1. Launches app on phone with hot reload enabled
2. Press `r` to instantly reload changes (takes 1-2 seconds)
3. Press `R` to hot restart app
4. Press `q` to quit

### Perfect for:
- UI tweaks
- Logic changes
- Rapid iteration
- Testing multiple variations quickly

**Note:** Hot reload works for most Dart code changes. If you change assets, pubspec.yaml, or native code, you'll need a full rebuild.

---

## Method 2: Quick Deploy - Full Build & Install

**Use this for clean builds or when hot reload doesn't work.**

### Command:
```
QUICK_DEPLOY.bat
```

### What it does:
1. Checks phone connection
2. Builds debug APK (20-40 seconds)
3. Installs to phone automatically

### Perfect for:
- First deployment of the day
- After changing assets or dependencies
- When hot reload acts weird
- Sharing builds with testers

---

## Method 3: VS Code (Press F5) - IDE Integration

**Use this if you prefer working in VS Code.**

### Command:
1. Open project in VS Code
2. Press `F5` or click "Run and Debug"
3. Select "Flutter: Run on Phone"

### What it does:
- Builds and runs app with hot reload
- Integrated debugging
- Breakpoints and console output in VS Code

### Perfect for:
- Debugging complex issues
- Using VS Code's Flutter DevTools
- Step-through debugging

---

## Current Configuration

### Phone Details:
- **Device:** Samsung Galaxy S23 (RFCY20CE9DF)
- **OS:** Android 16 (API 36)
- **Connection:** USB debugging enabled

### Flutter Details:
- **Version:** 3.38.5 (Stable)
- **Dart:** 3.10.4
- **Location:** C:\Flutter\flutter

### Recent Changes Deployed:
- ✅ Club selection screen (fixed overflow, adjusted grid)
- ✅ Reduced clubs to 6 for testing
- ✅ Paywall spacing adjustments
- ✅ Dev mode unlock (all content unlocked for testing)

---

## Troubleshooting

### Phone Not Detected
```bash
# Check ADB connection
"C:\Users\Code Explorer\AppData\Local\Android\Sdk\platform-tools\adb.exe" devices
```

If not listed:
1. Unplug and replug USB cable
2. On phone: disable and re-enable USB debugging
3. Tap "Allow" on phone when prompted

### Build Fails
```bash
# Run with verbose output
C:\Flutter\flutter\bin\flutter.bat build apk --debug --verbose
```

Common fixes:
1. Clean build: `flutter clean`
2. Get dependencies: `flutter pub get`
3. Check for syntax errors in Dart files

### Hot Reload Not Working
If hot reload doesn't pick up changes:
1. Press `R` for hot restart (not just `r`)
2. If still broken, exit and use `QUICK_DEPLOY.bat`

---

## Workflow Examples

### Example 1: Morning Start
1. Connect phone via USB
2. Run `DEV_MODE.bat`
3. Make changes in VS Code
4. Press `r` to reload after each change
5. Test on phone immediately

### Example 2: Quick Fix
1. Make change in Dart file
2. Press `r` in Dev Mode terminal
3. Test on phone (1-2 seconds)
4. Repeat

### Example 3: Major Change
1. Make changes to multiple files
2. Run `QUICK_DEPLOY.bat` for clean build
3. Test thoroughly
4. Switch back to `DEV_MODE.bat` for tweaks

---

## Performance

### Dev Mode (Hot Reload):
- Initial launch: ~20-40 seconds
- Each reload: 1-3 seconds
- **Best for:** Active development

### Quick Deploy:
- Full cycle: ~30-50 seconds
- **Best for:** Clean builds

### VS Code F5:
- Same as Dev Mode
- **Best for:** Debugging

---

## Next Steps

Your deployment workflow is optimized. Focus on:

1. **Test the current build** on your phone
2. **Use Dev Mode** for active development
3. **Use Quick Deploy** when you need a clean build
4. **Share APK** with testers from: `build\app\outputs\flutter-apk\app-debug.apk`

---

## Files Reference

- `DEV_MODE.bat` - Hot reload development mode
- `QUICK_DEPLOY.bat` - Full build and install
- `.vscode/launch.json` - VS Code F5 configuration
- `build/app/outputs/flutter-apk/app-debug.apk` - Latest APK

---

**Status:** ✅ All systems operational. Ready for rapid iteration!
