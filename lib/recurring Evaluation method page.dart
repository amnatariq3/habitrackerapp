import 'package:flutter/material.dart';
import 'package:untitled7/timer%20define%20habitpage.dart';
import 'Next Numerichabitpage.dart';
import 'define task page.dart';
import 'Numeric habit page.dart';
import 'habit timer page.dart';
import 'color compound class.dart';

class RecuuringEvaluationMethodPage extends StatelessWidget {
  const RecuuringEvaluationMethodPage({super.key});

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              Text(
                'How do you want to evaluate your progress?',
                style: TextStyle(
                  fontSize: 20,
                  color: Appcolors.subtheme,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              _OptionButton(
                label: 'WITH A YES OR NO',
                description: 'Record whether you succeed with the activity or not',
                onTap: () => _navigateTo(context,  DefineTaskPage()),
              ),
              const SizedBox(height: 14),

              _OptionButton(
                label: 'WITH A NUMBER',
                description: 'Track how many times or units you do the habit per day',
                onTap: () => _navigateTo(context, const DefineNumericHabitPage()),
              ),
              const SizedBox(height: 14),

              _OptionButton(
                label: 'WITH A TIMER',
                description: 'Track how long you spend on the habit daily',
                onTap: () => _navigateTo(context, const DefinetimerHabitPage()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  final String label;
  final String description;
  final VoidCallback? onTap;

  const _OptionButton({
    required this.label,
    required this.description,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Appcolors.subtheme,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              description,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
