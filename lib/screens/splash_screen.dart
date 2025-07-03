import 'package:flutter/material.dart';
import 'role_selection_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String? _selectedLanguage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo
                          Container(
                            width: 120,
                            height: 120,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFE31837),
                            ),
                            child: const Center(
                              child: Text(
                                'RL',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // App Name
                          const Text(
                            'Welcome to ReliefLink',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Subtitle
                          const Text(
                            'Disaster Relief Coordination',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF666666),
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Language Selection
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed:
                                        () => _handleLanguageSelection('en'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          _selectedLanguage == 'en'
                                              ? const Color(0xFFE31837)
                                              : Colors.white,
                                      foregroundColor:
                                          _selectedLanguage == 'en'
                                              ? Colors.white
                                              : const Color(0xFFE31837),
                                      side: const BorderSide(
                                        color: Color(0xFFE31837),
                                      ),
                                    ),
                                    child: const Text('English'),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed:
                                        () => _handleLanguageSelection('bn'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          _selectedLanguage == 'bn'
                                              ? const Color(0xFFE31837)
                                              : Colors.white,
                                      foregroundColor:
                                          _selectedLanguage == 'bn'
                                              ? Colors.white
                                              : const Color(0xFFE31837),
                                      side: const BorderSide(
                                        color: Color(0xFFE31837),
                                      ),
                                    ),
                                    child: const Text('বাংলা'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Continue Button
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed:
                                    _selectedLanguage != null
                                        ? () => _handleContinue(context)
                                        : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFE31837),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                                child: const Text(
                                  'Continue',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Emergency Alert Button
            Positioned(
              left: 16,
              top: 16,
              child: IconButton(
                onPressed: () {
                  // Handle emergency alert tap
                },
                icon: const Icon(Icons.warning_amber_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLanguageSelection(String languageCode) {
    setState(() {
      _selectedLanguage = languageCode;
    });
  }

  void _handleContinue(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
    );
  }
}
