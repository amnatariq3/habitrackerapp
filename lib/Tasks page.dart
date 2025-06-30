import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _userId;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userId = user.uid;
    } else {
      debugPrint("⚠️ No user logged in.");
      // Optionally: redirect to login
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _addTask() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _userId == null) return;
    await _firestore.collection('tasks').add({
      'userId': _userId,
      'title': text,
      'completed': false,
      'createdAt': Timestamp.now(),
    });
    _controller.clear(); // No setState needed — StreamBuilder updates
  }

  Future<void> _deleteTask(DocumentSnapshot doc) async {
    await _firestore.collection('tasks').doc(doc.id).delete();
  }

  Future<void> _toggleComplete(DocumentSnapshot doc) async {
    await _firestore.collection('tasks').doc(doc.id).update({
      'completed': !(doc['completed'] as bool),
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_userId == null) {
      return const Scaffold(
        body: Center(child: Text("Please login to view your tasks.")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Tasks")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "New Task",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addTask,
                ),
              ),
              onSubmitted: (_) => _addTask(),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('tasks')
                  .where('userId', isEqualTo: _userId)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No tasks yet."));
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (_, i) {
                    final doc = docs[i];
                    return ListTile(
                      title: Text(doc['title']),
                      leading: Checkbox(
                        value: doc['completed'],
                        onChanged: (_) => _toggleComplete(doc),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _deleteTask(doc),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
