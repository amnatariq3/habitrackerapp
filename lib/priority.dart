import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'Color Compound class.dart'; // Appcolors.subtheme & Appcolors.theme

void showPriorityDialog(BuildContext context) async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("You must be logged in to set priority")),
    );
    return;
  }

  final userId = user.uid;
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref("users/$userId/priority");

  // 🟡 Step 1: Get saved priority first
  int currentPriority = 1;
  final DataSnapshot snapshot = await dbRef.get();
  if (snapshot.exists && snapshot.value is Map) {
    final value = (snapshot.value as Map)['value'];
    if (value is int) currentPriority = value;
  }

  // 🟢 Step 2: Show dialog
  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: const Text("Set a priority", style: TextStyle(color: Colors.white)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, color: Colors.white),
                      onPressed: () {
                        if (currentPriority > 1) {
                          setState(() => currentPriority--);
                        }
                      },
                    ),
                    Text(
                      '$currentPriority',
                      style: TextStyle(color: Appcolors.theme, fontSize: 32),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, color: Colors.white),
                      onPressed: () {
                        if (currentPriority < 10) {
                          setState(() => currentPriority++);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text("Default - $currentPriority", style: TextStyle(color: Appcolors.theme)),
                const SizedBox(height: 10),
                Text(
                  "Higher priority activities will be displayed\nhigher in the list",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[300], fontSize: 12),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("CLOSE", style: TextStyle(color: Colors.white)),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    await dbRef.set({"value": currentPriority});
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Priority $currentPriority saved")),
                    );
                  } catch (e) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error saving: $e")),
                    );
                  }
                },
                child: Text("OK", style: TextStyle(color: Appcolors.theme)),
              ),
            ],
          );
        },
      );
    },
  );
}
