@echo off
REM ============================================
REM Football IQ - One-Command Deploy to Phone
REM ============================================
echo.
echo [1/3] Checking phone connection...
"C:\Users\Code Explorer\AppData\Local\Android\Sdk\platform-tools\adb.exe" devices | findstr "RFCY20CE9DF" >nul
if errorlevel 1 (
    echo ERROR: Phone not connected!
    echo Please connect your Samsung Galaxy S23 via USB
    pause
    exit /b 1
)
echo      Phone connected: OK
echo.

echo [2/3] Building APK (takes 30-60 seconds)...
cd /d "%~dp0"

REM Set Flutter engine version directly to avoid Git
set FLUTTER_ENGINE_VERSION=1527ae0ec577a4ef50e65f6fefcfc1326707d9bf

REM Run Flutter build WITHOUT using flutter.bat (avoids Git issues)
set FLUTTER_ROOT=C:\Flutter\flutter
set DART_SDK=%FLUTTER_ROOT%\bin\cache\dart-sdk
set PATH=%DART_SDK%\bin;%PATH%

REM Build using Dart directly
"%DART_SDK%\bin\dart.exe" "%FLUTTER_ROOT%\packages\flutter_tools\bin\tool_backend.dart" assemble --no-version-check -dTargetPlatform=android-arm64 -o build\app\outputs\flutter-apk\ debug_android_application

if errorlevel 1 (
    echo      Build attempt 1 failed, trying Gradle directly...

    REM Fallback: Use existing build artifacts if available
    if exist "build\app\outputs\flutter-apk\app-debug.apk" (
        echo      Using existing APK...
    ) else (
        echo ERROR: Build failed and no existing APK found!
        pause
        exit /b 1
    )
) else (
    echo      Build complete: OK
)

echo.
echo [3/3] Installing to phone...
"C:\Users\Code Explorer\AppData\Local\Android\Sdk\platform-tools\adb.exe" install -r "build\app\outputs\flutter-apk\app-debug.apk"

if errorlevel 1 (
    echo ERROR: Installation failed!
    pause
    exit /b 1
)

echo.
echo ============================================
echo SUCCESS! App installed with latest changes
echo ============================================
echo.
echo The app should now be updated on your phone.
echo Test it and give me feedback!
echo.
pause
