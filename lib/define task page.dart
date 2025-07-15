import 'package:flutter/material.dart';
import 'package:untitled7/Next%20frequencyselection%20screen.dart';
import 'Color Compound class.dart';
import 'Next2 DateselectionScreen.dart'; // Replace with actual path to your DateSelectionScreen

class DefineTaskPage extends StatefulWidget {
  const DefineTaskPage({super.key});

  @override
  State<DefineTaskPage> createState() => _DefineTaskPageState();
}

class _DefineTaskPageState extends State<DefineTaskPage> {
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  void _nextStep() {
    final taskName = _taskController.text.trim();
    final description = _descriptionController.text.trim();

    if (taskName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a task name')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FrequencySelectionScreen(
          habitName: taskName,
          description: description,
          condition: "Default",
          goal: null,
          unit: null,
          time: "N/A",
        ),
      ),
    );
  }

  void _goBack() => Navigator.pop(context);

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
                  'Define your Task',
                  style: TextStyle(
                    color: Appcolors.subtheme,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Text("Task", style: TextStyle(color: Appcolors.subtheme)),
              const SizedBox(height: 6),
              TextField(
                controller: _taskController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "e.g., Complete assignment",
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
              )
            ],
          ),
        ),
      ),
    );
  }
}
