import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class CustomizePage extends StatefulWidget {
  const CustomizePage({super.key});

  @override
  State<CustomizePage> createState() => _CustomizePageState();
}

class _CustomizePageState extends State<CustomizePage> {
  String iconStyle = 'Classic';
  final userId = 'user123'; // Replace with FirebaseAuth UID

  final List<Color> accentColors = [
    Colors.pink,
    Colors.orange,
    Colors.cyan,
    Colors.purple,
    Colors.red,
    Colors.orangeAccent,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.deepPurple,
    Colors.pinkAccent,
    Colors.purpleAccent,
    Colors.lime,
    Colors.teal,
    Colors.indigo,
    Colors.brown,
  ];

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future<void> loadSettings() async {
    var doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (doc.exists) {
      var data = doc.data()!;
      iconStyle = data['iconStyle'] ?? 'Classic';

      final accentValue = data['accentColor'];
      if (accentValue != null) {
        final color = Color(int.parse(accentValue));
        Provider.of<AccentColorNotifier>(context, listen: false).updateColor(color);
      }
      setState(() {});
    }
  }

  Future<void> saveSettings(Color color) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      'iconStyle': iconStyle,
      'accentColor': color.value.toString(),
    });
  }

  void selectAccentColor(Color color) {
    Provider.of<AccentColorNotifier>(context, listen: false).updateColor(color);
    saveSettings(color);
  }

  @override
  Widget build(BuildContext context) {
    final selectedAccent = Provider.of<AccentColorNotifier>(context).accentColor;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Customize'),
        backgroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text("Category icon style", style: TextStyle(color: Colors.white70)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ChoiceChip(
                label: const Text("Classic"),
                selected: iconStyle == "Classic",
                onSelected: (val) {
                  setState(() => iconStyle = "Classic");
                  saveSettings(selectedAccent);
                },
              ),
              ChoiceChip(
                label: const Text("Simple"),
                selected: iconStyle == "Simple",
                onSelected: (val) {
                  setState(() => iconStyle = "Simple");
                  saveSettings(selectedAccent);
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text("Accent colors", style: TextStyle(color: Colors.white70)),
          Wrap(
            spacing: 8,
            children: accentColors.map((color) {
              return GestureDetector(
                onTap: () => selectAccentColor(color),
                child: CircleAvatar(
                  backgroundColor: color,
                  child: selectedAccent == color
                      ? const Icon(Icons.check, color: Colors.white)
                      : null,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}



class AccentColorNotifier extends ChangeNotifier {
  Color _accentColor = Colors.pink; // Default

  Color get accentColor => _accentColor;

  void updateColor(Color newColor) {
    _accentColor = newColor;
    notifyListeners();
  }

  void loadFromValue(String colorValue) {
    _accentColor = Color(int.parse(colorValue));
    notifyListeners();
  }
}

