import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import 'Customize drawer page.dart';
import 'auth wraper page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase initialization
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDeMUGqXpPZHHtYGVRITmd0pEy_ktG305E",
        authDomain: "habit-tracker-aecb5.firebaseapp.com",
        projectId: "habit-tracker-aecb5",
        storageBucket: "habit-tracker-aecb5.appspot.com",
        messagingSenderId: "400341750100",
        appId: "1:400341750100:web:b0f8be6105ee8e8207b8c1",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  // Load theme preferences
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('darkMode') ?? false;
  final accentString = prefs.getString('accentColor') ?? Colors.pink.value.toString();
  final Color savedAccent = Color(int.parse(accentString));

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AccentColorNotifier()..loadFromValue(accentString)),
      ],
      child: MyApp(isDarkMode: isDark),
    ),
  );
}

class MyApp extends StatefulWidget {
  final bool isDarkMode;
  const MyApp({super.key, required this.isDarkMode});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  void _toggleTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', isDark);
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = Provider.of<AccentColorNotifier>(context).accentColor;

    return MaterialApp(
      title: 'Habit Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: createMaterialColor(accentColor),
        scaffoldBackgroundColor: Colors.white,
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: accentColor,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: createMaterialColor(accentColor),
        scaffoldBackgroundColor: Colors.black,
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: accentColor,
        ),
      ),
      themeMode: _themeMode,
      home: AuthWrapper(
        isDarkMode: _themeMode == ThemeMode.dark,
        onThemeToggle: _toggleTheme,
      ),
    );
  }

  /// Creates MaterialColor from Color
  MaterialColor createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }
}
