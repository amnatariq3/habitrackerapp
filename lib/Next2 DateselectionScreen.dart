import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'Color Compound class.dart';

class DateSelectionScreen extends StatefulWidget {
  final String habitName;
  final String description;
  final String frequency;
  final String? condition;
  final String? goal;
  final String? unit;
  final String? time;

  const DateSelectionScreen({
    super.key,
    required this.habitName,
    required this.description,
    required this.frequency,
    this.condition,
    this.goal,
    this.unit,
    this.time,
  });

  @override
  State<DateSelectionScreen> createState() => _DateSelectionScreenState();
}

class _DateSelectionScreenState extends State<DateSelectionScreen> {
  DateTime? startDate;
  DateTime? endDate;
  bool isEndDateEnabled = false;
  String priority = "Default";
  int reminders = 0;

  @override
  void initState() {
    super.initState();
    startDate = DateTime.now();
  }

  Future<void> pickDate({required bool isStart}) async {
    DateTime now = DateTime.now();
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? (startDate ?? now) : (endDate ?? now),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  void openPriorityDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("Select Priority", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ["Default", "High", "Low"].map((level) {
            return ListTile(
              title: Text(level, style: const TextStyle(color: Colors.white)),
              onTap: () {
                setState(() {
                  priority = level;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> saveToFirestore() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You must be logged in to save")),
      );
      return;
    }

    final doc = {
      'userId': user.uid,
      'habitName': widget.habitName,
      'description': widget.description,
      'frequency': widget.frequency,
      'condition': widget.condition,
      'goal': widget.goal,
      'unit': widget.unit,
      'time': widget.time,
      'priority': priority,
      'reminders': reminders,
      'startDate': startDate?.toIso8601String(),
      'endDate': isEndDateEnabled ? endDate?.toIso8601String() : null,
      'date': DateFormat('yyyy-MM-dd').format(startDate ?? DateTime.now()),
      'createdAt': Timestamp.now(),
    };

    try {
      await FirebaseFirestore.instance.collection('habits').add(doc);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Habit saved successfully!")),
      );
      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(toolbarHeight: 0, backgroundColor: Colors.black),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("When do you want to do it?",
                style: TextStyle(color: Appcolors.subtheme, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            buildTile(
              icon: Icons.calendar_today,
              label: "Start date",
              value: "${startDate!.day}/${startDate!.month}/${startDate!.year}",
              onTap: () => pickDate(isStart: true),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: buildTile(
                    icon: Icons.calendar_today_outlined,
                    label: "End date",
                    value: endDate != null
                        ? "${endDate!.day}/${endDate!.month}/${endDate!.year}"
                        : "Not set",
                    onTap: isEndDateEnabled ? () => pickDate(isStart: false) : null,
                    enabled: isEndDateEnabled,
                  ),
                ),
                Switch(
                  value: isEndDateEnabled,
                  activeColor: Appcolors.subtheme,
                  onChanged: (val) {
                    setState(() {
                      isEndDateEnabled = val;
                      if (!val) endDate = null;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            buildTile(
              icon: Icons.notifications,
              label: "Reminders",
              value: "$reminders",
              onTap: () => setState(() => reminders++),
            ),
            const SizedBox(height: 10),
            buildTile(
              icon: Icons.flag,
              label: "Priority",
              value: priority,
              onTap: openPriorityDialog,
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("BACK", style: TextStyle(color: Colors.white)),
                ),
                Row(
                  children: List.generate(4, (index) {
                    return Icon(Icons.circle,
                        size: 10,
                        color: index == 3 ? Appcolors.subtheme : Colors.orangeAccent.withOpacity(0.4));
                  }),
                ),
                TextButton(
                  onPressed: saveToFirestore,
                  child: Text("SAVE", style: TextStyle(color: Appcolors.subtheme)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTile({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
    bool enabled = true,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.5,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, color: Appcolors.subtheme),
              const SizedBox(width: 16),
              Expanded(child: Text(label, style: const TextStyle(color: Colors.white))),
              Text(value, style: TextStyle(color: Appcolors.subtheme)),
            ],
          ),
        ),
      ),
    );
  }
}
