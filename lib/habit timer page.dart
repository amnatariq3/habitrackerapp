import 'package:flutter/material.dart';
import 'package:untitled7/timer%20define%20habitpage.dart';

import 'color compound class.dart'; // Appcolors.theme & Appcolors.subtheme

class DefineHabitWithTimerPage extends StatefulWidget {
  const DefineHabitWithTimerPage({super.key});

  @override
  State<DefineHabitWithTimerPage> createState() => _DefineHabitWithTimerPageState();
}

class _DefineHabitWithTimerPageState extends State<DefineHabitWithTimerPage> {
  final TextEditingController _habitController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _selectedGoalType = 'At least';
  TimeOfDay _selectedTime = const TimeOfDay(hour: 0, minute: 0);
  int _extraGoals = 0;

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _goNext() {
    final habit = _habitController.text.trim();
    final description = _descriptionController.text.trim();
    final goalType = _selectedGoalType;
    final formattedTime = _selectedTime.format(context);

    if (habit.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a habit name')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DefinetimerHabitPage()
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Define your habit',
                  style: TextStyle(
                    fontSize: 22,
                    color: Appcolors.subtheme,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              TextField(
                controller: _habitController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Habit',
                  labelStyle: const TextStyle(color: Colors.white70),
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

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: _selectedGoalType,
                      dropdownColor: Colors.black,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Appcolors.subtheme),
                        ),
                      ),
                      iconEnabledColor: Appcolors.subtheme,
                      style: const TextStyle(color: Colors.white),
                      items: const [
                        DropdownMenuItem(value: 'At least', child: Text('At least')),
                        DropdownMenuItem(value: 'At most', child: Text('At most')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedGoalType = val);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: _pickTime,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Appcolors.subtheme),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _selectedTime.format(context),
                          style: const TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('a day.', style: TextStyle(color: Colors.white70)),
                ],
              ),

              const SizedBox(height: 10),
              const Text('e.g., Run at least 30 mins a day.', style: TextStyle(color: Colors.white38)),
              const SizedBox(height: 16),

              TextField(
                controller: _descriptionController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Description (optional)',
                  hintStyle: const TextStyle(color: Colors.white38),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Appcolors.subtheme),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.power_settings_new, color: Appcolors.subtheme),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text('Extra goals', style: TextStyle(color: Colors.white)),
                    ),
                    CircleAvatar(
                      backgroundColor: Appcolors.subtheme,
                      radius: 14,
                      child: Text(
                        '$_extraGoals',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
              ),

              const Spacer(),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('BACK', style: TextStyle(color: Colors.white70)),
                  ),
                  Row(
                    children: List.generate(4, (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index == 2
                              ? Appcolors.subtheme
                              : Appcolors.subtheme.withOpacity(0.3),
                        ),
                      );
                    }),
                  ),
                  TextButton(
                    onPressed: _goNext,
                    child: const Text('NEXT', style: TextStyle(color: Colors.white70)),
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
