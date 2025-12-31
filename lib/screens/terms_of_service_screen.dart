import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Terms of Service'),
        backgroundColor: AppTheme.background,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection('Terms of Service', '''
Last updated: December 29, 2025

By using Football IQ, you agree to these Terms of Service.'''),

            _buildSection('Use of the App', '''
Football IQ is a trivia game for entertainment purposes. You may use the app for personal, non-commercial use.

You agree not to:
- Reverse engineer or modify the app
- Use the app for any unlawful purpose
- Distribute or share the app outside official app stores'''),

            _buildSection('Intellectual Property', '''
All content in Football IQ, including questions, design, and code, is owned by Code Explorer and protected by copyright law.

Football club names, player names, and related trademarks belong to their respective owners and are used for informational/trivia purposes only.'''),

            _buildSection('Disclaimer', '''
Football IQ is provided "as is" without warranties of any kind.

We strive for accuracy in our trivia questions, but we do not guarantee that all information is error-free. The app is for entertainment purposes.'''),

            _buildSection('Limitation of Liability', '''
To the maximum extent permitted by law, Code Explorer shall not be liable for any indirect, incidental, or consequential damages arising from your use of the app.'''),

            _buildSection('Changes to Terms', '''
We may update these Terms of Service from time to time. Continued use of the app after changes constitutes acceptance of the new terms.'''),

            _buildSection('Contact', '''
For questions about these Terms, contact us at:

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
