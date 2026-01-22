@echo off
REM ============================================
REM Football IQ - Quick Deploy (One Command)
REM ============================================
REM This is the FAST deployment script.
REM Use this for rapid iteration cycles.
REM ============================================

echo.
echo ==========================================
echo   Football IQ - Quick Deploy
echo ==========================================
echo.

cd /d "%~dp0"

REM Check phone connection
echo [1/3] Checking phone connection...
"C:\Users\Code Explorer\AppData\Local\Android\Sdk\platform-tools\adb.exe" devices | findstr "RFCY20CE9DF" >nul
if errorlevel 1 (
    echo.
    echo ERROR: Phone not connected!
    echo Please connect Samsung Galaxy S23 via USB
    echo.
    pause
    exit /b 1
)
echo       Phone connected: OK
echo.

REM Build APK
echo [2/3] Building APK...
echo       This takes 20-40 seconds...
C:\Flutter\flutter\bin\flutter.bat build apk --debug 2>&1 | findstr /C:"Built build" /C:"ERROR" /C:"FAILURE"

if errorlevel 1 (
    echo.
    echo ERROR: Build failed!
    echo Run with verbose output to see details:
    echo   C:\Flutter\flutter\bin\flutter.bat build apk --debug
    echo.
    pause
    exit /b 1
)
echo       Build complete: OK
echo.

REM Install to phone
echo [3/3] Installing to phone...
"C:\Users\Code Explorer\AppData\Local\Android\Sdk\platform-tools\adb.exe" install -r "build\app\outputs\flutter-apk\app-debug.apk"

if errorlevel 1 (
    echo.
    echo ERROR: Installation failed!
    echo.
    pause
    exit /b 1
)

echo.
echo ==========================================
echo   SUCCESS! App deployed to phone
echo ==========================================
echo.
echo The app is now running with your latest changes.
echo Test it and iterate!
echo.
echo For hot reload during development, use:
echo   flutter run
echo.
pause
