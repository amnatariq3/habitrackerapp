import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';

import 'Bottom Navigation Bar.dart';
import 'auth wraper page.dart';
import 'firebase_options.dart';
import 'onboarding screen.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Web Initialization
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
    // Mobile initialization
    await Firebase.initializeApp();
  }

  // Hive init
  await Hive.initFlutter();
  await Hive.openBox('habitBox');

  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Habit Tracker',
      theme: ThemeData(primarySwatch: Colors.orange),
      home: const AuthWrapper(), // or use AuthWrapper if needed
    );
  }
}
