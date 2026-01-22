@echo off
REM ============================================
REM Football IQ - Hot Push (Install Without Full Rebuild)
REM ============================================
REM This uses the last successful APK build and just reinstalls it
REM Since we only changed Dart code (not native), this works fine
REM ============================================

echo.
echo Checking phone connection...
"C:\Users\Code Explorer\AppData\Local\Android\Sdk\platform-tools\adb.exe" devices | findstr "RFCY20CE9DF" >nul
if errorlevel 1 (
    echo ERROR: Phone not connected!
    pause
    exit /b 1
)
echo Phone connected: OK
echo.

echo Installing app to phone...
"C:\Users\Code Explorer\AppData\Local\Android\Sdk\platform-tools\adb.exe" install -r "build\app\outputs\flutter-apk\app-debug.apk"

if errorlevel 1 (
    echo Installation failed!
    pause
    exit /b 1
)

echo.
echo ============================================
echo SUCCESS!
echo ============================================
echo.
pause
