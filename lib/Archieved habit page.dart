import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:untitled7/color%20compound%20class.dart';

class ArchivedHabitsPage extends StatelessWidget {
  final String userId;

  const ArchivedHabitsPage({required this.userId});

  bool isHabitArchived(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value == 'true' || value == '1';
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final habitsRef = FirebaseDatabase.instance.ref('users/$userId/habits');
    final isDark = Theme
        .of(context)
        .brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Archived Habits', style: TextStyle(color: Colors.black),),
        backgroundColor: Appcolors.subtheme,
      ),
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: StreamBuilder<DatabaseEvent>(
        stream: habitsRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data?.snapshot.value;

          if (data == null || data is! Map) {
            return Center(
              child: Text("No archived habits found", style: TextStyle(color: Appcolors.subtheme)),
            );
          }

          final archivedHabits = <MapEntry<String, dynamic>>[];

          data.forEach((key, value) {
            if (value is Map) {
              if (isHabitArchived(value['isArchived'])) {
                archivedHabits.add(MapEntry(key, value));
              }
            }
          });

          if (archivedHabits.isEmpty) {
            return Center(
              child: Text("No archived habits found", style: TextStyle(color: Appcolors.subtheme)),
            );
          }

          return ListView.builder(
            itemCount: archivedHabits.length,
            itemBuilder: (context, index) {
              final habitId = archivedHabits[index].key;
              final habit = Map<String, dynamic>.from(archivedHabits[index].value);

              final title = habit['habitName'] ?? '';
              final frequency = habit['frequency'] ?? '';
              final linkCount = habit['linkCount'] ?? 0;
              final doneCount = habit['doneCount'] ?? 0;
              final completionRate = habit['completionRate'] ?? 0;

              return Card(
                color: Colors.grey[900],
                margin: const EdgeInsets.all(12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  title: Text(title, style: const TextStyle(color: Colors.white)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(frequency, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.link, size: 18, color: Colors.red),
                          Text(' $linkCount  ', style: const TextStyle(color: Colors.white)),
                          const Icon(Icons.check_circle, size: 18, color: Colors.red),
                          Text(' $doneCount  ', style: const TextStyle(color: Colors.white)),
                          const SizedBox(width: 10),
                          Text('$completionRate%', style: const TextStyle(color: Colors.white)),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.calendar_month, color: Colors.white),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(Icons.bar_chart, color: Colors.white),
                            onPressed: () {},
                          ),
                          PopupMenuButton(
                            icon: const Icon(Icons.more_vert, color: Colors.white),
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                child: const Text("Unarchive"),
                                onTap: () async {
                                  await habitsRef.child(habitId).update({'isArchived': false});
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.star, color: Colors.orange),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
