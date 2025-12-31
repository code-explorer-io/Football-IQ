# Git/Bash PATH Troubleshooting for Claude Code

> **Last Updated**: 1st January 2025
> **Status**: RESOLVED

## The Problem

Claude Code on Windows requires `git-bash` to function. VS Code extension shows error:
```
Error: Claude Code on Windows requires git-bash (https://git-scm.com/downloads/win).
If installed but not in PATH, set environment variable pointing to your bash.exe,
similar to: CLAUDE_CODE_GIT_BASH_PATH=C:\Program Files\Git\bin\bash.exe
```

## Root Causes Identified

### 1. GitHub Desktop Git Conflict
GitHub Desktop installs its own bundled Git that does NOT include `bash.exe`. If GitHub Desktop's paths appear in your PATH before the real Git, Claude Code finds Git but not Bash.

**Problem paths (should be REMOVED from User PATH):**
- `C:\Users\<username>\AppData\Local\GitHubDesktop\bin`
- `C:\Users\<username>\AppData\Local\GitHubDesktop\app-X.X.X\resources\app\git\cmd`

### 2. Environment Variable Not Set or Not Persisting
The Windows Environment Variables GUI can be misleading - you may think you've saved a variable but it didn't persist. Always verify via PowerShell.

### 3. VS Code Not Picking Up New Environment Variables
VS Code caches environment variables on startup. After setting new variables, you MUST fully restart VS Code (and sometimes Windows).

---

## The Solution (Verified Working)

### Required Environment Variable
```
CLAUDE_CODE_GIT_BASH_PATH = C:\Program Files\Git\bin\bash.exe
```

This should be set in **User variables** (System variables also works but User is sufficient).

### Required PATH Entries
Your User PATH should include:
```
C:\Program Files\Git\bin
```

Your User PATH should NOT include:
```
C:\Users\<username>\AppData\Local\GitHubDesktop\bin
C:\Users\<username>\AppData\Local\GitHubDesktop\app-*\resources\app\git\cmd
```

---

## How to Fix (PowerShell Commands)

### Set the Environment Variable
```powershell
[Environment]::SetEnvironmentVariable('CLAUDE_CODE_GIT_BASH_PATH', 'C:\Program Files\Git\bin\bash.exe', 'User')
```

### Verify It's Set
```powershell
[Environment]::GetEnvironmentVariable('CLAUDE_CODE_GIT_BASH_PATH', 'User')
```

### Check Current PATH
```powershell
[Environment]::GetEnvironmentVariable('PATH', 'User')
```

### Set Clean PATH (Remove GitHub Desktop, Add Git)
```powershell
# Get current path, remove GitHub Desktop entries, ensure Git\bin is included
$currentPath = [Environment]::GetEnvironmentVariable('PATH', 'User')

# Example of a clean PATH (adjust for your system):
$cleanPath = 'C:\Users\seanm\AppData\Local\Programs\Python\Python313\Scripts\;C:\Users\seanm\AppData\Local\Programs\Python\Python313\;C:\Users\seanm\AppData\Local\Programs\Python\Launcher\;C:\Program Files\Git\bin;C:\Users\seanm\AppData\Local\Microsoft\WindowsApps;C:\Users\seanm\AppData\Local\Programs\Microsoft VS Code\bin;C:\Users\seanm\AppData\Roaming\npm;C:\Flutter\flutter\bin'

[Environment]::SetEnvironmentVariable('PATH', $cleanPath, 'User')
```

---

## Verification Checklist

Run these commands to verify your setup:

```bash
# 1. Check Git is installed
where git
git --version

# 2. Check Bash is installed
where bash
bash --version

# 3. Check environment variable (in bash)
echo $CLAUDE_CODE_GIT_BASH_PATH

# 4. Verify bash.exe exists at the specified path
ls -la "/c/Program Files/Git/bin/bash.exe"

# 5. Check no GitHub Desktop in PATH
echo $PATH | tr ':' '\n' | grep -i githubdesktop
# (Should return nothing)
```

---

## After Making Changes

1. **Close ALL VS Code windows** (check Task Manager for remaining `Code` processes)
2. **Restart VS Code**
3. If still not working, **log out and back into Windows** or restart

---

## Current Working Configuration (as of 1 Jan 2025)

```
Git Version: 2.52.0.windows.1
Git Location: C:\Program Files\Git
Bash Location: C:\Program Files\Git\bin\bash.exe
CLAUDE_CODE_GIT_BASH_PATH: C:\Program Files\Git\bin\bash.exe (User + System)

User PATH:
- C:\Users\seanm\AppData\Local\Programs\Python\Python313\Scripts\
- C:\Users\seanm\AppData\Local\Programs\Python\Python313\
- C:\Users\seanm\AppData\Local\Programs\Python\Launcher\
- C:\Program Files\Git\bin  <-- Git is here, early in PATH
- C:\Users\seanm\AppData\Local\Microsoft\WindowsApps
- C:\Users\seanm\AppData\Local\Programs\Microsoft VS Code\bin
- C:\Users\seanm\AppData\Roaming\npm
- C:\Flutter\flutter\bin
```

---

## Quick Fix Script

If this happens again, run this in PowerShell (as Administrator is NOT required for User variables):

```powershell
# Set the environment variable
[Environment]::SetEnvironmentVariable('CLAUDE_CODE_GIT_BASH_PATH', 'C:\Program Files\Git\bin\bash.exe', 'User')

# Verify
Write-Host "CLAUDE_CODE_GIT_BASH_PATH is now:"
[Environment]::GetEnvironmentVariable('CLAUDE_CODE_GIT_BASH_PATH', 'User')

# Then restart VS Code
Write-Host "Now close and reopen VS Code"
```
