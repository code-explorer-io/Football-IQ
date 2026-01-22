@echo off
REM ============================================
REM Football IQ - Deployment Menu
REM ============================================

:menu
cls
echo.
echo ==========================================
echo   Football IQ - Development Menu
echo ==========================================
echo.
echo Choose your deployment method:
echo.
echo   1. Dev Mode (Hot Reload) - FASTEST
echo      Use this for active development.
echo      Make changes and press 'r' to reload.
echo.
echo   2. Quick Deploy - Full Build
echo      Use this for clean builds or first deployment.
echo.
echo   3. Clean Build - Nuclear Option
echo      Use this when something is broken.
echo      Clears cache and rebuilds everything.
echo.
echo   4. Check Phone Connection
echo      Verify phone is connected.
echo.
echo   5. Open Deployment Guide
echo      View detailed documentation.
echo.
echo   0. Exit
echo.
echo ==========================================
echo.

set /p choice=Enter your choice (1-5 or 0):

if "%choice%"=="1" goto devmode
if "%choice%"=="2" goto quickdeploy
if "%choice%"=="3" goto cleanbuild
if "%choice%"=="4" goto checkphone
if "%choice%"=="5" goto guide
if "%choice%"=="0" exit /b 0

echo Invalid choice. Please try again.
timeout /t 2 >nul
goto menu

:devmode
cls
call DEV_MODE.bat
goto menu

:quickdeploy
cls
call QUICK_DEPLOY.bat
goto menu

:cleanbuild
cls
call CLEAN_BUILD.bat
goto menu

:checkphone
cls
echo.
echo Checking phone connection...
echo.
"C:\Users\Code Explorer\AppData\Local\Android\Sdk\platform-tools\adb.exe" devices
echo.
pause
goto menu

:guide
cls
echo.
echo Opening Deployment Guide...
start DEPLOYMENT_GUIDE.md
timeout /t 2 >nul
goto menu
