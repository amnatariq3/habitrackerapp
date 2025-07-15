import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:table_calendar/table_calendar.dart';

import 'Color Compound class.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: widget.initialTabIndex);
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
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _editItem("Habit name", habit['habitName'], Icons.edit),
        _editItem("Category", "Quit a bad habit", Icons.block, color: Colors.red),
        _editItem("Description", habit['description'] ?? "-", Icons.info),
        _editItem("Time and reminders", "0", Icons.notifications),
        _editItem("Priority", "Default", Icons.flag),
        _editItem("Frequency", habit['frequency'], Icons.calendar_today),
        _editItem("Start date", "7/9/25", Icons.date_range),
        _editItem("End date", "-", Icons.event_busy),
        _editItem("Archive", "", Icons.download),
        _editItem("Restart habit progress", "", Icons.refresh),
        _editItem("Delete habit", "", Icons.delete, color: Colors.red),
      ],
    );
  }

  Widget _editItem(String title, String value, IconData icon, {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? Appcolors.theme),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: Text(value, style: TextStyle(color: color ?? Colors.white)),
      onTap: () async {
        if (title == "Delete habit") {
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
            final ref = FirebaseDatabase.instance.ref("users/${FirebaseAuth.instance.currentUser!.uid}/habits/${widget.habitId}");
            await ref.remove();
            Navigator.pop(context);
          }
        }
      },
    );
  }
}
