@echo off
echo.
echo ========================================
echo Football IQ - Install to Phone
echo ========================================
echo.
echo Checking for connected devices...
echo.

"%LocalAppData%\Android\Sdk\platform-tools\adb.exe" devices

echo.
echo If your Samsung Galaxy S23 appears above, the app will now install...
echo If not, please:
echo   1. Check USB cable is connected
echo   2. Ensure USB Debugging is enabled on phone
echo   3. Accept the USB debugging authorization prompt if it appears
echo   4. Run this script again
echo.

set APK_PATH="%~dp0build\app\outputs\flutter-apk\app-debug.apk"

if exist %APK_PATH% (
    echo Installing Football IQ...
    echo.
    "%LocalAppData%\Android\Sdk\platform-tools\adb.exe" install -r %APK_PATH%
    echo.
    echo ========================================
    echo Installation complete!
    echo ========================================
    echo.
    echo The app should now appear on your phone.
    echo Look for "Football IQ" in your app drawer.
    echo.
) else (
    echo ERROR: APK not found at %APK_PATH%
    echo Please run the build script first.
    echo.
)

pause
