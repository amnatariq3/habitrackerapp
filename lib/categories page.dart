import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'category picker page.dart';
import 'color compound class.dart';

class CategoriesPage extends StatefulWidget {
  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  List<Map<String, dynamic>> customCategories = [];
  String userId = '';
  bool isLoading = true;

  final List<Map<String, dynamic>> defaultCategories = [
    {'icon': Icons.block, 'label': 'Quit a bad...'},
    {'icon': Icons.brush, 'label': 'Art'},
    {'icon': Icons.access_time, 'label': 'Task'},
    {'icon': Icons.self_improvement, 'label': 'Meditation'},
    {'icon': Icons.school, 'label': 'Study'},
    {'icon': Icons.sports, 'label': 'Sports'},
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
    final ref = FirebaseDatabase.instance.ref('users/$userId/categories');
    final snapshot = await ref.get();

    final Map? data = snapshot.value as Map?;
    final List<Map<String, dynamic>> loaded = [];

    if (data != null) {
      data.forEach((key, value) {
        loaded.add({
          'id': key,
          'name': value['name'] ?? '',
          'color': Color(value['color'] ?? Colors.grey.value),
          'icon': IconData(
            value['icon'] ?? Icons.category.codePoint,
            fontFamily: value['iconFont'] ?? 'MaterialIcons',
          ),
        });
      });
    }

    setState(() {
      customCategories = loaded;
      isLoading = false;
    });
  }

  void _openCategoryForEdit(Map<String, dynamic> cat) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryPickerPage(
          userId: userId,
          existingCategory: cat,
        ),
      ),
    );
    await _loadCustomCategories();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white70 : Colors.grey[700];
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
                  return GestureDetector(
                    onTap: () => _openCategoryForEdit(cat),
                    child: Chip(
                      label: Text(cat['name']),
                      backgroundColor: cat['color'],
                      labelStyle: const TextStyle(color: Colors.white),
                      avatar: Icon(cat['icon'], size: 18, color: Colors.white),
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 32),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Default categories",
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
                      Icon(cat['icon'], color: textColor, size: 28),
                      const SizedBox(height: 8),
                      Text(
                        cat['label'],
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: textColor),
                      ),
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
              if (result != null) await _loadCustomCategories();
            },
            child: const Text("NEW CATEGORY", style: TextStyle(fontSize: 16)),
          ),
        ),
      ),
    );
  }
}
