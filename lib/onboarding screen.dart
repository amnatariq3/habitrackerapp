import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Bottom Navigation Bar.dart'; // Your HomeScreen
import 'color compound class.dart';  // Appcolors.theme & Appcolors.subtheme

class OnboardingScreen extends StatefulWidget {
  final bool isDarkMode;
  final void Function(bool) onThemeToggle;
  final VoidCallback onDone;

  const OnboardingScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
    required this.onDone,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<OnboardModel> _pages = [
    OnboardModel(
      image: Icons.check_circle_outline,
      title: 'Welcome to Routiny',
      description: 'This app will help you keep an organized routine as you build new habits!',
    ),
    OnboardModel(
      image: Icons.timeline,
      title: 'Track Progress',
      description: 'Visualize your habit streaks and never break the chain!',
    ),
    OnboardModel(
      image: Icons.notifications_active,
      title: 'Get Reminders',
      description: 'Enable daily reminders so you never forget to check‑in.',
    ),
    OnboardModel(
      image: Icons.lock,
      title: 'Secure Login',
      description: 'Securely manage your habits anywhere, anytime.',
    ),
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    widget.onDone(); // tell AuthWrapper
  }

  void _nextPage() {
    if (_currentIndex < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skip() => _completeOnboarding();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _pages.length,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_pages[index].image, size: 100, color: Appcolors.theme),
                    const SizedBox(height: 30),
                    Text(
                      _pages[index].title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Appcolors.subtheme,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _pages[index].description,
                      style: const TextStyle(fontSize: 16, color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _skip,
                  child: const Text("Skip", style: TextStyle(color: Colors.white70)),
                ),
                Row(
                  children: List.generate(
                    _pages.length,
                        (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentIndex == index
                            ? Appcolors.subtheme
                            : Appcolors.theme.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _nextPage,
                  child: Text(
                    _currentIndex == _pages.length - 1 ? "Start" : "Next",
                    style: const TextStyle(color: Colors.white70),
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

/* ────────────── OnboardModel ────────────── */
class OnboardModel {
  final IconData image;
  final String title;
  final String description;

  const OnboardModel({
    required this.image,
    required this.title,
    required this.description,
  });
}
