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

    // Fetch habits
    final habitSnap = await db.ref('users/$userId/habits').get();
    if (habitSnap.exists) {
      final map = habitSnap.value as Map;
      for (var entry in map.entries) {
        final habit = Map<String, dynamic>.from(entry.value);
        if (habit['date'] == selectedDateStr) {
          habit['id'] = entry.key;
          habit['type'] = 'habit';
          activities.add(habit);
        }
      }
    }

    // Fetch single tasks
    final singleSnap = await db.ref('users/$userId/singleTasks').get();
    if (singleSnap.exists) {
      final map = singleSnap.value as Map;
      for (var entry in map.entries) {
        final task = Map<String, dynamic>.from(entry.value);
        if (task['date'] == selectedDateStr) {
          task['id'] = entry.key;
          task['type'] = 'single';
          activities.add(task);
        }
      }
    }

    // Fetch recurring tasks
    final recurSnap = await db.ref('users/$userId/recurringTasks').get();
    if (recurSnap.exists) {
      final map = recurSnap.value as Map;
      for (var entry in map.entries) {
        final task = Map<String, dynamic>.from(entry.value);
        if (task['date'] == selectedDateStr) {
          task['id'] = entry.key;
          task['type'] = 'recurring';
          activities.add(task);
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
      case 'single':
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
      case 'single':
      default:
        return 'Single Task';
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
            calendarFormat: CalendarFormat.week,
            startingDayOfWeek: StartingDayOfWeek.monday,
            selectedDayPredicate: (day) => isSameDay(day, selectedDay),
            onDaySelected: (selected, focused) {
              setState(() => selectedDay = selected);
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
            ),
            headerVisible: false,
            availableGestures: AvailableGestures.horizontalSwipe,
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
                        const Text("There is nothing scheduled",
                            style: TextStyle(fontWeight: FontWeight.bold)),
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
                    final title = item['habitName'] ?? item['task'] ?? 'Untitled';
                    final type = item['type'];

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
                          await db.ref('users/$userId/${type == 'habit' ? 'habits' : type == 'recurring' ? 'recurringTasks' : 'singleTasks'}/${item['id']}').remove();
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
