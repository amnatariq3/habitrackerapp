import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'color compound class.dart'; // Appcolors.theme / subtheme etc.

class CategoryPickerPage extends StatefulWidget {
  final String? userId;

  const CategoryPickerPage({super.key, this.userId});

  @override
  State<CategoryPickerPage> createState() => _CategoryPickerPageState();
}

class _CategoryPickerPageState extends State<CategoryPickerPage> {
  final _nameCtrl = TextEditingController();
  IconData? _selectedIcon;
  Color _selectedColor = Colors.pinkAccent;

  final _firestore = FirebaseFirestore.instance;

  final List<IconData> _presetIcons = [
    Icons.sports_basketball,
    Icons.book,
    Icons.brush,
    Icons.health_and_safety,
    Icons.timer,
    Icons.school,
    Icons.fitness_center,
    Icons.home,
    Icons.work,
    Icons.fastfood,
  ];

  Future<void> _saveCategory() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category name is required')),
      );
      return;
    }

    final uid = widget.userId ?? FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    try {
      await _firestore.collection('categories').add({
        'userId': uid,
        'name': _nameCtrl.text.trim(),
        'icon': _selectedIcon?.codePoint,
        'iconFont': _selectedIcon?.fontFamily,
        'color': _selectedColor.value,
        'createdAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category created successfully!')),
      );

      Navigator.pop(context); // Go back to the previous screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving category: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Category', style: TextStyle(color: Appcolors.subtheme)),
        backgroundColor: Colors.grey[900],
        iconTheme: IconThemeData(color: Appcolors.subtheme),
      ),
      backgroundColor: Colors.black,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.label_outline, color: Colors.white),
            title: TextField(
              controller: _nameCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Category name',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
            ),
          ),
          const Divider(color: Colors.white12),

          ListTile(
            leading: Icon(_selectedIcon ?? Icons.image_search_outlined, color: Colors.white),
            title: const Text('Category icon', style: TextStyle(color: Colors.white)),
            trailing: const Icon(Icons.chevron_right, color: Colors.white),
            onTap: _openIconPicker,
          ),
          const Divider(color: Colors.white12),

          ListTile(
            leading: CircleAvatar(backgroundColor: _selectedColor),
            title: const Text('Category color', style: TextStyle(color: Colors.white)),
            trailing: const Icon(Icons.chevron_right, color: Colors.white),
            onTap: _openColorPicker,
          ),
          const Divider(color: Colors.white12),

          const SizedBox(height: 40),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Appcolors.subtheme,
              minimumSize: const Size(double.infinity, 48),
            ),
            onPressed: _saveCategory,
            child: const Text(
              'CREATE CATEGORY',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _openIconPicker() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      builder: (ctx) => GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 4,
        children: _presetIcons.map((icon) {
          final isSelected = icon == _selectedIcon;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedIcon = icon);
              Navigator.pop(ctx);
            },
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? Appcolors.subtheme.withOpacity(0.3) : Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 30, color: Colors.white),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _openColorPicker() async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pick a color'),
        content: BlockPicker(
          pickerColor: _selectedColor,
          availableColors: [
            Colors.redAccent,
            Colors.orange,
            Colors.purple,
            Colors.green,
            Colors.blue,
            Colors.pink,
            Colors.cyan,
            Colors.teal,
          ],
          onColorChanged: (c) => setState(() => _selectedColor = c),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }
}
