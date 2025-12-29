import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection('Privacy Policy', '''
Last updated: December 29, 2025

Football IQ ("we", "our", or "us") is committed to protecting your privacy. This Privacy Policy explains how we handle information when you use our mobile application.'''),

            _buildSection('Information We Collect', '''
Football IQ does NOT collect, store, or transmit any personal information to external servers.

All data is stored locally on your device only:
- Game scores and statistics
- Achievement progress
- Game preferences

This data never leaves your device.'''),

            _buildSection('Data Storage', '''
All game data is stored locally on your device using standard app storage. This data is:
- Only accessible by the Football IQ app
- Deleted when you uninstall the app
- Not backed up to any external servers'''),

            _buildSection('Third-Party Services', '''
Football IQ does not currently use any third-party analytics, advertising, or tracking services.

If this changes in future updates, this privacy policy will be updated accordingly.'''),

            _buildSection('Children\'s Privacy', '''
Football IQ does not knowingly collect any information from children. The app does not require any personal information to function.'''),

            _buildSection('Changes to This Policy', '''
We may update this Privacy Policy from time to time. Any changes will be reflected in the app with an updated "Last updated" date.'''),

            _buildSection('Contact Us', '''
If you have any questions about this Privacy Policy, please contact us at:

code.explorer.io@gmail.com'''),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content.trim(),
            style: const TextStyle(
              fontSize: 15,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
