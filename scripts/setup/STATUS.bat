@echo off
REM ============================================
REM Football IQ - System Status Check
REM ============================================

echo.
echo ==========================================
echo   Football IQ - System Status
echo ==========================================
echo.

cd /d "%~dp0"

REM Check Flutter
echo [1/4] Flutter Installation:
C:\Flutter\flutter\bin\flutter.bat --version 2>&1 | findstr "Flutter version"
if errorlevel 1 (
    echo       ERROR: Flutter not working
) else (
    echo       Status: OK
)
echo.

REM Check Phone Connection
echo [2/4] Phone Connection:
"C:\Users\Code Explorer\AppData\Local\Android\Sdk\platform-tools\adb.exe" devices | findstr "RFCY20CE9DF" >nul
if errorlevel 1 (
    echo       Device: NOT CONNECTED
    echo       Action: Connect phone via USB
) else (
    echo       Device: CONNECTED (RFCY20CE9DF)
    echo       Status: OK
)
echo.

REM Check APK
echo [3/4] Latest Build:
if exist "build\app\outputs\flutter-apk\app-debug.apk" (
    for %%F in ("build\app\outputs\flutter-apk\app-debug.apk") do (
        echo       APK exists: YES
        echo       Size: %%~zF bytes
        echo       Modified: %%~tF
        echo       Status: OK
    )
) else (
    echo       APK exists: NO
    echo       Action: Run QUICK_DEPLOY.bat to build
)
echo.

REM Check VS Code Config
echo [4/4] VS Code Configuration:
if exist ".vscode\launch.json" (
    echo       Config exists: YES
    echo       Press F5 in VS Code to run
    echo       Status: OK
) else (
    echo       Config exists: NO
    echo       Action: File should exist, may need to recreate
)
echo.

echo ==========================================
echo   Status Check Complete
echo ==========================================
echo.
echo Ready to deploy? Run START_HERE.bat
echo.
pause
