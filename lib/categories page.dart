import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'category picker page.dart';
import 'color compound class.dart'; // Make sure Appcolors.theme & subtheme are defined

class CategoriesPage extends StatefulWidget {
  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  List<Map<String, dynamic>> customCategories = [];
  String userId = '';
  bool isLoading = true;

  final List<Map<String, dynamic>> defaultCategories = [
    {'icon': Icons.block, 'label': 'Quit a bad...', 'entries': 0},
    {'icon': Icons.brush, 'label': 'Art', 'entries': 0},
    {'icon': Icons.access_time, 'label': 'Task', 'entries': 0},
    {'icon': Icons.self_improvement, 'label': 'Meditati...', 'entries': 0},
    {'icon': Icons.school, 'label': 'Study', 'entries': 0},
    {'icon': Icons.sports, 'label': 'Sports', 'entries': 0},
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userId = user.uid;
      await _loadCustomCategories();
    }
  }

  Future<void> _loadCustomCategories() async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('categories')
          .where('userId', isEqualTo: userId)
          .get();

      final List<Map<String, dynamic>> loaded = query.docs.map((doc) {
        final data = doc.data();
        return {
          'name': data['name'],
          'color': Color(data['color']),
          'icon': IconData(data['icon'], fontFamily: data['iconFont']),
        };
      }).toList();

      setState(() {
        customCategories = loaded;
        isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading categories: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white70 : Colors.grey[700];
    final iconColor = isDark ? Colors.white : Colors.black87;
    final emptyTextColor = isDark ? Colors.white38 : Colors.grey;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Custom categories\n${5 - customCategories.length} available",
                style: TextStyle(color: subTextColor),
              ),
            ),
            const SizedBox(height: 12),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (customCategories.isEmpty)
              Column(
                children: [
                  Icon(Icons.apps, size: 40, color: emptyTextColor),
                  const SizedBox(height: 4),
                  Text(
                    "There are no custom categories",
                    style: TextStyle(color: emptyTextColor),
                  ),
                ],
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: customCategories.map((cat) {
                  return Chip(
                    label: Text(cat['name']),
                    backgroundColor: cat['color'],
                    labelStyle: const TextStyle(color: Colors.white),
                    avatar: Icon(cat['icon'], size: 18, color: Colors.white),
                  );
                }).toList(),
              ),
            const SizedBox(height: 32),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Default categories\nEditable for premium users",
                style: TextStyle(color: subTextColor),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: defaultCategories.map((cat) {
                return Container(
                  width: 100,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Appcolors.subtheme,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Icon(cat['icon'], color: iconColor, size: 28),
                      const SizedBox(height: 8),
                      Text(
                        cat['label'],
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: iconColor),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${cat['entries']} entries",
                        style: TextStyle(color: iconColor.withOpacity(0.6), fontSize: 10),
                      )
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Appcolors.subtheme,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () async {
              if (userId.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("User not logged in")),
                );
                return;
              }
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CategoryPickerPage(userId: userId),
                ),
              );
              // Reload categories if one was added
              if (result != null) await _loadCustomCategories();
            },
            child: const Text("NEW CATEGORY", style: TextStyle(fontSize: 16)),
          ),
        ),
      ),
    );
  }
}
