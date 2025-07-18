import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'Bottom Navigation Bar.dart';
import 'Color Compound class.dart';
import 'remender dialogue.dart';

class DateSelectionScreen extends StatefulWidget {
  final String habitName;
  final String description;
  final String frequency; // "Habit", "Single", or "Recurring"
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
  DateTime? startDate = DateTime.now();
  DateTime? endDate;
  bool isEndDateEnabled = false;
  String priority = "Default";

  int reminderCount = 0;
  TimeOfDay selectedTime = TimeOfDay.now();
  String reminderType = "Notification";
  String reminderSchedule = "Always enabled";
  List<String> selectedDays = [];
  int daysBefore = 1;

  Future<void> pickDate({required bool isStart}) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? (startDate ?? DateTime.now()) : (endDate ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) startDate = picked;
        else endDate = picked;
      });
    }
  }

  Future<void> saveToDatabase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You must be logged in to save")),
      );
      return;
    }

    final formattedTime = "${selectedTime.hour}:${selectedTime.minute}";
    final isHabit = widget.frequency == 'Habit';
    final isRecurring = widget.frequency == 'Recurring';

    final path = isHabit
        ? 'habits'
        : isRecurring
        ? 'recurringTasks'
        : 'singleTasks';

    final ref = FirebaseDatabase.instance.ref("users/${user.uid}/$path").push();

    await ref.set({
      'task': widget.habitName,
      'description': widget.description,
      'condition': widget.condition ?? '',
      'goal': widget.goal ?? '',
      'unit': widget.unit ?? '',
      'time': widget.time ?? '',
      'priority': priority,
      'reminders': reminderCount,
      'reminderTime': formattedTime,
      'reminderType': reminderType,
      'reminderSchedule': reminderSchedule,
      'selectedDays': selectedDays,
      'daysBefore': daysBefore,
      'startDate': startDate?.toIso8601String(),
      'endDate': isEndDateEnabled ? endDate?.toIso8601String() : null,
      'date': DateFormat('yyyy-MM-dd').format(startDate ?? DateTime.now()),
      'type': isHabit ? 'habit' : isRecurring ? 'recurring' : 'single',
      'createdAt': DateTime.now().toIso8601String(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Saved successfully!")),
    );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => HomeScreen(
          isDarkMode: Theme.of(context).brightness == Brightness.dark,
          onThemeToggle: (_) {},
        ),
      ),
          (route) => false,
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
        opacity: enabled ? 1 : 0.5,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          margin: const EdgeInsets.symmetric(vertical: 6),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(toolbarHeight: 0, backgroundColor: Colors.black),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text("When do you want to do it?",
                style: TextStyle(fontSize: 20, color: Appcolors.subtheme, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            buildTile(
              icon: Icons.calendar_today,
              label: "Start date",
              value: "${startDate!.day}/${startDate!.month}/${startDate!.year}",
              onTap: () => pickDate(isStart: true),
            ),
            Row(
              children: [
                Expanded(
                  child: buildTile(
                    icon: Icons.calendar_today_outlined,
                    label: "End date",
                    value: endDate != null
                        ? "${endDate!.day}/${endDate!.month}/${endDate!.year}"
                        : "Not set",
                    onTap: () => pickDate(isStart: false),
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
            buildTile(
              icon: Icons.notifications,
              label: "Reminders",
              value: "$reminderCount",
              onTap: () => openReminderDialog(context),
            ),
            buildTile(
              icon: Icons.flag,
              label: "Priority",
              value: priority,
              onTap: () {
                showPriorityDialog(context).then((value) {
                  if (value != null) setState(() => priority = value);
                });
              },
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("BACK", style: TextStyle(color: Colors.white70)),
                ),
                Row(
                  children: List.generate(4, (i) {
                    return Icon(Icons.circle,
                        size: 10,
                        color: i == 3 ? Appcolors.subtheme : Colors.grey.withOpacity(0.4));
                  }),
                ),
                TextButton(
                  onPressed: saveToDatabase,
                  child: Text("SAVE", style: TextStyle(color: Appcolors.subtheme)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> showPriorityDialog(BuildContext context) async {
    int currentPriority = 1;
    return await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("Set a priority", style: TextStyle(color: Colors.white)),
        content: StatefulBuilder(
          builder: (context, setState) => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => setState(() {
                  if (currentPriority > 1) currentPriority--;
                }),
                icon: const Icon(Icons.remove, color: Colors.white),
              ),
              Text('$currentPriority', style: TextStyle(color: Appcolors.subtheme, fontSize: 24)),
              IconButton(
                onPressed: () => setState(() {
                  if (currentPriority < 10) currentPriority++;
                }),
                icon: const Icon(Icons.add, color: Colors.white),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("CANCEL", style: TextStyle(color: Colors.white70))),
          TextButton(
            onPressed: () => Navigator.pop(context, "$currentPriority"),
            child: Text("SAVE", style: TextStyle(color: Appcolors.subtheme)),
          ),
        ],
      ),
    );
  }
}
