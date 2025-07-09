import 'package:flutter/material.dart';
import 'color compound class.dart';
import 'Next frequencyselection screen.dart';

class DefineHabitPage extends StatefulWidget {
  const DefineHabitPage({super.key});

  @override
  State<DefineHabitPage> createState() => _DefineHabitPageState();
}

class _DefineHabitPageState extends State<DefineHabitPage> {
  final TextEditingController _habitController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  void _goBack() => Navigator.pop(context);

  void _nextStep() {
    final habitName = _habitController.text.trim();
    final description = _descriptionController.text.trim();

    if (habitName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a habit name')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FrequencySelectionScreen(
          habitName: habitName,
          description: description,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              Center(
                child: Text(
                  'Define your habit',
                  style: TextStyle(
                    color: Appcolors.subtheme,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Text("Habit", style: TextStyle(color: Appcolors.subtheme)),
              const SizedBox(height: 6),
              TextField(
                controller: _habitController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "e.g., Do not drink alcohol.",
                  hintStyle: const TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Appcolors.subtheme),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Appcolors.subtheme, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _descriptionController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Description (optional)",
                  hintStyle: const TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade800),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Appcolors.subtheme),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                maxLines: 2,
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _goBack,
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
                  TextButton(
                    onPressed: _nextStep,
                    child: Text("NEXT", style: TextStyle(color: Appcolors.subtheme)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
