import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'Color Compound class.dart';
import 'Next2 DateselectionScreen.dart';

class EditFrequencypage extends StatefulWidget {
  final String habitName;
  final String description;
  final String? condition;
  final String? goal;
  final String? unit;
  final String? time;
  final String habitId; // ✅ Add this
  const EditFrequencypage({
    super.key,
    required this.habitName,
    required this.description,
    required this.habitId, // ✅ Required
    this.condition,
    this.goal,
    this.unit,
    this.time,
  });

  @override
  State<EditFrequencypage> createState() => _EditFrequencypageState();
}

class _EditFrequencypageState extends State<EditFrequencypage> {
  int? selectedOption;

  final List<String> frequencyOptions = [
    "Every day",
    "Specific days of the week",
    "Specific days of the month",
    "Specific days of the year",
    "Some days per period",
    "Repeat",
  ];

  void onNext() async {
    if (selectedOption == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a frequency")),
      );
      return;
    }

    final selectedFrequency = frequencyOptions[selectedOption!];

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final ref = FirebaseDatabase.instance
        .ref("users/${user.uid}/habits/${widget.habitId}");

    try {
      await ref.update({
        "frequency": selectedFrequency,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Frequency updated successfully")),
      );

      // You can now go to next screen or pop
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DateSelectionScreen(
            habitName: widget.habitName,
            description: widget.description,
            frequency: selectedFrequency,
            condition: widget.condition,
            goal: widget.goal,
            unit: widget.unit,
            time: widget.time,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update: $e")),
      );
    }
  }

  void onBack() => Navigator.pop(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(toolbarHeight: 0, backgroundColor: Colors.black, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("How often do you want to do it?",
                style: TextStyle(color: Appcolors.subtheme, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ...List.generate(frequencyOptions.length, (index) {
              return RadioListTile<int>(
                activeColor: Appcolors.subtheme,
                title: Text(frequencyOptions[index], style: const TextStyle(color: Colors.white)),
                value: index,
                groupValue: selectedOption,
                onChanged: (value) {
                  setState(() {
                    selectedOption = value;
                  });
                },
              );
            }),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(onPressed: onBack, child: const Text("BACK", style: TextStyle(color: Colors.white))),
                Row(
                  children: List.generate(4, (index) {
                    return Icon(Icons.circle, size: 10, color: index == 2 ? Appcolors.subtheme : Colors.orangeAccent.withOpacity(0.4));
                  }),
                ),
                TextButton(onPressed: onNext, child: Text("CONFIRM", style: TextStyle(color: Appcolors.subtheme))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
