import 'package:flutter/material.dart';
import 'Color Compound class.dart';
import 'Next2 DateselectionScreen.dart';

class FrequencySelectionScreen extends StatefulWidget {
  final String habitName;
  final String description;
  final String? condition;
  final String? goal;
  final String? unit;
  final String? time;

  const FrequencySelectionScreen({
    super.key,
    required this.habitName,
    required this.description,
    this.condition,
    this.goal,
    this.unit,
    this.time,
  });

  @override
  State<FrequencySelectionScreen> createState() => _FrequencySelectionScreenState();
}

class _FrequencySelectionScreenState extends State<FrequencySelectionScreen> {
  int? selectedOption = 0;

  final List<String> frequencyOptions = [
    "Every day",
    "Specific days of the week",
    "Specific days of the month",
    "Specific days of the year",
    "Some days per period",
    "Repeat"
  ];

  void onNext() {
    if (selectedOption == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a frequency")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DateSelectionScreen(
          habitName: widget.habitName,
          description: widget.description,
          frequency: frequencyOptions[selectedOption!],
          condition: widget.condition,
          goal: widget.goal,
          unit: widget.unit,
          time: widget.time,
        ),
      ),
    );
  }

  void onBack() => Navigator.pop(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "How often do you want to do it?",
              style: TextStyle(
                color: Appcolors.subtheme,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ...List.generate(frequencyOptions.length, (index) {
              return RadioListTile(
                activeColor: Appcolors.subtheme,
                title: Text(
                  frequencyOptions[index],
                  style: const TextStyle(color: Colors.white),
                ),
                value: index,
                groupValue: selectedOption,
                onChanged: (value) {
                  setState(() {
                    selectedOption = value!;
                  });
                },
              );
            }),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: onBack,
                  child: const Text("BACK", style: TextStyle(color: Colors.white)),
                ),
                Row(
                  children: List.generate(4, (index) {
                    return Icon(
                      Icons.circle,
                      size: 10,
                      color: index == 2
                          ? Appcolors.subtheme
                          : Colors.orangeAccent.withOpacity(0.4),
                    );
                  }),
                ),
                TextButton(
                  onPressed: onNext,
                  child: Text("NEXT", style: TextStyle(color: Appcolors.subtheme)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
