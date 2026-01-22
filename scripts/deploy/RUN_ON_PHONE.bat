@echo off
REM ==========================================
REM Football IQ - Run on Phone with Hot Reload
REM ==========================================
REM This starts the app on your phone with hot reload enabled
REM After it launches, press 'r' to reload after making changes
REM Press 'q' to quit
REM ==========================================

echo.
echo ==========================================
echo   Football IQ - Running on Phone
echo ==========================================
echo.
echo Checking phone connection...

"C:\Users\Code Explorer\AppData\Local\Android\Sdk\platform-tools\adb.exe" devices | findstr "RFCY20CE9DF" >nul
if errorlevel 1 (
    echo ERROR: Phone not connected!
    echo.
    echo Please:
    echo   1. Connect your Samsung Galaxy S23 via USB
    echo   2. Enable USB debugging
    echo   3. Run this script again
    echo.
    pause
    exit /b 1
)

echo Phone connected: OK
echo.
echo Starting app with hot reload...
echo.
echo ==========================================
echo   HOT RELOAD CONTROLS:
echo   - Press 'r' to hot reload changes
echo   - Press 'R' to hot restart
echo   - Press 'q' to quit
echo ==========================================
echo.

cd /d "%~dp0..\.."
"C:\Flutter\flutter\bin\flutter.bat" run -d RFCY20CE9DF

echo.
echo App closed.
pause
