# Quick Build and Install Script for Football IQ
# Run this from PowerShell to build and install the updated app

Write-Host "================================" -ForegroundColor Cyan
Write-Host "Football IQ - Quick Build" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# Set working directory
Set-Location "C:\Users\Code Explorer\Documents\GitHub\Football-IQ"

Write-Host "Building APK with Gradle..." -ForegroundColor Yellow
& ".\android\gradlew.bat" -p android assembleDebug

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "Build successful!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Installing to phone..." -ForegroundColor Yellow

    & "C:\Users\Code Explorer\AppData\Local\Android\Sdk\platform-tools\adb.exe" install -r "build\app\outputs\flutter-apk\app-debug.apk"

    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "================================" -ForegroundColor Green
        Write-Host "SUCCESS!" -ForegroundColor Green
        Write-Host "================================" -ForegroundColor Green
        Write-Host "App installed on your phone with all updates!" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "Installation failed!" -ForegroundColor Red
    }
} else {
    Write-Host ""
    Write-Host "Build failed!" -ForegroundColor Red
}

Write-Host ""
Write-Host "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
