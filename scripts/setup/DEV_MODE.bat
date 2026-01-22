@echo off
REM ============================================
REM Football IQ - Dev Mode (Hot Reload)
REM ============================================
REM This runs the app with HOT RELOAD enabled.
REM Make changes in your editor and press 'r' to reload instantly!
REM This is the FASTEST way to iterate.
REM ============================================

echo.
echo ==========================================
echo   Football IQ - Dev Mode (Hot Reload)
echo ==========================================
echo.

cd /d "%~dp0"

REM Check phone connection
echo Checking phone connection...
"C:\Users\Code Explorer\AppData\Local\Android\Sdk\platform-tools\adb.exe" devices | findstr "RFCY20CE9DF" >nul
if errorlevel 1 (
    echo.
    echo ERROR: Phone not connected!
    echo Please connect Samsung Galaxy S23 via USB
    echo.
    pause
    exit /b 1
)
echo Phone connected: OK
echo.

echo Starting Flutter in hot reload mode...
echo.
echo ==========================================
echo   COMMANDS:
echo   r - Hot reload (refresh changes)
echo   R - Hot restart (full restart)
echo   q - Quit
echo ==========================================
echo.

C:\Flutter\flutter\bin\flutter.bat run -d RFCY20CE9DF

pause
