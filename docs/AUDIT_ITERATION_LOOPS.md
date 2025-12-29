# Audit Iteration Loops

> Framework for comprehensive project audit before continuing development.
> Created: December 29, 2025

---

## Overview

Five sequential loops designed to verify environment, identify gaps, verify completeness, plan next steps, and prepare for store submission - all with dependencies identified BEFORE any coding starts.

---

## Loop 0: ENVIRONMENT CHECK

### Purpose
Verify all tools and dependencies are working before we start. Prevents mid-audit failures.

### Process
1. Verify Git is working:
   - `git --version`
   - `git status` in project directory

2. Verify Flutter is working:
   - `flutter --version`
   - `flutter doctor`

3. Verify Dart is working:
   - `dart --version`

4. Verify Java is working:
   - `java --version`

5. Verify Android SDK:
   - Check SDK location exists
   - Check build-tools present

6. Verify project builds:
   - `flutter analyze`
   - `flutter build appbundle --release` (or verify recent build exists)

### Output Format
```
## ENVIRONMENT STATUS

| Tool | Status | Version/Location |
|------|--------|------------------|
| Git | OK/FAIL | version |
| Flutter | OK/FAIL | version |
| Dart | OK/FAIL | version |
| Java | OK/FAIL | version |
| Android SDK | OK/FAIL | location |
| Project Build | OK/FAIL | last successful |

### Issues Found
- Issue 1: description + fix
```

### Gate
**DO NOT PROCEED** to Loop 1 if any critical tool is failing.

---

## Loop 1: AUDIT - What's Missing?

### Purpose
Find all gaps before they become problems. Identify everything required but not yet implemented.

### Process

**1. Documentation Review:**
- Read PRD / product requirements
- Read PHASE_STATUS.md
- Read CLAUDE_CONTEXT.md
- Read any other docs in /docs folder

**2. Technical Configuration Review:**
- pubspec.yaml (dependencies, assets, version)
- android/app/build.gradle.kts (signing, version, SDK)
- android/app/src/main/AndroidManifest.xml (permissions, app config)
- ios/Runner/Info.plist (permissions, app config) - if iOS build exists

**3. Code Completeness Scan:**
- List all screens in /lib/screens
- Check each screen for error handling
- Check navigation flows are complete
- Check for TODO comments or placeholder code
- Check for hardcoded strings that should be configurable

**4. Security & Credentials Check:**
- Scan for hardcoded secrets/API keys in code
- Verify .gitignore excludes sensitive files (key.properties, *.jks)
- Check if keystore is backed up (note location)
- Check for passwords visible in logs or comments

**5. Store Requirements Check (Google Play):**
- App icon exists (512x512 PNG)
- Privacy policy accessible in app
- Privacy policy URL (hosted externally - stores require URL)
- App version/build number set correctly
- Package name is final
- Signing key created and secured

**6. Store Requirements Check (Apple - for later):**
- App icon (1024x1024 PNG)
- All required Info.plist entries
- App Transport Security configured

**7. Standard Mobile App Checklist:**
- App icon (all sizes generated)
- Splash screen (branded, not default)
- Loading states (spinners where needed)
- Error states (what happens when things fail)
- Empty states (what shows when no data)
- Offline handling (graceful degradation)

**8. Legal & Content:**
- Privacy Policy in app
- Terms of Service in app
- Content appropriate (no offensive material)
- Third-party licenses (if using assets that require attribution)

### Output Format
```
## AUDIT RESULTS

### CRITICAL (Blocks store submission)
- [ ] Item - Description - Why critical

### IMPORTANT (Should fix before public launch)
- [ ] Item - Description

### NICE-TO-HAVE (Can defer to later)
- [ ] Item - Description
```

---

## Loop 2: VERIFY - What's Actually Complete?

### Purpose
Confirm items marked as "done" are actually done and working. Trust but verify.

### Process

**1. Load "Done" Items:**
- Read PHASE_STATUS.md
- Extract all items marked as Done/Complete

**2. Code Verification (for each item):**
- Locate the relevant code file(s)
- Verify the file exists
- Verify the code compiles (`flutter analyze`)
- Verify it's reachable (navigation path exists from home)
- Check for TODO/FIXME comments within the code
- Check for placeholder data

**3. Game Mode Verification (for each mode):**
- Screen file exists in /lib/screens
- Data file exists in /assets/data
- Mode appears in gameModes list
- Navigation from home screen works
- Results screen exists and is navigated to

**4. Feature Verification (for each feature):**
- Code path is complete (no dead ends)
- All imports resolve
- No hardcoded test values
- Error handling present

**5. Manual Test List:**
- Items that need human verification
- Specific test steps provided

### Output Format
```
## VERIFICATION RESULTS

### CONFIRMED COMPLETE
- [x] Item - Verified: file.dart exists, navigation works

### INCOMPLETE (Marked done but has issues)
- [ ] Item - Issue: description of problem

### NEEDS MANUAL TESTING
- [ ] Item - Test: steps to verify manually
```

---

## Loop 3: PLAN - What's Next & Prerequisites

### Purpose
Create actionable plan with ALL dependencies identified BEFORE coding starts. No surprises.

### Process

**1. Consolidate Work Items:**
- Gaps from Loop 1 (CRITICAL first, then IMPORTANT)
- Incomplete items from Loop 2
- Prioritize by: blocks submission > affects users > nice-to-have

**2. For Each Work Item, Identify:**

**Code Requirements:**
- Files to create/modify
- Complexity (Simple/Medium/Complex)

**Package Dependencies:**
- Package name and version
- Check compatibility with existing packages
- Installation command

**External Services/Accounts:**
- Service name
- Account creation URL
- API keys or credentials needed
- Setup steps required

**Assets Required:**
- Images: dimensions, format, purpose
- Data files: format, content needed
- Where to source/create them

**Environment Requirements:**
- Tools to install
- Configuration changes
- Permissions needed

**3. Risk Assessment:**
- External dependencies (things outside our control)
- Hidden complexity flags
- Single points of failure

**4. Create Ordered Task List:**
- Group by phase
- Dependencies first
- Quick wins identified

### Output Format
```
## EXECUTION PLAN

### PREREQUISITES (Do ALL of these BEFORE any coding)

**Packages to Install:**
- [ ] package_name: ^version - purpose

**Accounts to Create:**
- [ ] Service Name - URL - what it's for

**Assets to Create:**
- [ ] Asset description - size/format - where to create

**Configuration:**
- [ ] Config change - file - what to change

---

### PHASE: [Name]

#### Task 1: [Name]
**Priority:** Critical/Important/Nice-to-have
**Complexity:** Simple/Medium/Complex
**Risk:** Low/Medium/High - reason

**Prerequisites:** (items from above that must be done first)
- Prerequisite 1

**Implementation Steps:**
1. Step 1
2. Step 2

**Verification:**
- How to confirm it's done

---
```

---

## Loop 4: STORE SUBMISSION CHECKLIST

### Purpose
Specific checklist for what's needed to submit to Google Play and Apple App Store.

### Process

**1. Google Play Console Requirements:**
- [ ] App created in Play Console
- [ ] Store listing: App name (30 chars)
- [ ] Store listing: Short description (80 chars)
- [ ] Store listing: Full description (4000 chars)
- [ ] Store listing: App icon (512x512 PNG)
- [ ] Store listing: Feature graphic (1024x500 PNG)
- [ ] Store listing: Screenshots - Phone (min 2, 16:9 or 9:16)
- [ ] Store listing: Screenshots - Tablet (if supporting)
- [ ] Content rating questionnaire completed
- [ ] Privacy policy URL (must be publicly accessible)
- [ ] App category selected
- [ ] Contact email provided
- [ ] Target audience and content settings
- [ ] App access (if login required, provide test credentials)
- [ ] Ads declaration
- [ ] App signing key enrolled

**2. Apple App Store Requirements (for later):**
- [ ] Apple Developer account active
- [ ] App created in App Store Connect
- [ ] App icon (1024x1024 PNG, no alpha)
- [ ] Screenshots for each device size
- [ ] App description
- [ ] Keywords
- [ ] Privacy policy URL
- [ ] Support URL
- [ ] Age rating questionnaire
- [ ] App category
- [ ] Build uploaded via TestFlight/Codemagic

**3. Both Stores - Common:**
- [ ] Privacy policy hosted at public URL
- [ ] App version number finalized
- [ ] Release notes written
- [ ] No placeholder content
- [ ] No test/debug code in release build

### Output Format
```
## STORE SUBMISSION STATUS

### Google Play - Ready: YES/NO
| Requirement | Status | Notes |
|-------------|--------|-------|
| Item | Done/Missing/Partial | details |

### Apple App Store - Ready: YES/NO
| Requirement | Status | Notes |
|-------------|--------|-------|
| Item | Done/Missing/Blocked | details |

### Blockers
- Blocker 1: description
```

---

## Execution Order

```
┌─────────────────────────────────────────────────────────────┐
│  Loop 0: Environment Check                                  │
│  ├── All tools working?                                     │
│  └── GATE: Stop if failures                                 │
├─────────────────────────────────────────────────────────────┤
│  Loop 1: Audit                                              │
│  ├── Find all gaps                                          │
│  └── Categorize: Critical / Important / Nice-to-have        │
├─────────────────────────────────────────────────────────────┤
│  Loop 2: Verify                                             │
│  ├── Check "done" items are actually done                   │
│  └── List items needing manual testing                      │
├─────────────────────────────────────────────────────────────┤
│  Loop 3: Plan                                               │
│  ├── Consolidate all work items                             │
│  ├── Identify ALL prerequisites                             │
│  └── Create ordered execution plan                          │
├─────────────────────────────────────────────────────────────┤
│  Loop 4: Store Checklist                                    │
│  ├── Google Play requirements                               │
│  └── Apple App Store requirements                           │
├─────────────────────────────────────────────────────────────┤
│  *** STOP AND REPORT TO USER ***                            │
│  Present all findings before any coding                     │
├─────────────────────────────────────────────────────────────┤
│  User Reviews & Approves                                    │
│  ├── Approve prerequisites                                  │
│  └── Approve execution plan                                 │
├─────────────────────────────────────────────────────────────┤
│  Install All Prerequisites                                  │
│  ├── Packages                                               │
│  ├── Create accounts                                        │
│  └── Create assets                                          │
├─────────────────────────────────────────────────────────────┤
│  Execute Plan                                               │
│  └── Only after ALL prerequisites in place                  │
└─────────────────────────────────────────────────────────────┘
```

---

## Success Criteria

- [ ] No environment failures during execution
- [ ] No surprises or missing dependencies
- [ ] No mid-task installations
- [ ] No "we forgot X" moments
- [ ] Clear progress tracking throughout
- [ ] User can step away and return knowing exactly where things stand

---

## Anti-Patterns to Avoid

1. **Don't start coding during audit** - Loops 0-2 are READ-ONLY
2. **Don't assume "done" means done** - Verify everything in Loop 2
3. **Don't skip prerequisites** - List them ALL in Loop 3
4. **Don't bundle unrelated tasks** - Keep tasks atomic
5. **Don't hide complexity** - Be honest about effort and risk
6. **Don't proceed past gates if failures exist** - Fix first, then continue

---

## Results

*Results will be appended below as each loop completes.*

---
