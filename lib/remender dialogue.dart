import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'Color Compound class.dart';

Future<void> openReminderDialog(BuildContext context) async {
  TimeOfDay selectedTime = TimeOfDay.now();
  String reminderType = "Notification";
  String reminderSchedule = "Always enabled";
  List<String> selectedDays = [];
  int daysBefore = 1;

  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("You must be logged in to set reminders")),
    );
    return;
  }

  final userId = user.uid;
  final dbRef = FirebaseDatabase.instance.ref("users/$userId/reminders").push();

  await showDialog(
    context: context,
    builder: (_) => StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("New reminder", style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () async {
                    TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (picked != null) {
                      setState(() => selectedTime = picked);
                    }
                  },
                  child: Text(
                    selectedTime.format(context),
                    style: TextStyle(fontSize: 24, color: Appcolors.subtheme),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: ["Don't remind", "Notification", "Alarm"].map((type) {
                    bool selected = reminderType == type;
                    return GestureDetector(
                      onTap: () => setState(() => reminderType = type),
                      child: Column(
                        children: [
                          Icon(
                            type == "Don't remind"
                                ? Icons.do_not_disturb_on
                                : type == "Notification"
                                ? Icons.notifications
                                : Icons.alarm,
                            color: selected ? Appcolors.subtheme : Colors.white54,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            type,
                            style: TextStyle(
                              color: selected ? Appcolors.subtheme : Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Reminder schedule", style: TextStyle(color: Colors.pink)),
                ),
                Column(
                  children: ["Always enabled", "Specific days of the week", "Days before"]
                      .map((type) => RadioListTile<String>(
                    activeColor: Appcolors.subtheme,
                    value: type,
                    groupValue: reminderSchedule,
                    onChanged: (value) => setState(() => reminderSchedule = value!),
                    title: Text(type, style: const TextStyle(color: Colors.white)),
                  ))
                      .toList(),
                ),
                if (reminderSchedule == "Specific days of the week")
                  Wrap(
                    spacing: 8,
                    children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].map((day) {
                      final isSelected = selectedDays.contains(day);
                      return ChoiceChip(
                        label: Text(day),
                        selected: isSelected,
                        selectedColor: Appcolors.subtheme,
                        backgroundColor: Colors.grey[800],
                        labelStyle:
                        TextStyle(color: isSelected ? Colors.white : Colors.white70),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              selectedDays.add(day);
                            } else {
                              selectedDays.remove(day);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                if (reminderSchedule == "Days before")
                  Row(
                    children: [
                      const Text("Remind", style: TextStyle(color: Colors.white70)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: "1",
                            hintStyle: TextStyle(color: Colors.white54),
                          ),
                          onChanged: (val) =>
                              setState(() => daysBefore = int.tryParse(val) ?? 1),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text("days before", style: TextStyle(color: Colors.white70)),
                    ],
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("CANCEL", style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: () async {
                final reminderData = {
                  "reminderTime": selectedTime.format(context),
                  "reminderType": reminderType,
                  "reminderSchedule": reminderSchedule,
                  "selectedDays": selectedDays,
                  "daysBefore": daysBefore,
                };

                try {
                  await dbRef.set(reminderData);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Reminder saved successfully")),
                  );
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Failed to save reminder: $e")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Appcolors.subtheme),
              child: const Text("CONFIRM", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    ),
  );
}
