import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:untitled7/priority.dart';
import 'Color Compound class.dart';

class NewTaskPage extends StatefulWidget {
  @override
  State<NewTaskPage> createState() => _NewTaskPageState();
}

class _NewTaskPageState extends State<NewTaskPage> {
  final TextEditingController taskController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  bool isPending = true;
  String selectedPriority = "Default";
  String selectedCategory = "Task";

  void pickDate() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() => selectedDate = date);
    }
  }
  //
  // void pickPriority() {
  //   showModalBottomSheet(
  //     context: context,
  //     builder: (_) => ListView(
  //       children: ["Low", "Default", "High"].map((e) => ListTile(
  //         title: Text(e),
  //         onTap: () {
  //           setState(() => selectedPriority = e);
  //           Navigator.pop(context);
  //         },
  //       )).toList(),
  //     ),
  //   );
  // }

  void pickCategory() {
    showModalBottomSheet(
      context: context,
      builder: (_) => ListView(
        children: ["Task", "Health", "Study", "Work", "Other"].map((e) => ListTile(
          title: Text(e),
          onTap: () {
            setState(() => selectedCategory = e);
            Navigator.pop(context);
          },
        )).toList(),
      ),
    );
  }

  Future<void> saveTaskToRealtimeDatabase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login required.")),
      );
      return;
    }

    final taskData = {
      'title': taskController.text.trim(),
      'date': selectedDate.toIso8601String(),
      'category': selectedCategory,
      'priority': selectedPriority,
      'isPending': isPending,
      'createdAt': DateTime.now().toIso8601String(),
    };

    try {
      final DatabaseReference ref = FirebaseDatabase.instance
          .ref("users/${user.uid}/tasks")
          .push();

      await ref.set(taskData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Task saved to Realtime Database!")),
      );

      Navigator.pop(context); // Go back to tasks list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Widget buildOptionRow(String label, IconData icon,
      {String? trailing, VoidCallback? onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      onTap: onTap,
      leading: Icon(icon, color: Appcolors.subtheme),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      trailing: trailing != null
          ? Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Appcolors.theme,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(trailing,
            style: const TextStyle(color: Colors.white, fontSize: 13)),
      )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: Text("New Task", style: TextStyle(color: Appcolors.subtheme)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: taskController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Task",
                labelStyle: TextStyle(color: Appcolors.subtheme),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Appcolors.subtheme),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Appcolors.theme),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          buildOptionRow("Category", Icons.category,
              trailing: selectedCategory, onTap: pickCategory),
          buildOptionRow("Date", Icons.calendar_today,
              trailing:
              "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
              onTap: pickDate),
          buildOptionRow("Priority", Icons.flag,
              trailing: selectedPriority, onTap:()=> showPriorityDialog(context)),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            leading: Icon(Icons.pending, color: Appcolors.subtheme),
            title:
            const Text("Pending task", style: TextStyle(color: Colors.white)),
            subtitle: const Text(
              "It will be shown each day until completed.",
              style: TextStyle(fontSize: 12, color: Colors.white),
            ),
            trailing: IconButton(
              onPressed: () => setState(() => isPending = !isPending),
              icon: Icon(
                isPending ? Icons.check_circle : Icons.circle_outlined,
                color: Appcolors.subtheme,
              ),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("CANCEL", style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Appcolors.subtheme,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  onPressed: () {
                    if (taskController.text.trim().isNotEmpty) {
                      saveTaskToRealtimeDatabase();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Task name is required.")),
                      );
                    }
                  },
                  child: const Text("CONFIRM", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
