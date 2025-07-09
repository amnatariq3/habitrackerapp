import 'package:flutter/material.dart';

import 'habit timer page.dart';
import 'Numeric habit page.dart';
import 'define habit page.dart';
import 'color compound class.dart';

class EvaluationMethodPage extends StatelessWidget {
  const EvaluationMethodPage({super.key});

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

              // YES / NO Habit
              _OptionButton(
                label: 'WITH A YES OR NO',
                description: 'Record whether you succeed with the activity or not',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DefineHabitPage()),
                  );
                },
              ),
              const SizedBox(height: 14),

              // Numeric Habit
              _OptionButton(
                label: 'WITH A NUMERIC VALUE',
                description: 'Establish a value as a daily goal or limit for the habit',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => NumericHabitPage()),
                  );
                },
              ),
              const SizedBox(height: 14),

              // Timer-based Habit
              _OptionButton(
                label: 'WITH A TIMER',
                description: 'Establish a time value as a daily goal or limit for the habit',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DefineHabitWithTimerPage()),
                  );
                },
              ),

              const Spacer(),

              // Back button and step indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("BACK", style: TextStyle(color: Colors.white70)),
                  ),
                  Row(
                    children: List.generate(4, (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index == 1
                              ? Appcolors.subtheme
                              : Appcolors.subtheme.withOpacity(0.3),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(width: 50), // Placeholder for layout balance
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ────────────── Option Button Widget ────────────── */
class _OptionButton extends StatelessWidget {
  final String label;
  final String description;
  final VoidCallback? onTap;
  final bool isDisabled;

  const _OptionButton({
    required this.label,
    required this.description,
    this.onTap,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color buttonColor = isDisabled
        ? Colors.grey.withOpacity(0.3)
        : Appcolors.subtheme;

    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: buttonColor,
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
              style: TextStyle(
                color: isDisabled ? Colors.grey : Colors.white70,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
