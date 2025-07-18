

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:untitled7/Archieved%20habit%20page.dart';
import 'package:untitled7/priority.dart';
import 'package:untitled7/remender%20dialogue.dart';
import 'Color Compound class.dart';
import 'edit habit frequency page.dart';

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


class HabitDetailScreen extends StatefulWidget {
  final Map habitData;
  final String habitId;
  final int initialTabIndex;

  const HabitDetailScreen({
    required this.habitData,
    required this.habitId,
    this.initialTabIndex = 0,
    super.key,
  });

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late DatabaseReference habitRef;
  late String userId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: widget.initialTabIndex);
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userId = user.uid;
      habitRef = FirebaseDatabase.instance.ref("users/$userId/habits/${widget.habitId}");
    }
  }

  Future<void> _updateField(String key, dynamic value) async {
    await habitRef.update({key: value});
    setState(() {
      widget.habitData[key] = value;
    });
  }

  Future<void> _selectDate({required bool isStart}) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      final key = isStart ? 'startDate' : 'endDate';
      _updateField(key, picked.toIso8601String());
    }
  }

  Future<void> _editTextField(String title, String key, String currentValue) async {
    final controller = TextEditingController(text: currentValue);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: Text("Edit $title", style: const TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(hintText: "Enter $title", hintStyle: const TextStyle(color: Colors.grey)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL", style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text("SAVE", style: TextStyle(color: Colors.lightGreenAccent)),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      _updateField(key, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final habit = widget.habitData;
    return Scaffold(
      appBar: AppBar(title: Text(habit['habitName'] ?? 'Habit Detail')),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.calendar_today), text: 'Calendar'),
              Tab(icon: Icon(Icons.bar_chart), text: 'Stats'),
              Tab(icon: Icon(Icons.edit), text: 'Edit'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _calendarTab(),
                _statisticsTab(habit),
                _editTab(habit),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _calendarTab() {
    final List<bool> last7 = List<bool>.from(widget.habitData['last7'] ?? List.filled(7, false));
    final today = DateTime.now();
    final Map<DateTime, bool> habitDays = {};

    for (int i = 0; i < last7.length; i++) {
      final date = DateTime(today.year, today.month, today.day).subtract(Duration(days: 6 - i));
      habitDays[date] = last7[i];
    }

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: TableCalendar(
        firstDay: DateTime.utc(2020),
        lastDay: DateTime.utc(2030),
        focusedDay: today,
        calendarStyle: const CalendarStyle(
          todayDecoration: BoxDecoration(color: Colors.yellow, shape: BoxShape.circle),
          selectedDecoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle),
          markerDecoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
          weekendTextStyle: TextStyle(color: Colors.grey),
          defaultTextStyle: TextStyle(color: Colors.white),
        ),
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            if (habitDays.containsKey(day)) {
              final done = habitDays[day]!;
              return Container(
                decoration: BoxDecoration(
                  color: done ? Colors.green : Colors.red,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${day.day}',
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }
            return null;
          },
        ),
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(color: Colors.white),
          leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
          rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
        ),
        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(color: Colors.white),
          weekendStyle: TextStyle(color: Colors.redAccent),
        ),
      ),
    );
  }

  Widget _statisticsTab(Map habit) {
    final last7 = List<bool>.from(habit['last7'] ?? List.filled(7, false));
    final score = (last7.where((e) => e).length / 7) * 100;
    final chain = habit['chain'] ?? 0;
    final best = habit['bestChain'] ?? 2;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CircularPercentIndicator(
            radius: 70,
            lineWidth: 10,
            percent: score / 100,
            animation: true,
            center: Text("${score.toInt()}", style: const TextStyle(color: Colors.white, fontSize: 24)),
            progressColor: Appcolors.theme,
            backgroundColor: Colors.grey.shade800,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _statBox("Current", "$chain DAYS", Icons.link),
              _statBox("Best", "$best DAYS", Icons.emoji_events),
            ],
          ),
          const SizedBox(height: 16),
          _completionStats(),
        ],
      ),
    );
  }

  Widget _statBox(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Appcolors.theme),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(color: Colors.grey)),
        Text(value, style: TextStyle(color: Appcolors.theme, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _completionStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Times completed", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        _statRow("This week", "1"),
        _statRow("This month", "2"),
        _statRow("This year", "2"),
        _statRow("All", "2"),
      ],
    );
  }

  static Widget _statRow(String label, String count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Text(count, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _editTab(Map habit) {
    final archived = isHabitArchived(widget.habitData['isArchived']);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _editItem("Habit name", habit['habitName'], Icons.edit, onTap: () => _editTextField("Habit Name", "habitName", habit['habitName'])),
        _editItem("Category", habit['category'] ?? "-", Icons.category, onTap: () => _editTextField("Category", "category", habit['category'] ?? "")),
        _editItem("Description", habit['description'] ?? "-", Icons.info, onTap: () => _editTextField("Description", "description", habit['description'] ?? "")),
        _editItem("Time and reminders", "Set reminders", Icons.notifications, onTap:()=>openReminderDialog(context) ),
        _editItem("Priority", habit['priority'] ?? "Default", Icons.flag,onTap: ()=>showPriorityDialog(context)),
        _editItem("Frequency", habit['frequency'], Icons.calendar_today,onTap:(){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>EditFrequencypage( habitName: habit['habitName'] ?? '',
            description: habit['description'] ?? '',
            habitId: widget.habitId,)));
        }),
        _editItem("Start date", habit['startDate'] ?? "Tap to set", Icons.date_range, onTap: () => _selectDate(isStart: true)),
        _editItem("End date", habit['endDate'] ?? "Tap to set", Icons.event_busy, onTap: () => _selectDate(isStart: false)),
        _editItem(
          archived ? "Unarchive" : "Archive",
          "",
          Icons.download,
          onTap: () async {
            final confirm = await showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: Text(archived ? "Unarchive Habit" : "Archive Habit"),
                content: Text(
                  archived ? "Do you want to move this habit back to active habits?" : "Do you want to archive this habit?",
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(archived ? "Unarchive" : "Archive"),
                  ),
                ],
              ),
            );

            if (confirm == true) {
              await habitRef.update({"isArchived": archived ? 0 : 1});
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(archived ? "Habit unarchived" : "Habit archived")),
              );
              Navigator.pop(context);
            }
          },
        ),
        _editItem("Delete habit", "", Icons.delete, color: Colors.red, onTap: () async {
          final confirm = await showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("Delete Habit"),
              content: const Text("Are you sure you want to delete this habit permanently?"),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
                TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
              ],
            ),
          );
          if (confirm == true) {
            await habitRef.remove();
            Navigator.pop(context);
          }
        }),
      ],
    );
  }

  Widget _editItem(String title, String value, IconData icon, {Color? color, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: color ?? Appcolors.subtheme),
      title: Text(title, style: const TextStyle(color: Colors.lightGreenAccent)),
      trailing: Text(value, style: TextStyle(color: color ?? Colors.white70)),
      onTap: onTap,
    );
  }
}
