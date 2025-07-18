import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

import 'Color Compound class.dart';

class contactusPage extends StatefulWidget {
  const contactusPage({super.key});

  @override
  State<contactusPage> createState() => _contactusPageState();
}

class _contactusPageState extends State<contactusPage> {
  @override
  void initState() {
    super.initState();
    // Show the alert dialog as soon as the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showContactDialog(context);
    });
  }

  void _logUserAction(String action) async {
    await FirebaseFirestore.instance.collection('contact_actions').add({
      'action': action,
      'timestamp': Timestamp.now(),
    });
  }

  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black87,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Contact us',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildOption(context, 'CONTACT SUPPORT'),
              _buildOption(context, 'SEND SUGGESTIONS'),
              _buildOption(context, 'REPORT A BUG'),
              _buildOption(context, 'REMINDERS ARE NOT WORKING'),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Text(
                  'CLOSE',
                  style: TextStyle(
                    color: Appcolors.subtheme,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOption(BuildContext context, String text) {
    return ListTile(
        title: Text(
          text,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        onTap: () {
          _logUserAction(text);
          Navigator.pop(context); // Close the main dialog

          // Show the correct dialog based on the tapped text
          if (text == 'CONTACT SUPPORT') {
            showcontactsupportDialog(context);
          } else if (text == 'SEND SUGGESTIONS') {
            showsendsuggestionDialog(context);
          } else if (text == 'REPORT A BUG') {
            showReportdebugDialog(context);
          } else if (text == 'REMINDERS ARE NOT WORKING') {
            showReminderWarningDialog(context);
          }
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    final isDark= Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: const SizedBox.shrink(), // Empty body since dialog handles everything
    );
  }
}

void showcontactsupportDialog(BuildContext context) {
  final TextEditingController controller = TextEditingController();
  final isDark = Theme
      .of(context)
      .brightness == Brightness.dark;
  showDialog(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        backgroundColor: isDark ? Colors.black : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Contact support",
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          maxLines: 4,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Write your comments here",
            hintStyle: TextStyle(color: Colors.white70),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.purple),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.purple),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("CANCEL", style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () async {
              final feedback = controller.text.trim();
              if (feedback.isEmpty) return;

              final user = FirebaseAuth.instance.currentUser;
              if (user == null) return;

              final userId = user.uid;
              final timestamp = DateTime.now().toIso8601String();

              final feedbackRef = FirebaseDatabase.instance
                  .ref("users/$userId/feedbacks")
                  .push();

              await feedbackRef.set({
                'message': feedback,
                'timestamp': timestamp,
                'email': user.email ?? "unknown",
              });

              Navigator.pop(ctx);

              final Uri emailUri = Uri(
                scheme: 'mailto',
                path: 'support@example.com', // CHANGE to your support email
                query: Uri.encodeFull(
                    'subject=Feedback from HabitNow App&body=$feedback'),
              );

              if (await canLaunchUrl(emailUri)) {
                await launchUrl(emailUri);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Could not open email app")),
                );
              }
            },
            child: const Text("SEND", style: TextStyle(color: Colors.purple)),
          ),
        ],
      );
    },
  );
}

void showsendsuggestionDialog(BuildContext context) {
  final TextEditingController controller = TextEditingController();
  final isDark = Theme
      .of(context)
      .brightness == Brightness.dark;
  showDialog(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        backgroundColor: isDark ? Colors.black : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Send Suggestion",
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          maxLines: 4,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Write your comments here",
            hintStyle: TextStyle(color: Colors.white70),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.purple),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.purple),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("CANCEL", style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () async {
              final feedback = controller.text.trim();
              if (feedback.isEmpty) return;

              final user = FirebaseAuth.instance.currentUser;
              if (user == null) return;

              final userId = user.uid;
              final timestamp = DateTime.now().toIso8601String();

              final feedbackRef = FirebaseDatabase.instance
                  .ref("users/$userId/feedbacks")
                  .push();

              await feedbackRef.set({
                'message': feedback,
                'timestamp': timestamp,
                'email': user.email ?? "unknown",
              });

              Navigator.pop(ctx);

              final Uri emailUri = Uri(
                scheme: 'mailto',
                path: 'support@example.com', // CHANGE to your support email
                query: Uri.encodeFull(
                    'subject=Feedback from HabitNow App&body=$feedback'),
              );

              if (await canLaunchUrl(emailUri)) {
                await launchUrl(emailUri);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Could not open email app")),
                );
              }
            },
            child: const Text("SEND", style: TextStyle(color: Colors.purple)),
          ),
        ],
      );
    },
  );
}

void showReportdebugDialog(BuildContext context) {
  final TextEditingController controller = TextEditingController();
  final isDark = Theme
      .of(context)
      .brightness == Brightness.dark;
  showDialog(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        backgroundColor: isDark ? Colors.black : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Report a debug",
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          maxLines: 4,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Write your comments here",
            hintStyle: TextStyle(color: Colors.white70),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.purple),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.purple),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("CANCEL", style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () async {
              final feedback = controller.text.trim();
              if (feedback.isEmpty) return;

              final user = FirebaseAuth.instance.currentUser;
              if (user == null) return;

              final userId = user.uid;
              final timestamp = DateTime.now().toIso8601String();

              final feedbackRef = FirebaseDatabase.instance
                  .ref("users/$userId/feedbacks")
                  .push();

              await feedbackRef.set({
                'message': feedback,
                'timestamp': timestamp,
                'email': user.email ?? "unknown",
              });

              Navigator.pop(ctx);

              final Uri emailUri = Uri(
                scheme: 'mailto',
                path: 'support@example.com', // CHANGE to your support email
                query: Uri.encodeFull(
                    'subject=Feedback from HabitNow App&body=$feedback'),
              );

              if (await canLaunchUrl(emailUri)) {
                await launchUrl(emailUri);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Could not open email app")),
                );
              }
            },
            child: const Text("SEND", style: TextStyle(color: Colors.purple)),
          ),
        ],
      );
    },
  );
}
void showReminderWarningDialog(BuildContext context) {
  showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.notifications_active_rounded,
                  size: 60, color: Colors.orange),
              const SizedBox(height: 20),
              const Text(
                "Notice about reminders",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                "Your device has an integrated battery optimizer that could disable scheduled alarms and notifications.",
                style: TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                "Make sure that HabitNow is excluded from your optimizer to ensure the correct execution of the reminders.",
                style: TextStyle(color: Colors.white60),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.purpleAccent,
                  elevation: 0,
                ),
                child: const Text(
                  "GOT IT!",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              )
            ],
          ),
        );
       },
      );
}