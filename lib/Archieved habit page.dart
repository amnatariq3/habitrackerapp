import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'Color Compound class.dart';

class ArchivedHabitsPage extends StatefulWidget {
  const ArchivedHabitsPage({super.key});

  @override
  State<ArchivedHabitsPage> createState() => _ArchivedHabitsPageState();
}

class _ArchivedHabitsPageState extends State<ArchivedHabitsPage> {
  late final DatabaseReference habitsRef;
  late final String userId;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userId = user.uid;
      habitsRef = FirebaseDatabase.instance.ref("users/$userId/habits");
    }
  }

  Future<void> _unarchiveHabit(String habitId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Unarchive Habit"),
        content: const Text("Do you want to unarchive this habit?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Unarchive", style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await habitsRef.child(habitId).update({'isArchived': false});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Habit unarchived")),
      );
    }
  }

  Future<void> _unarchiveAllHabits(List<String> habitIds) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Unarchive All Habits"),
        content: const Text("Are you sure you want to restore all archived habits?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Restore All", style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      for (final id in habitIds) {
        await habitsRef.child(id).update({'isArchived': false});
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All habits unarchived")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Archived Habits"),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.restore, color: Colors.greenAccent),
            onPressed: () async {
              final snapshot = await habitsRef.get();
              final data = snapshot.value;
              if (data is Map) {
                final archivedIds = data.entries
                    .where((e) => e.value['isArchived'] == true)
                    .map((e) => e.key.toString())
                    .toList();
                if (archivedIds.isNotEmpty) {
                  await _unarchiveAllHabits(archivedIds);
                }
              }
            },
            tooltip: "Restore All",
          )
        ],
      ),
      body: StreamBuilder(
        stream: habitsRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data?.snapshot.value;
          if (data == null || data is! Map) {
            return const Center(
              child: Text("No archived habits found", style: TextStyle(color: Colors.white70)),
            );
          }

          final archivedHabits = data.entries
              .where((entry) => entry.value['isArchived'] == true)
              .toList();

          if (archivedHabits.isEmpty) {
            return const Center(
              child: Text("No archived habits found", style: TextStyle(color: Colors.white70)),
            );
          }

          return ListView.builder(
            itemCount: archivedHabits.length,
            itemBuilder: (context, index) {
              final habitId = archivedHabits[index].key;
              final habit = Map<String, dynamic>.from(archivedHabits[index].value);
              return Card(
                color: Colors.grey[900],
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text(habit['habitName'], style: const TextStyle(color: Colors.white)),
                  subtitle: Text(habit['description'] ?? '-', style: const TextStyle(color: Colors.white70)),
                  trailing: IconButton(
                    icon: const Icon(Icons.unarchive, color: Colors.green),
                    onPressed: () => _unarchiveHabit(habitId),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
