import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled7/Color%20Compound%20class.dart';

Future<void> showFeedbackDialog(BuildContext context, String userId) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Do you like HabitNow?",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            SizedBox(height: 20),
            Icon(Icons.favorite, color: Colors.pinkAccent, size: 50),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () {
                    saveFeedback(userId, "not_really");
                    Navigator.pop(context);
                  },
                  child: Text("NOT REALLY", style: TextStyle(color: Colors.white)),
                ),
                TextButton(
                  onPressed: () {
                    saveFeedback(userId, "love_it");
                    Navigator.pop(context);
                  },
                  child: Text("LOVE IT!", style: TextStyle(color: Appcolors.subtheme, fontWeight: FontWeight.bold)),
                ),
              ],
            )
          ],
        ),
      );
    },
  );
}

Future<void> saveFeedback(String userId, String response) async {
  await FirebaseFirestore.instance.collection('feedback').add({
  'userId': userId,
  'response': response,
  'timestamp': Timestamp.now(),
  });
}