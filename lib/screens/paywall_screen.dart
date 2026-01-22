import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../services/purchase_service.dart';
import '../services/analytics_service.dart';
import '../services/haptic_service.dart';
import '../theme/app_theme.dart';

/// Premium upgrade screen.
/// Shows benefits and handles purchase flow.
class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  bool _isLoading = true;
  bool _isPurchasing = false;
  List<Package> _packages = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOfferings();
    AnalyticsService.logPaywallViewed();
  }

  Future<void> _loadOfferings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final packages = await PurchaseService.getPackages();
      if (mounted) {
        setState(() {
          _packages = packages;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Unable to load. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handlePurchase() async {
    HapticService.tap();
    setState(() => _isPurchasing = true);

    final success = await PurchaseService.purchasePremium();

    if (mounted) {
      setState(() => _isPurchasing = false);

      if (success) {
        // Celebrate the purchase!
        HapticService.celebrate();
        // Show success and pop back
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Welcome to Premium! All content unlocked.'),
            backgroundColor: AppTheme.correct,
          ),
        );
        Navigator.of(context).pop(true); // Return true to indicate purchase
      }
    }
  }

  Future<void> _handleRestore() async {
    HapticService.tap();
    setState(() => _isPurchasing = true);

    final success = await PurchaseService.restorePurchases();

    if (mounted) {
      setState(() => _isPurchasing = false);

      if (success) {
        HapticService.celebrate();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Purchase restored! Welcome back.'),
            backgroundColor: AppTheme.correct,
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No previous purchase found.'),
            backgroundColor: AppTheme.textMuted,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppTheme.textPrimary),
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            children: [
              // Header - Reduced spacing for better fit
              const Icon(
                Icons.star,
                size: 56,
                color: AppTheme.gold,
              ),
              const SizedBox(height: 12),
              const Text(
                'Unlock Everything',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'One-time purchase. No subscriptions.',
                style: TextStyle(
                  fontSize: 15,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              // Benefits list
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildBenefitItem(
                        Icons.shield,
                        'All Clubs',
                        'Arsenal, Man City, and future clubs',
                      ),
                      _buildBenefitItem(
                        Icons.games,
                        'All Game Modes',
                        'Survival, Blitz, Higher or Lower & more',
                      ),
                      _buildBenefitItem(
                        Icons.update,
                        'Free Updates',
                        'New clubs and modes added regularly',
                      ),
                      _buildBenefitItem(
                        Icons.block,
                        'No Ads. Ever.',
                        'Clean, distraction-free experience',
                      ),
                    ],
                  ),
                ),
              ),

              // Purchase section
              if (_isLoading)
                const CircularProgressIndicator(color: AppTheme.gold)
              else if (_errorMessage != null)
                Column(
                  children: [
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: AppTheme.incorrect),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _loadOfferings,
                      child: const Text('Try Again'),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    // Price button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isPurchasing ? null : _handlePurchase,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.gold,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isPurchasing
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black,
                                ),
                              )
                            : Text(
                                _packages.isNotEmpty
                                    ? 'Unlock for ${_packages.first.storeProduct.priceString}'
                                    : 'Unlock Premium',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Restore purchases
                    TextButton(
                      onPressed: _isPurchasing ? null : _handleRestore,
                      child: const Text(
                        'Restore Purchase',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.gold.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.gold, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
