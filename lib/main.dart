import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'services/purchase_service.dart';
import 'services/sound_service.dart';
import 'services/unlock_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Verify dev mode is disabled in release builds
  UnlockService.assertDevModeDisabled();

  // Initialize services with error handling
  String? initError;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init error: $e');
    initError = 'Failed to initialize app services';
  }

  try {
    await PurchaseService.initialize();
  } catch (e) {
    debugPrint('PurchaseService init error: $e');
    // Non-fatal - app can run without purchases
  }

  try {
    await SoundService.init();
  } catch (e) {
    debugPrint('SoundService init error: $e');
    // Non-fatal - app can run without sound
  }

  runApp(FootballIQApp(initError: initError));
}

class FootballIQApp extends StatelessWidget {
  final String? initError;

  const FootballIQApp({super.key, this.initError});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Football IQ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A1A2E),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: initError != null
          ? _ErrorScreen(message: initError!)
          : const SplashScreen(),
    );
  }
}

/// Error screen shown when app initialization fails
class _ErrorScreen extends StatelessWidget {
  final String message;

  const _ErrorScreen({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.redAccent,
                size: 64,
              ),
              const SizedBox(height: 24),
              const Text(
                'Something went wrong',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              const Text(
                'Please restart the app or check your internet connection.',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
