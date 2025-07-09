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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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

              // ── Habit name ──
              Text('Habit', style: TextStyle(color: Appcolors.subtheme)),
              const SizedBox(height: 6),
              _outlinedField(_habitCtrl, hint: 'e.g., Do not drink alcohol.'),

              const SizedBox(height: 20),

              // ── Goal row: dropdown + numeric ──
              Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: _dropdownGoalType(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 5,
                    child: _outlinedField(
                      _goalCtrl,
                      hint: 'Goal',
                      keyboard: TextInputType.number,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // ── Unit row: optional + static 'a day.' ──
              Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: _outlinedField(
                      _unitCtrl,
                      hint: 'Unit (optional)',
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    flex: 3,
                    child: Text(
                      'a day.',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),
              const Text(
                'e.g., Smoke less than 5 cigarettes a day.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),

              const SizedBox(height: 24),

              // ── Description ──
              _outlinedField(
                _descCtrl,
                hint: 'Description (optional)',
                maxLines: 2,
              ),

              const SizedBox(height: 24),

              // ── Extra goals tile ──
              GestureDetector(
                onTap: () {
                  // TODO: open extra-goal editor
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.power_settings_new,
                          color: Appcolors.subtheme, size: 24),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Text('Extra goals',
                            style: TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Appcolors.subtheme.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$_extraGoals',
                          style: TextStyle(color: Appcolors.subtheme),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // ── Bottom bar (Back + dots + Next) ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('BACK',
                        style: TextStyle(color: Colors.white70)),
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
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>DefineNumericHabitPage()));
                    },
                    child: Text('NEXT',
                        style: TextStyle(color: Appcolors.subtheme)),
                  ),
                ],
              ),
            ],
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
