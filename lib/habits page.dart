import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'Activity type page.dart';
import 'Archieved habit page.dart';
import 'Color Compound class.dart';
import 'habit page detailed screen.dart';
bool isHabitArchived(dynamic value) {
  try {
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
  } catch (_) {
    return false;
  }
  return false;
}



class HabitsPage extends StatefulWidget {
  const HabitsPage({super.key});

  @override
  State<HabitsPage> createState() => _HabitsPageState();
}

class _HabitsPageState extends State<HabitsPage> {
  late final DatabaseReference habitsRef;
  late final String userId;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    userId = user.uid;
    habitsRef = FirebaseDatabase.instance.ref("users/$userId/habits");
  }

  void _showHabitOptions(Map habit, String habitId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) =>
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(habit['habitName'],
                    style: const TextStyle(color: Colors.white)),
                subtitle: Text(habit['frequency'],
                    style: const TextStyle(color: Colors.redAccent)),
                trailing: const Icon(Icons.block, color: Colors.red),
              ),
              ListTile(
                leading: const Icon(
                    Icons.calendar_today_outlined, color: Colors.white),
                title: const Text(
                    'Calendar', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          HabitDetailScreen(
                            habitData: habit,
                            habitId: habitId,
                            initialTabIndex: 0,
                          ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.bar_chart, color: Colors.white),
                title: const Text(
                    'Statistics', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          HabitDetailScreen(
                            habitData: habit,
                            habitId: habitId,
                            initialTabIndex: 1,
                          ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.white),
                title: const Text(
                    'Edit', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          HabitDetailScreen(
                            habitData: habit,
                            habitId: habitId,
                            initialTabIndex: 2,
                          ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.download, color: Colors.white),
                title: const Text(
                    'Archive', style: TextStyle(color: Colors.white)),
                onTap: () async {
                  Navigator.pop(ctx);
                  await habitsRef.child(habitId).update({'isArchived': 1});
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.white),
                title: const Text(
                    'Delete', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(ctx);
                  habitsRef.child(habitId).remove();
                },
              ),
            ],
          ),
    );
  }

  Widget buildHabitCard(Map habit, String habitId) {
    final today = DateTime.now();
    final last7 = List<bool>.from(habit['last7'] ?? List.filled(7, false));
    final chain = habit['chain'] ?? 0;
    final doneCount = last7
        .where((done) => done)
        .length;
    final pct = last7.isNotEmpty ? (doneCount * 100 ~/ last7.length) : 0;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(habit['habitName'], style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 4, horizontal: 8),
                  decoration: BoxDecoration(color: Colors.red[900],
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(habit['frequency'], style: const TextStyle(
                      color: Colors.white70, fontSize: 12)),
                ),
                IconButton(
                    icon: const Icon(Icons.more_vert, color: Colors.white70),
                    onPressed: () => _showHabitOptions(habit, habitId)),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 7,
                itemBuilder: (ctx, i) {
                  final day = today.subtract(Duration(days: 6 - i));
                  final val = last7[i];
                  Color bg;
                  if (val)
                    bg = Colors.green;
                  else if (!val && day.isBefore(
                      DateTime(today.year, today.month, today.day)))
                    bg = Colors.red;
                  else if (DateUtils.dateOnly(day) == DateUtils.dateOnly(today))
                    bg = Colors.yellow;
                  else
                    bg = Colors.grey;
                  return Container(
                    width: 48,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                        color: bg, shape: BoxShape.circle),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text([
                          "Sun",
                          "Mon",
                          "Tue",
                          "Wed",
                          "Thu",
                          "Fri",
                          "Sat"
                        ][day.weekday % 7], style: const TextStyle(
                            color: Colors.white70, fontSize: 10)),
                        Text('${day.day}', style: const TextStyle(
                            color: Colors.white, fontSize: 16)),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.link, color: Colors.red),
                    const SizedBox(width: 4),
                    Text('$chain', style: const TextStyle(color: Colors.white)),
                    const SizedBox(width: 12),
                    const Icon(Icons.check_circle, color: Colors.red),
                    const SizedBox(width: 4),
                    Text('$pct%', style: const TextStyle(color: Colors.white)),
                  ],
                ),
                IconButton(icon: const Icon(
                    Icons.calendar_today_outlined, color: Colors.white70),
                    onPressed: () => _showHabitOptions(habit, habitId)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _noHabitsView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("No active habits found",
              style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () {
              final userId = FirebaseAuth.instance.currentUser?.uid;
              if (userId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ArchivedHabitsPage(userId: userId),
                  ),
                );
              }
            },
            icon: const Icon(Icons.unarchive, color: Colors.white),
            label: const Text("View Archived Habits", style: TextStyle(
                color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme
        .of(context)
        .brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: StreamBuilder(
        stream: habitsRef.onValue,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final val = snap.data?.snapshot.value;
          if (val == null || val is! Map) {
            return _noHabitsView();
          }

          final entries = val.entries.where((e) {
            if (e.value is! Map) return false;
            final habit = Map<String, dynamic>.from(e.value);
            return !isHabitArchived(habit['isArchived']);
          }).toList();

          if (entries.isEmpty) {
            return _noHabitsView();
          }

          return ListView.builder(
            itemCount: entries.length,
            itemBuilder: (c, i) {
              final id = entries[i].key;
              final habit = Map<String, dynamic>.from(entries[i].value);
              return buildHabitCard(habit, id);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Appcolors.subtheme,
        onPressed: () =>
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ActivityTypePage()),
            ),
        child: const Icon(Icons.add),
      ),
    );
  }
}