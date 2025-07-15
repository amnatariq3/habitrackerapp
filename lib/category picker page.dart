import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'color compound class.dart';

class CategoryPickerPage extends StatefulWidget {
  final String userId;
  final String? categoryId;
  final String? initialName;
  final IconData? initialIcon;
  final Color? initialColor;
  final Map<String, dynamic>? existingCategory;

  const CategoryPickerPage({
    super.key,
    required this.userId,
    this.categoryId,
    this.initialName,
    this.initialIcon,
    this.initialColor,
    this.existingCategory,
  });

  @override
  State<CategoryPickerPage> createState() => _CategoryPickerPageState();
}

class _CategoryPickerPageState extends State<CategoryPickerPage> {
  final _nameCtrl = TextEditingController();
  IconData? _selectedIcon;
  Color _selectedColor = Colors.pinkAccent;
  bool isEditing = false;

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
    Icons.flight,
    Icons.music_note,
    Icons.directions_walk,
    Icons.movie,
    Icons.shopping_cart,
    Icons.wb_sunny,
    Icons.favorite,
    Icons.nightlight,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialName != null) {
      isEditing = true;
      _nameCtrl.text = widget.initialName!;
      _selectedIcon = widget.initialIcon;
      _selectedColor = widget.initialColor ?? Appcolors.subtheme;
    }
  }

  Future<void> _saveCategory() async {
    if (_nameCtrl.text.trim().isEmpty || _selectedIcon == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name & Icon are required')),
      );
      return;
    }

    final ref = FirebaseDatabase.instance.ref("users/${widget.userId}/categories");
    final data = {
      'name': _nameCtrl.text.trim(),
      'icon': _selectedIcon!.codePoint,
      'iconFont': _selectedIcon!.fontFamily,
      'color': _selectedColor.value,
    };

    try {
      if (isEditing && widget.categoryId != null) {
        await ref.child(widget.categoryId!).update(data);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category updated')),
        );
      } else {
        await ref.push().set(data);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category created')),
        );
      }

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving category: $e')),
      );
    }
  }

  Future<void> _deleteCategory() async {
    if (widget.categoryId == null) return;

    final ref = FirebaseDatabase.instance
        .ref("users/${widget.userId}/categories/${widget.categoryId}");

    await ref.remove();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Category deleted')),
    );

    Navigator.pop(context, true);
  }

  void _openIconPicker() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      builder: (ctx) => GridView.count(
        crossAxisCount: 4,
        padding: const EdgeInsets.all(16),
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
              child: Icon(icon, size: 28, color: Colors.white),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: Text(isEditing ? "Edit Category" : "New Category",
            style: TextStyle(color: Appcolors.subtheme)),
        iconTheme: IconThemeData(color: Appcolors.subtheme),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _deleteCategory,
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.label, color: Colors.white),
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
            title: const Text('Select Icon', style: TextStyle(color: Colors.white)),
            trailing: const Icon(Icons.chevron_right, color: Colors.white),
            onTap: _openIconPicker,
          ),
          const Divider(color: Colors.white12),

          ListTile(
            leading: CircleAvatar(backgroundColor: _selectedColor),
            title: const Text('Select Color', style: TextStyle(color: Colors.white)),
            trailing: const Icon(Icons.chevron_right, color: Colors.white),
            onTap: _openColorPicker,
          ),
          const Divider(color: Colors.white12),

          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: _saveCategory,
            style: ElevatedButton.styleFrom(
              backgroundColor: Appcolors.subtheme,
              minimumSize: const Size(double.infinity, 48),
            ),
            child: Text(
              isEditing ? 'UPDATE CATEGORY' : 'CREATE CATEGORY',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
