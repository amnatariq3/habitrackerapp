import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Bottom Navigation Bar.dart'; // HomeScreen
import 'login page.dart';            // Login page
import 'onboarding screen.dart';     // Onboarding page

class AuthWrapper extends StatefulWidget {
  final bool isDarkMode;
  final void Function(bool) onThemeToggle;

  const AuthWrapper({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _showOnboarding = false;
  String? _lastUserId;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeen = prefs.getBool('hasSeenOnboarding') ?? false;
    setState(() {
      _showOnboarding = !hasSeen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Not logged in → Login page
        if (!snapshot.hasData) {
          return const LoginPage();
        }

        final user = snapshot.data!;

        // If user changed, reset onboarding check
        if (_lastUserId != user.uid) {
          _lastUserId = user.uid;
          _checkOnboardingStatus();
        }

        // Show onboarding if needed
        if (_showOnboarding) {
          return OnboardingScreen(
            isDarkMode: widget.isDarkMode,
            onThemeToggle: widget.onThemeToggle,
            onDone: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('hasSeenOnboarding', true);
              setState(() => _showOnboarding = false);
            },
          );
        }

        // Logged in and onboarding complete → Home
        return HomeScreen(
          isDarkMode: widget.isDarkMode,
          onThemeToggle: widget.onThemeToggle,
        );
      },
    );
  }
}
