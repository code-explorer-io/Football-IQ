import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'analytics_service.dart';

/// Handles all in-app purchase logic via RevenueCat.
///
/// Entitlement: "premium" - unlocks all clubs and game modes
/// Product: One-time purchase (non-consumable)
class PurchaseService {
  static const String _entitlementId = 'premium';

  // RevenueCat API key for Google Play
  static const String _apiKey = 'goog_oFlOoAMzEvSmjjCzjidKONioDlu';

  // Cache key for offline access
  static const String _premiumCacheKey = 'is_premium_cached';

  static bool _isInitialized = false;
  static bool _isPremium = false;

  // Stream controller for premium status changes
  static final _premiumStatusController = StreamController<bool>.broadcast();
  static Stream<bool> get premiumStatusStream => _premiumStatusController.stream;

  /// Initialize RevenueCat SDK
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Load cached status first for instant UI
      await _loadCachedStatus();
      debugPrint('PurchaseService: Loaded cached premium status: $_isPremium');

      // Configure RevenueCat
      await Purchases.setLogLevel(LogLevel.debug);

      PurchasesConfiguration configuration = PurchasesConfiguration(_apiKey);
      await Purchases.configure(configuration);

      // Listen for customer info updates
      Purchases.addCustomerInfoUpdateListener((customerInfo) {
        _updatePremiumStatus(customerInfo);
      });

      // Get initial status
      final customerInfo = await Purchases.getCustomerInfo();
      _updatePremiumStatus(customerInfo);

      _isInitialized = true;
      debugPrint('RevenueCat initialized. Premium: $_isPremium');
    } catch (e) {
      debugPrint('RevenueCat initialization error: $e');
      // Fall back to cached status
    }
  }

  /// Check if user has premium access
  static bool get isPremium => _isPremium;

  /// Check premium status (async, fetches latest)
  static Future<bool> checkPremiumStatus() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      _updatePremiumStatus(customerInfo);
      return _isPremium;
    } catch (e) {
      debugPrint('Error checking premium status: $e');
      return _isPremium; // Return cached value
    }
  }

  /// Get available packages for purchase
  static Future<List<Package>> getPackages() async {
    try {
      final offerings = await Purchases.getOfferings();
      if (offerings.current != null) {
        return offerings.current!.availablePackages;
      }
    } catch (e) {
      debugPrint('Error getting offerings: $e');
    }
    return [];
  }

  /// Purchase premium access
  static Future<bool> purchasePremium() async {
    try {
      // Log analytics
      await AnalyticsService.logPurchaseStarted();

      final offerings = await Purchases.getOfferings();
      if (offerings.current == null || offerings.current!.availablePackages.isEmpty) {
        debugPrint('No offerings available');
        return false;
      }

      // Get the first available package (should be our one-time purchase)
      final package = offerings.current!.availablePackages.first;

      // Make the purchase
      final purchaseResult = await Purchases.purchase(PurchaseParams.package(package));

      _updatePremiumStatus(purchaseResult.customerInfo);

      if (_isPremium) {
        // Log successful purchase
        final price = package.storeProduct.price;
        final currency = package.storeProduct.currencyCode;
        await AnalyticsService.logPurchaseCompleted(price, currency);
        await AnalyticsService.setUserPremium(true);
      }

      return _isPremium;
    } catch (e) {
      if (e is PurchasesErrorCode) {
        debugPrint('Purchase error: $e');
      }
      return false;
    }
  }

  /// Restore previous purchases
  static Future<bool> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      _updatePremiumStatus(customerInfo);

      if (_isPremium) {
        await AnalyticsService.logPurchaseRestored();
        await AnalyticsService.setUserPremium(true);
      }

      return _isPremium;
    } catch (e) {
      debugPrint('Restore error: $e');
      return false;
    }
  }

  /// Update premium status from customer info
  static void _updatePremiumStatus(CustomerInfo customerInfo) {
    final hadPremium = _isPremium;
    _isPremium = customerInfo.entitlements.all[_entitlementId]?.isActive ?? false;

    // Cache the status
    _cachePremiumStatus(_isPremium);

    // Notify listeners if changed
    if (hadPremium != _isPremium) {
      _premiumStatusController.add(_isPremium);
    }
  }

  /// Cache premium status for offline access
  static Future<void> _cachePremiumStatus(bool isPremium) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_premiumCacheKey, isPremium);
  }

  /// Load cached premium status
  static Future<void> _loadCachedStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool(_premiumCacheKey) ?? false;
  }

  /// Dispose resources
  static void dispose() {
    _premiumStatusController.close();
  }

  /// Debug: Clear cached premium status (for testing)
  static Future<void> debugClearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_premiumCacheKey);
    _isPremium = false;
    debugPrint('PurchaseService: Cache cleared, premium reset to false');
  }
}
