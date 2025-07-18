import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'Activity type page.dart';
import 'Color Compound class.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> singleTasks = [];
  List<Map<String, dynamic>> recurringTasks = [];
  late String userId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userId = user.uid;
      listenToTasks();
    }
  }

  void listenToTasks() {
    final singleRef = FirebaseDatabase.instance.ref("users/$userId/singleTasks");
    final recurringRef = FirebaseDatabase.instance.ref("users/$userId/recurringTasks");

    singleRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>? ?? {};
      List<Map<String, dynamic>> loaded = [];
      data.forEach((key, value) {
        loaded.add({
          'id': key,
          'task': value['task'] ?? 'Untitled',
          'date': value['date'] ?? '',
          'description': value['description'] ?? '',
        });
      });
      setState(() {
        singleTasks = loaded;
      });
    });

    recurringRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>? ?? {};
      List<Map<String, dynamic>> loaded = [];
      data.forEach((key, value) {
        loaded.add({
          'id': key,
          'task': value['task'] ?? 'Untitled',
          'date': value['date'] ?? '',
          'description': value['description'] ?? '',
        });
      });
      setState(() {
        recurringTasks = loaded;
      });
    });
  }

  Future<void> deleteTask(String id, bool isRecurring) async {
    final path = isRecurring ? 'recurringTasks' : 'singleTasks';
    await FirebaseDatabase.instance.ref("users/$userId/$path/$id").remove();
  }

  Widget buildTaskList(List<Map<String, dynamic>> list, bool isRecurring) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (list.isEmpty) {
      return const Center(
        child: Text("No tasks found", style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (_, index) {
        final task = list[index];
        return Card(
          color: isDark ? Colors.grey[900] : Colors.grey[100],
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            title: Text(
              task['task'],
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              task['description'] ?? '',
              style: const TextStyle(color: Colors.grey),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => deleteTask(task['id'], isRecurring),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Tasks"),
        backgroundColor: Appcolors.theme,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Single Task"),
            Tab(text: "Recurring Task"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildTaskList(singleTasks, false),
          buildTaskList(recurringTasks, true),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) =>  ActivityTypePage()),
          );
        },
        backgroundColor: Appcolors.subtheme,
        child: const Icon(Icons.add),
      ),
    );
  }
}
