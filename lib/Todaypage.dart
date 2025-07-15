import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'Activity type page.dart';
import 'Color Compound class.dart';

class TodayPage extends StatefulWidget {
  const TodayPage({super.key});

  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {
  final firestore = FirebaseFirestore.instance;
  late String userId;
  final db = FirebaseDatabase.instance;

  DateTime selectedDay = DateTime.now();
  String get selectedDateStr => DateFormat('yyyy-MM-dd').format(selectedDay);

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userId = user.uid;
    }
  }

  Future<List<Map<String, dynamic>>> fetchAllActivities() async {
    List<Map<String, dynamic>> activities = [];

    // Fetch tasks from Firestore (collection: scheduled)
    final taskSnap = await firestore
        .collection('scheduled')
        .where('userId', isEqualTo: userId)
        .where('date', isEqualTo: selectedDateStr)
        .get();

    for (var doc in taskSnap.docs) {
      final data = doc.data();
      data['id'] = doc.id;
      data['type'] = data['type'] ?? 'task'; // ensure 'task' type exists
      activities.add(data);
    }

    // Fetch habits from Realtime Database
    final habitSnap = await db.ref('users/$userId/habits').get();
    if (habitSnap.exists) {
      final habitsMap = habitSnap.value as Map;
      for (var entry in habitsMap.entries) {
        final habit = entry.value as Map;
        if (habit['date'] == selectedDateStr) {
          habit['id'] = entry.key;
          habit['type'] = 'habit';
          activities.add(Map<String, dynamic>.from(habit));
        }
      }
    }

    return activities;
  }

  IconData getIcon(String type) {
    switch (type) {
      case 'habit':
        return Icons.self_improvement;
      case 'recurring':
        return Icons.repeat;
      case 'task':
      default:
        return Icons.task_alt;
    }
  }

  String getTypeLabel(String type) {
    switch (type) {
      case 'habit':
        return 'Habit';
      case 'recurring':
        return 'Recurring Task';
      case 'task':
      default:
        return 'Task';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          TableCalendar(
            focusedDay: selectedDay,
            firstDay: DateTime.utc(2020),
            lastDay: DateTime.utc(2100),
            startingDayOfWeek: StartingDayOfWeek.monday,
            headerVisible: false,
            calendarFormat: CalendarFormat.week,
            availableGestures: AvailableGestures.horizontalSwipe,
            selectedDayPredicate: (day) => isSameDay(day, selectedDay),
            onDaySelected: (selected, focused) {
              setState(() {
                selectedDay = selected;
              });
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.green.shade300,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Appcolors.subtheme,
                shape: BoxShape.circle,
              ),
              weekendTextStyle: const TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 10),

          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchAllActivities(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final activities = snapshot.data ?? [];

                if (activities.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_busy, size: 80, color: Appcolors.subtheme),
                        const SizedBox(height: 10),
                        const Text(
                          "There is nothing scheduled",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        const Text("Try adding new activities",
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: activities.length,
                  itemBuilder: (_, index) {
                    final item = activities[index];
                    final title = item['title'] ?? item['habitName'] ?? 'Untitled';
                    final type = item['type'] ?? 'task';

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Appcolors.subtheme.withOpacity(0.15),
                        child: Icon(getIcon(type), color: Appcolors.subtheme),
                      ),
                      title: Text(title, style: TextStyle(color: Theme.of(context).primaryColorLight)),
                      subtitle: Text(getTypeLabel(type),
                          style: TextStyle(color: Appcolors.subtheme, fontSize: 12)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () async {
                          if (type == 'habit') {
                            await db.ref('users/$userId/habits/${item['id']}').remove();
                          } else {
                            await firestore.collection('scheduled').doc(item['id']).delete();
                          }
                          setState(() {});
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => ActivityTypePage()));
        },
        child: const Icon(Icons.add),
        backgroundColor: Appcolors.subtheme,
      ),
    );
  }
}
