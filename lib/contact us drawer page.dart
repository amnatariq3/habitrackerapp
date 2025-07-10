import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    ).then((_) {
      // Automatically pop the page after dialog is closed
      Navigator.of(context).pop();
    });
  }

  Widget _buildOption(BuildContext context, String text) {
    return ListTile(
      title: Text(
        text,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
      onTap: () {
        _logUserAction(text);
        Navigator.pop(context); // Close dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$text selected and saved!')),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox.shrink(), // Empty body since dialog handles everything
    );
  }
}
