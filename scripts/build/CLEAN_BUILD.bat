@echo off
REM ============================================
REM Football IQ - Clean Build
REM ============================================
REM Use this when you need a completely fresh build.
REM This clears all cached files and rebuilds from scratch.
REM ============================================

echo.
echo ==========================================
echo   Football IQ - Clean Build
echo ==========================================
echo.

cd /d "%~dp0"

REM Check phone connection
echo [1/4] Checking phone connection...
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

REM Clean build cache
echo [2/4] Cleaning build cache...
C:\Flutter\flutter\bin\flutter.bat clean
echo       Clean complete: OK
echo.

REM Get dependencies
echo [3/4] Getting dependencies...
C:\Flutter\flutter\bin\flutter.bat pub get
echo       Dependencies updated: OK
echo.

REM Build APK
echo [4/4] Building APK (this will take longer than usual)...
C:\Flutter\flutter\bin\flutter.bat build apk --debug

if errorlevel 1 (
    echo.
    echo ERROR: Build failed!
    echo.
    pause
    exit /b 1
)
echo       Build complete: OK
echo.

REM Install to phone
echo Installing to phone...
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
echo   SUCCESS! Clean build deployed
echo ==========================================
echo.
pause
