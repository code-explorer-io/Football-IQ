# Distribution Guide

> Step-by-step instructions for getting Football IQ to testers.

---

## Overview

| Platform | Testers | Status | Blocked By |
|----------|---------|--------|------------|
| Android | Some friends | Almost ready | Google Play approval (pending) |
| iOS | Most friends | Not started | Apple Developer signup + Codemagic setup |

**Priority:** iOS first (more testers there), Android will unblock itself once Google approves.

---

## ANDROID: Google Play Internal Testing

### Current Status
- [x] Google Play Developer account created
- [x] Paid $25 fee
- [ ] Identity verification approved (WAITING)

### Once Approved - Steps to Distribute

1. **Go to Google Play Console** - https://play.google.com/console

2. **Create App**
   - Click "Create app"
   - App name: Football IQ
   - Default language: English (UK)
   - App type: App
   - Free or paid: Free (we'll add IAP later)
   - Accept declarations

3. **Build Release APK/AAB**
   ```bash
   cd c:\Users\seanm\Projects\Football-IQ
   flutter build appbundle --release
   ```
   Output: `build\app\outputs\bundle\release\app-release.aab`

4. **Upload to Internal Testing**
   - Go to: Testing > Internal testing
   - Click "Create new release"
   - Upload the `.aab` file
   - Add release notes: "V1 - Initial test build"
   - Save and review

5. **Add Testers**
   - Go to: Testing > Internal testing > Testers tab
   - Create email list (e.g., "Friends")
   - Add tester email addresses
   - Save

6. **Share Link**
   - Copy the internal testing link
   - Send to testers via WhatsApp/email
   - They click link → redirects to Play Store → Install

### Notes
- Internal testing = instant approval (no Google review)
- Up to 100 testers allowed
- Testers must have Google account with that email

---

## iOS: Apple Developer + Codemagic + TestFlight

### Current Status
- [ ] Apple Developer account created
- [ ] Codemagic account created
- [ ] Codemagic connected to GitHub
- [ ] Codemagic connected to Apple
- [ ] First iOS build uploaded to TestFlight

### Step 1: Apple Developer Account ($99/year)

1. **Go to** https://developer.apple.com/programs/enroll/

2. **Sign in with Apple ID** (or create one)

3. **Enroll as Individual**
   - You don't need a company/organization
   - Individual is fine for publishing apps

4. **Pay $99** (annual fee)

5. **Wait for approval** (usually 24-48 hours, sometimes instant)

### Step 2: Create Codemagic Account

1. **Go to** https://codemagic.io

2. **Sign up with GitHub** (easiest - connects your repos automatically)

3. **Select your Football-IQ repo** to add it to Codemagic

### Step 3: Connect Apple Developer to Codemagic

This is the key step - it lets Codemagic build iOS apps and upload to TestFlight.

1. **In Codemagic**, go to your app settings

2. **Go to**: Distribution > Code signing > iOS

3. **You'll need from Apple Developer Portal:**
   - **App Store Connect API Key** (recommended method)
     - Go to: https://appstoreconnect.apple.com/access/api
     - Click "+" to generate new key
     - Give it "Admin" or "App Manager" role
     - Download the .p8 file (only downloadable ONCE)
     - Note the Key ID and Issuer ID

4. **In Codemagic**, add:
   - Issuer ID
   - Key ID
   - Upload the .p8 file

5. **For signing certificates**, use Codemagic's automatic option:
   - Select "Automatic code signing"
   - Codemagic will manage certificates for you

### Step 4: Configure codemagic.yaml

Create this file in your project root:

```yaml
workflows:
  ios-workflow:
    name: iOS Release
    max_build_duration: 60
    instance_type: mac_mini_m2

    environment:
      ios_signing:
        distribution_type: app_store
        bundle_identifier: com.footballiq.app
      vars:
        APP_STORE_CONNECT_ISSUER_ID: YOUR_ISSUER_ID
        APP_STORE_CONNECT_KEY_IDENTIFIER: YOUR_KEY_ID
        APP_STORE_CONNECT_PRIVATE_KEY: YOUR_P8_CONTENTS

    scripts:
      - name: Get Flutter packages
        script: flutter pub get

      - name: Build iOS
        script: flutter build ipa --release --export-options-plist=/Users/builder/export_options.plist

    artifacts:
      - build/ios/ipa/*.ipa

    publishing:
      app_store_connect:
        auth: integration
        submit_to_testflight: true
```

**Note:** We'll configure this together once you have the Apple account. The exact values depend on your Apple credentials.

### Step 5: Add Testers to TestFlight

1. **Go to** https://appstoreconnect.apple.com

2. **Select your app** (created during first build)

3. **Go to TestFlight tab**

4. **Add External Testers**
   - Create a group (e.g., "Friends")
   - Add email addresses
   - They'll get an email invite to download TestFlight app and install your app

### Notes
- TestFlight builds need a quick Apple review (usually <24 hours)
- Testers need to install TestFlight app from App Store first
- Up to 10,000 external testers allowed

---

## Tomorrow's Checklist

### Morning (can do in parallel)
- [ ] Check Google Play Console - is account approved?
- [ ] Sign up for Apple Developer ($99)

### Once Apple Developer approved
- [ ] Create Codemagic account (sign up with GitHub)
- [ ] Add Football-IQ repo to Codemagic
- [ ] Generate App Store Connect API key
- [ ] Configure Codemagic iOS signing
- [ ] Trigger first iOS build
- [ ] Add testers to TestFlight

### Once Google Play approved
- [ ] Create app in Play Console
- [ ] Build release AAB: `flutter build appbundle --release`
- [ ] Upload to Internal Testing
- [ ] Add tester emails
- [ ] Share testing link

---

## Quick Reference

| Service | URL |
|---------|-----|
| Google Play Console | https://play.google.com/console |
| Apple Developer | https://developer.apple.com |
| App Store Connect | https://appstoreconnect.apple.com |
| Codemagic | https://codemagic.io |
| GitHub Repo | https://github.com/seanmccloskey10-cell/Football-IQ |

---

## Estimated Timeline

| Task | Time |
|------|------|
| Apple Developer signup | 10 mins |
| Apple approval | 24-48 hours (sometimes instant) |
| Codemagic setup | 30 mins |
| First iOS build | 15 mins |
| TestFlight review | <24 hours |
| **Total to first iOS tester** | **1-3 days** |

| Task | Time |
|------|------|
| Google Play approval | Already waiting |
| App creation + upload | 20 mins |
| **Total to first Android tester** | **Same day once approved** |

---

*Last updated: 2024-12-28*
