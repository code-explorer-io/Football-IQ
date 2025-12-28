import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const FootballIQApp());
}

class FootballIQApp extends StatelessWidget {
  const FootballIQApp({super.key});

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
      home: const SplashScreen(),
    );
  }
}
