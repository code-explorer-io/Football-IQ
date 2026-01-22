@echo off
echo.
echo ========================================
echo Football IQ - Build APK
echo ========================================
echo.
echo This script will build a new APK with your latest changes.
echo This may take 3-5 minutes...
echo.

cd /d "%~dp0android"

echo Setting up environment...
set FLUTTER_PREBUILT_ENGINE_VERSION=1527ae0ec577a4ef50e65f6fefcfc1326707d9bf
set JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-17.0.17.10-hotspot

echo.
echo Starting Gradle build...
echo.

call gradlew.bat assembleDebug

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo Build Successful!
    echo ========================================
    echo.
    echo APK Location:
    echo %~dp0build\app\outputs\flutter-apk\app-debug.apk
    echo.
    echo Next steps:
    echo 1. Run install-to-phone.bat to install on your Samsung Galaxy S23
    echo 2. Or manually copy the APK to your phone
    echo.
) else (
    echo.
    echo ========================================
    echo Build Failed!
    echo ========================================
    echo.
    echo Please check the error messages above.
    echo.
)

pause
