import 'package:flutter/material.dart';
import 'color compound class.dart';
import 'Next frequencyselection screen.dart';

class DefineNumericHabitPage extends StatefulWidget {
  const DefineNumericHabitPage({super.key});

  @override
  _DefineNumericHabitPageState createState() => _DefineNumericHabitPageState();
}

class _DefineNumericHabitPageState extends State<DefineNumericHabitPage> {
  final TextEditingController habitController = TextEditingController();
  final TextEditingController goalController = TextEditingController();
  final TextEditingController unitController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String selectedCondition = 'At least';

  void onNextPressed() {
    final habit = habitController.text.trim();
    final goal = goalController.text.trim();
    final unit = unitController.text.trim();
    final description = descriptionController.text.trim();

    if (habit.isEmpty || goal.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Habit and goal are required")),
      );
      return;
    }
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
                    color: Appcolors.subtheme,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
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
                    borderSide: BorderSide(color: Appcolors.subtheme),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: selectedCondition,
                      dropdownColor: Colors.black,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Appcolors.subtheme),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Appcolors.subtheme),
                        ),
                      ),
                      items: ['At least', 'At most', 'Exactly']
                          .map((val) => DropdownMenuItem(
                        value: val,
                        child: Text(val),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCondition = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: goalController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Goal',
                        hintStyle: const TextStyle(color: Colors.grey),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Appcolors.subtheme),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Appcolors.subtheme),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: unitController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Unit (optional)',
                  hintStyle: const TextStyle(color: Colors.grey),
                  suffixText: 'a day',
                  suffixStyle: const TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Appcolors.subtheme),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Appcolors.subtheme),
                  ),
                ),
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
                padding: const EdgeInsets.all(16),
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
                          size: 8,
                          color: index == 0 ? Appcolors.subtheme : Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      final habit = habitController.text.trim();
                      final goal = goalController.text.trim();
                      final unit = unitController.text.trim();
                      final description = descriptionController.text.trim();

                      if (habit.isEmpty || goal.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Habit and goal are required")),
                        );
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FrequencySelectionScreen(
                            habitName: habit,
                            description: description,
                            condition: selectedCondition,
                            goal: goal,
                            unit: unit,
                          ),
                        ),
                      );
                    },
                    child: Text('NEXT', style: TextStyle(color: Appcolors.subtheme)),
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
