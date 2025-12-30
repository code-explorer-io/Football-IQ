# Fix Git PATH - Run this script as Administrator OR as your user
# This adds GitHub Desktop's Git to your User PATH permanently

$gitPath = "C:\Users\seanm\AppData\Local\GitHubDesktop\app-3.5.4\resources\app\git\cmd"

# Verify the path exists
if (-not (Test-Path "$gitPath\git.exe")) {
    Write-Host "ERROR: git.exe not found at $gitPath" -ForegroundColor Red
    Write-Host "GitHub Desktop may have updated. Looking for current version..." -ForegroundColor Yellow

    # Try to find the current GitHub Desktop version
    $ghDesktopPath = "C:\Users\seanm\AppData\Local\GitHubDesktop"
    $appFolders = Get-ChildItem -Path $ghDesktopPath -Directory | Where-Object { $_.Name -like "app-*" } | Sort-Object Name -Descending

    if ($appFolders.Count -gt 0) {
        $latestApp = $appFolders[0].FullName
        $possibleGitPath = "$latestApp\resources\app\git\cmd"
        if (Test-Path "$possibleGitPath\git.exe") {
            Write-Host "Found git.exe at: $possibleGitPath" -ForegroundColor Green
            $gitPath = $possibleGitPath
        }
    }
}

# Get current user PATH
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")

# Check if already in PATH
if ($currentPath -like "*$gitPath*") {
    Write-Host "Git path is already in your User PATH!" -ForegroundColor Green
} else {
    # Add to PATH
    $newPath = $currentPath + ";" + $gitPath
    [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
    Write-Host "SUCCESS: Added Git to your User PATH!" -ForegroundColor Green
    Write-Host "Path added: $gitPath" -ForegroundColor Cyan
}

# Verify git works
Write-Host "`nVerifying git installation..." -ForegroundColor Yellow
$env:Path += ";$gitPath"
try {
    $gitVersion = & "$gitPath\git.exe" --version
    Write-Host "Git is working: $gitVersion" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Could not run git.exe" -ForegroundColor Red
}

Write-Host "`n=== IMPORTANT ===" -ForegroundColor Yellow
Write-Host "You must RESTART VS Code for the changes to take effect!" -ForegroundColor Yellow
Write-Host "After restarting, run 'git --version' in any terminal to verify." -ForegroundColor White
