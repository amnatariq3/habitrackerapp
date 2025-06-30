import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HabitsPage extends StatefulWidget {
  const HabitsPage({super.key});

  @override
  _HabitsPageState createState() => _HabitsPageState();
}

class _HabitsPageState extends State<HabitsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _habitController = TextEditingController();
  String? _userId;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userId = user.uid;
    } else {
      debugPrint("⚠️ No user is currently logged in.");
      // Optionally redirect to login page
    }
  }

  @override
  void dispose() {
    _habitController.dispose();
    super.dispose();
  }

  Future<void> _addHabit() async {
    final text = _habitController.text.trim();
    if (text.isEmpty || _userId == null) return;

    await _firestore.collection('habits').add({
      'userId': _userId,
      'habit': text,
      'completed': false,
      'createdAt': Timestamp.now(),
    });

    _habitController.clear();
  }

  Future<void> _deleteHabit(DocumentSnapshot doc) async {
    await _firestore.collection('habits').doc(doc.id).delete();
  }

  Future<void> _toggleCompletion(DocumentSnapshot doc) async {
    await _firestore.collection('habits').doc(doc.id).update({
      'completed': !(doc['completed'] as bool),
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_userId == null) {
      return const Scaffold(
        body: Center(child: Text("Please log in to view your habits.")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Your Habits")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: _habitController,
              decoration: InputDecoration(
                hintText: 'New Habit',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addHabit,
                ),
              ),
              onSubmitted: (_) => _addHabit(),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('habits')
                  .where('userId', isEqualTo: _userId)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No habits yet. Add one above."));
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    return ListTile(
                      title: Text(doc['habit']),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: doc['completed'],
                            onChanged: (_) => _toggleCompletion(doc),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteHabit(doc),
                          ),
                        ],
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
