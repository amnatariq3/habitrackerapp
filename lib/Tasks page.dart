import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:untitled7/color%20compound%20class.dart';
import 'Activity type page.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  final firestore = FirebaseFirestore.instance;
  late String userId;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userId = user.uid;
    }
  }

  Stream<List<QueryDocumentSnapshot>> getTasks(String type) {
    return firestore
        .collection('scheduled')
        .where('userId', isEqualTo: userId)
        .where('type', isEqualTo: type) // "single" or "recurring"
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: TabBar(
                  tabs: const [
                    Tab(text: 'Single tasks'),
                    Tab(text: 'Recurring tasks'),
                  ],
                  indicatorColor: Appcolors.theme,
                  indicatorWeight: 3,
                  labelColor: isDark ? Colors.white : Colors.black,
                  unselectedLabelColor: Colors.grey,
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    TaskList(type: 'single'),
                    TaskList(type: 'recurring'),
                  ],
                ),
              ),
            ],
          ),
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
      ),
    );
  }
}

// ───────── Reusable Task List Widget ─────────
class TaskList extends StatelessWidget {
  final String type; // 'single' or 'recurring'
  const TaskList({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text("You must be logged in."));
    }

    return StreamBuilder<List<QueryDocumentSnapshot>>(
      stream: FirebaseFirestore.instance
          .collection('scheduled')
          .where('userId', isEqualTo: user.uid)
          .where('type', isEqualTo: type)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs),
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
                const Icon(Icons.assignment_rounded, size: 100, color: Colors.blueGrey),
                const SizedBox(height: 20),
                Text(
                  'No ${type == "single" ? "single" : "recurring"} tasks',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'There are no upcoming tasks',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (_, index) {
            final doc = docs[index];
            return ListTile(
              title: Text(doc['title'] ?? 'Untitled Task'),
              subtitle: Text(doc['date'] ?? ''),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection('scheduled')
                      .doc(doc.id)
                      .delete();
                },
              ),
            );
          },
        );
      },
    );
  }
}
