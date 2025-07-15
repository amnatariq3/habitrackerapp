import 'package:flutter/material.dart';
import 'Next Numerichabitpage.dart';
import 'color compound class.dart'; // Appcolors.theme & Appcolors.subtheme

class NumericHabitPage extends StatefulWidget {
  const NumericHabitPage({super.key});

  @override
  State<NumericHabitPage> createState() => _NumericHabitPageState();
}

class _NumericHabitPageState extends State<NumericHabitPage> {
  /* ────────── controllers / state ────────── */
  final _habitCtrl       = TextEditingController();
  final _goalCtrl        = TextEditingController();
  final _unitCtrl        = TextEditingController();
  final _descCtrl        = TextEditingController();

  final List<String> _goalTypes = ['At least', 'At most', 'Exactly', 'No goal'];
  String _selectedGoalType = 'At least';

  int _extraGoals = 0; // you can manage a list later

  /* ────────── helpers ────────── */
  void _saveAndNext() {
    if (_habitCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Habit name is required')),
      );
      return;
    }

    // TODO: Persist or pass data to next step
    print('Habit: ${_habitCtrl.text}');
    print('GoalType: $_selectedGoalType');
    print('Goal value: ${_goalCtrl.text}');
    print('Unit: ${_unitCtrl.text}');
    print('Desc: ${_descCtrl.text}');
    print('Extra goals: $_extraGoals');

    // Navigator.push(context, MaterialPageRoute(builder: (_) => NextPage()));
  }

  @override
  void dispose() {
    _habitCtrl.dispose();
    _goalCtrl.dispose();
    _unitCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  /* ────────── UI ────────── */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
        body: SafeArea(
        child: SingleChildScrollView( // ✅ Add this
        child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min, // ✅ Prevents full expansion
    children: [
    const SizedBox(height: 20),
    Center(
    child: Text(
    'Define your habit',
    style: TextStyle(
    fontSize: 20,
    color: Appcolors.subtheme,
    fontWeight: FontWeight.bold,
    ),
    ),
    ),
    const SizedBox(height: 30),
    // All your existing widgets...
    // at the end of Column, REMOVE Spacer
    const SizedBox(height: 30), // optional spacing instead of Spacer
    Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
    TextButton(
    onPressed: () => Navigator.pop(context),
    child: const Text('BACK', style: TextStyle(color: Colors.white70)),
    ),
    Row(
    children: List.generate(4, (i) {
    return Container(
    margin: const EdgeInsets.symmetric(horizontal: 3),
    width: 8,
    height: 8,
    decoration: BoxDecoration(
    shape: BoxShape.circle,
    color: i == 2
    ? Appcolors.subtheme
        : Appcolors.subtheme.withOpacity(0.3),
    ),
    );
    }),
    ),
    TextButton(
    onPressed: () {
    Navigator.push(context, MaterialPageRoute(
    builder: (context) => DefineNumericHabitPage(),
    ));
    },
    child: Text('NEXT', style: TextStyle(color: Appcolors.subtheme)),
    ),
    ],
    ),
    ],
    ),
    ),
    ),
    ),
    );

  }

  // ───────────────── helper widgets ─────────────────
  Widget _outlinedField(
      TextEditingController ctrl, {
        required String hint,
        TextInputType keyboard = TextInputType.text,
        int maxLines = 1,
      }) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboard,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Appcolors.subtheme),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Appcolors.subtheme, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _dropdownGoalType() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Appcolors.subtheme),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedGoalType,
          dropdownColor: Colors.grey.shade900,
          iconEnabledColor: Appcolors.subtheme,
          items: _goalTypes
              .map((type) => DropdownMenuItem<String>(
            value: type,
            child: Text(type, style: const TextStyle(color: Colors.white)),
          ))
              .toList(),
          onChanged: (val) =>
              setState(() => _selectedGoalType = val ?? _selectedGoalType),
        ),
      ),
    );
  }
}
