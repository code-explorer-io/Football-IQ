# VibeCoder Guide: From Zero to Google Play

> A practical guide for first-time app developers building with Flutter and AI assistance.

**Based on real experience** - Every step, gotcha, and fix documented from building Football IQ.

---

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Phase 1: Environment Setup](#phase-1-environment-setup)
4. [Phase 2: Build Your App](#phase-2-build-your-app)
5. [Phase 3: Google Play Console Setup](#phase-3-google-play-console-setup)
6. [Phase 4: In-App Purchases with RevenueCat](#phase-4-in-app-purchases-with-revenuecat)
7. [Phase 5: Testing on Physical Device](#phase-5-testing-on-physical-device)
8. [Phase 6: Production Release](#phase-6-production-release)
9. [Common Issues & Fixes](#common-issues--fixes)
10. [Lessons Learned](#lessons-learned)

---

## Overview

This guide walks you through the complete journey of building a Flutter app and publishing it to Google Play with in-app purchases. It's written for "VibeCoder" - someone who codes with AI assistance and wants practical, step-by-step guidance.

**What you'll build:**
- A Flutter app for Android
- Google Play listing
- In-app purchases via RevenueCat
- Internal testing distribution

**Time estimate:** 2-4 days (not counting app development)

---

## Prerequisites

### Accounts Needed (create these first)
- [ ] Google Play Developer Account ($25 one-time) - [Sign up](https://play.google.com/console)
- [ ] Google Cloud Account (free) - [Sign up](https://console.cloud.google.com)
- [ ] RevenueCat Account (free tier) - [Sign up](https://app.revenuecat.com)
- [ ] GitHub Account (free) - For version control

### Software Needed
- [ ] Flutter SDK
- [ ] Android Studio (for Android SDK and emulator)
- [ ] Git
- [ ] VS Code (recommended) with Flutter extension

### Hardware
- Windows, Mac, or Linux computer
- Android phone for testing (highly recommended)

---

## Phase 1: Environment Setup

### Install Flutter (Windows)

1. Download Flutter SDK from [flutter.dev](https://flutter.dev)
2. Extract to `C:\Flutter\flutter`
3. Add to PATH: `C:\Flutter\flutter\bin`
4. Run `flutter doctor` to verify

**Common Issue: Flutter cache corruption**
```
Error: 'dart.exe' is not recognized
```
**Fix:** Delete cache and rebuild:
```bash
rm -rf C:\Flutter\flutter\bin\cache
flutter doctor
```

### Install Android Studio

1. Download from [developer.android.com](https://developer.android.com/studio)
2. Install Android SDK via SDK Manager
3. Create an emulator (optional but useful)

### Verify Setup
```bash
flutter doctor -v
```
All checkmarks should be green for Android development.

---

## Phase 2: Build Your App

### Project Structure
```
lib/
  ├── main.dart
  ├── models/
  ├── screens/
  ├── services/
  └── theme/
```

### Key Files for IAP
- `lib/services/purchase_service.dart` - RevenueCat integration
- `android/app/src/main/AndroidManifest.xml` - Needs BILLING permission

### Add BILLING Permission
In `AndroidManifest.xml`, add inside `<manifest>`:
```xml
<uses-permission android:name="com.android.vending.BILLING" />
```

**Important:** This must be in the build BEFORE you can create in-app products in Google Play Console.

---

## Phase 3: Google Play Console Setup

### Step 1: Create Your App
1. Go to [Google Play Console](https://play.google.com/console)
2. Click "Create app"
3. Fill in app details (name, language, app/game, free/paid)

### Step 2: Complete Store Listing
Required sections:
- App name and descriptions
- Screenshots (phone + tablet)
- Feature graphic
- App icon
- Privacy policy URL
- App category

### Step 3: Set Up Merchant Account
1. Go to Monetize > Products
2. You'll be prompted to create a payments profile
3. Fill in:
   - Business name (your name is fine for solo devs)
   - Customer support email
   - Credit card statement name (keep generic, e.g., "CODE EXPLORER")

**Tip:** Enrol for the 15% service fee (for developers under $1M revenue)

### Step 4: Upload Your First Build
1. Build release bundle:
   ```bash
   flutter build appbundle --release
   ```
2. Go to Release > Testing > Internal testing
3. Create new release
4. Upload `.aab` file from `build/app/outputs/bundle/release/`
5. Roll out to internal testing

**Important:** You must roll out the release, not just upload it. The status should show "Available to internal testers".

---

## Phase 4: In-App Purchases with RevenueCat

### Why RevenueCat?
- Handles both Google Play and App Store
- Simpler than raw billing APIs
- Good free tier
- Analytics dashboard

### Step 1: Create In-App Product in Google Play Console

1. Go to Monetize > Products > One-time products
2. Click "Create product"
3. Fill in:
   - Product ID: `your_app_premium` (can't change later!)
   - Name: `Your App Premium`
   - Description: `Unlock all features`
   - Price: Set in your local currency

**Common Issue:** "Need BILLING permission"
- This means your uploaded build doesn't have the permission
- Add it to AndroidManifest.xml, increment version, rebuild, upload new release

### Step 2: Set Up Google Cloud Credentials

This connects RevenueCat to Google Play. It's the most complex part.

#### Enable APIs
1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Create a project (or use existing)
3. Search and enable:
   - Google Play Android Developer API
   - Google Play Developer Reporting API

#### Create Service Account
1. Go to IAM & Admin > Service Accounts
2. Create Service Account
3. Name it (e.g., "RevenueCat")
4. Grant roles:
   - Pub/Sub Editor
   - Monitoring Viewer
5. Create JSON key and download it

#### Grant Access in Google Play Console
1. Go to Users and permissions
2. Invite new user
3. Paste service account email (from JSON file)
4. Grant permissions:
   - View app information (read only)
   - View financial data
   - Manage orders and subscriptions
5. Send invite

### Step 3: Configure RevenueCat

1. Go to [RevenueCat Dashboard](https://app.revenuecat.com)
2. Create project (or use existing)
3. Add new Play Store app:
   - App name: Your app name
   - Package name: `com.yourcompany.yourapp`
   - Upload JSON credentials file
4. Create Entitlement:
   - Identifier: `premium` (must match your code)
5. Create Product:
   - Type: Non-consumable
   - Google product identifier: `your_app_premium`
6. Create Offering:
   - Identifier: Something unique
   - Add package with your product
7. Make the offering "Current"

### Step 4: Add to Your Flutter App

```yaml
# pubspec.yaml
dependencies:
  purchases_flutter: ^8.0.0
```

```dart
// purchase_service.dart
import 'package:purchases_flutter/purchases_flutter.dart';

class PurchaseService {
  static const String _apiKey = 'goog_YourPublicAPIKey';
  static const String _entitlementId = 'premium';

  static Future<void> initialize() async {
    await Purchases.configure(PurchasesConfiguration(_apiKey));
  }

  static Future<bool> purchasePremium() async {
    final offerings = await Purchases.getOfferings();
    if (offerings.current == null) return false;

    final package = offerings.current!.availablePackages.first;
    final result = await Purchases.purchasePackage(package);

    return result.customerInfo.entitlements.all[_entitlementId]?.isActive ?? false;
  }
}
```

**Get your API key:** RevenueCat Dashboard > API keys > Copy the public key for your app (starts with `goog_`)

---

## Phase 5: Testing on Physical Device

### Add Yourself as Tester
1. Internal testing > Testers tab
2. Create email list
3. Add your Google account email
4. Save

### Get the Test Link
1. Internal testing page
2. Find "How testers join" section
3. Copy the link

### Join the Test (on your phone)
1. **Important:** Open the link in Chrome browser, NOT your email app
2. Accept the test invitation
3. Download from Play Store

**Common Issue:** "App not available for your account"
- Make sure you're signed into the right Google account
- Open link in Chrome, not Gmail/email app
- Wait a few minutes after adding email to tester list

### Test the Purchase
1. Open your app
2. Try the purchase flow
3. Google Play will show test purchase dialog

---

## Phase 6: Production Release

### Pre-Launch Checklist
- [ ] All store listing sections complete
- [ ] Screenshots uploaded
- [ ] Privacy policy URL set
- [ ] App content rating completed
- [ ] Target audience set
- [ ] IAP tested and working
- [ ] Multiple testers have tried the app

### Submit for Review
1. Go to Production track
2. Create release
3. Upload your latest `.aab`
4. Complete any missing requirements
5. Submit for review

Review typically takes 1-3 days for new apps.

---

## Common Issues & Fixes

### Build Issues

| Issue | Fix |
|-------|-----|
| `dart.exe not recognized` | Delete `flutter/bin/cache`, run `flutter doctor` |
| Version code already used | Increment build number in `pubspec.yaml` |
| Build fails with file lock | Close emulator/Android Studio, retry |

### Google Play Issues

| Issue | Fix |
|-------|-----|
| Can't create in-app products | Upload build with BILLING permission first |
| App not available for tester | Open join link in Chrome, not email |
| Product not showing in app | Make sure offering is set as "Current" |

### RevenueCat Issues

| Issue | Fix |
|-------|-----|
| Offerings returning null | Check API key is correct (goog_ not test_) |
| Purchase button does nothing | Verify offering is "Current" in dashboard |
| Credentials validation pending | Can take up to 36 hours |

---

## Lessons Learned

### What Worked Well
1. **Step-by-step approach** - One thing at a time, verify before moving on
2. **Version control** - Commit after each working state
3. **Real device testing** - Emulator can't test purchases
4. **RevenueCat** - Much simpler than raw Google Play Billing

### What We'd Do Differently
1. **Set up BILLING permission from the start** - Saves a rebuild later
2. **Create Google Cloud credentials earlier** - Takes time to validate
3. **Document as you go** - Hard to remember steps after the fact

### Tips for VibeCoding with AI
1. **Be specific** - "I see X on screen" helps AI give accurate guidance
2. **Verify steps** - If something doesn't look right, ask before proceeding
3. **Take breaks** - Complex setups are mentally taxing
4. **Screenshot everything** - Helps when asking for help

---

## Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Google Play Console Help](https://support.google.com/googleplay/android-developer)
- [RevenueCat Documentation](https://www.revenuecat.com/docs)
- [RevenueCat Google Play Setup](https://www.revenuecat.com/docs/service-credentials/creating-play-service-credentials)

---

*This guide was created from real experience building Football IQ. If you find it helpful, consider sharing with other VibeCoder.*
