import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'Activity type page.dart';
import 'calendar page.dart';
import 'Color Compound class.dart';

class TodayPage extends StatefulWidget {
  const TodayPage({super.key});

  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {
  final firestore = FirebaseFirestore.instance;
  late String userId;

  DateTime selectedDay = DateTime.now();
  String get selectedDateStr => DateFormat('yyyy-MM-dd').format(selectedDay);

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userId = user.uid;
    } else {
      // If unauthenticated, redirect to login or show message
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginPage()));
    }
  }

  Future<List<QueryDocumentSnapshot>> fetchTasks() async {
    final query = await firestore
        .collection('scheduled')
        .where('userId', isEqualTo: userId)
        .where('startDate', isGreaterThanOrEqualTo: selectedDateStr)
        .get();
    return query.docs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

          const SizedBox(height: 20),

          Expanded(
            child: FutureBuilder<List<QueryDocumentSnapshot>>(
              future: fetchTasks(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data ?? [];

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_today, size: 60, color: Appcolors.subtheme),
                        const SizedBox(height: 12),
                        const Text("There is nothing scheduled",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        const Text("Try adding new activities", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (_, i) {
                    final doc = docs[i];
                    final title = doc['title'] ?? 'Untitled';
                    final priority = doc['priority'] ?? 'Default';

                    return ListTile(
                      title: Text(title),
                      subtitle: Text("Priority: $priority"),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async {
                          await firestore.collection('scheduled').doc(doc.id).delete();
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
