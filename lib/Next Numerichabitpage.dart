import 'package:flutter/material.dart';
import 'Color Compound class.dart';
import 'Next frequencyselection screen.dart';

class DefineNumericHabitPage extends StatefulWidget {
  const DefineNumericHabitPage({super.key});

  @override
  _DefineNumericHabitPageState createState() => _DefineNumericHabitPageState();
}

class _DefineNumericHabitPageState extends State<DefineNumericHabitPage> {
  final TextEditingController habitController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String selectedCondition = 'At least';
  TimeOfDay selectedTime = const TimeOfDay(hour: 0, minute: 0);

  Future<void> pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  void onNextPressed() {
    final habit = habitController.text.trim();
    final description = descriptionController.text.trim();
    final condition = selectedCondition;
    final time = selectedTime.format(context);

    if (habit.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a habit")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FrequencySelectionScreen(
          habitName: habit,
          description: description,
          condition: condition,
          time: time,
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Define your habit',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Appcolors.subtheme,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: habitController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Habit',
                  labelStyle: TextStyle(color: Appcolors.subtheme),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Appcolors.subtheme),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Appcolors.subtheme, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedCondition,
                dropdownColor: Colors.black,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Goal Type',
                  labelStyle: TextStyle(color: Appcolors.subtheme),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Appcolors.subtheme),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Appcolors.subtheme, width: 2),
                  ),
                ),
                items: ['At least', 'At most', 'Exactly']
                    .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e),
                ))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    selectedCondition = val!;
                  });
                },
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: pickTime,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Appcolors.subtheme),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    '${selectedTime.format(context)} a day',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'e.g., Smoke less than 5 cigarettes a day.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: descriptionController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Description (optional)',
                  labelStyle: const TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Appcolors.subtheme),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.bolt, color: Appcolors.subtheme),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Extra goals',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const CircleAvatar(
                      backgroundColor: Colors.orange,
                      radius: 12,
                      child: Text('0', style: TextStyle(fontSize: 12, color: Colors.white)),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('BACK', style: TextStyle(color: Colors.white)),
                  ),
                  Row(
                    children: List.generate(
                      4,
                          (index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Icon(
                          Icons.circle,
                          size: 10,
                          color: index == 0 ? Appcolors.subtheme : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: onNextPressed,
                    child: Text('NEXT', style: TextStyle(color: Appcolors.subtheme)),
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
