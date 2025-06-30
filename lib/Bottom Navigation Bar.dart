import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:untitled7/timer%20page.dart';

import 'Color Compound class.dart';
import 'Tasks page.dart';
import 'Todaypage.dart';
import 'auth wraper page.dart';
import 'categories page.dart';
import 'habits page.dart';
import 'login page.dart';
import 'logout page.dart';
class HabitTrackerApp extends StatelessWidget {

  const HabitTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Habit Tracker',
      theme: ThemeData(primarySwatch: Colors.orange),
      home: const AuthWrapper(),
    );
  }
}


class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int currentIndex = 0;

  final pages = const [
    TodayPage(),
    HabitsPage(),
    TasksPage(),
    CategoriesPage(),
    TimerPage(),
  ];

  final labels = ["Today", "Habits", "Tasks", "Categories", "Timer"];

  void _onDrawerTap(int index) {
    setState(() {
      currentIndex = index;
      Navigator.pop(context); // Close the drawer
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(labels[currentIndex]),
      ),

      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.orange),
              child: Text("HabitNow", style: TextStyle(fontSize: 24, color: Colors.white)),
            ),
            _drawerItem(Icons.today, "Today", 0),
            _drawerItem(Icons.star_outline, "Habits", 1),
            _drawerItem(Icons.check_circle_outline, "Tasks", 2),
            _drawerItem(Icons.grid_view, "Categories", 3),
            _drawerItem(Icons.timer_outlined, "Timer", 4),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () async {
                LogoutHelper.confirmLogout(context);


              },
            ),
          ],
        ),
      ),

      body: pages[currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        selectedItemColor: Appcolors.subtheme,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.today), label: "Today"),
          BottomNavigationBarItem(icon: Icon(Icons.star_outline), label: "Habits"),
          BottomNavigationBarItem(icon: Icon(Icons.check_circle_outline), label: "Tasks"),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: "Categories"),
          BottomNavigationBarItem(icon: Icon(Icons.timer_outlined), label: "Timer"),
        ],
      ),
    );
  }

  ListTile _drawerItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(title),
      selected: currentIndex == index,
      selectedTileColor: Colors.orange.withOpacity(0.2),
      onTap: () => _onDrawerTap(index),
    );
  }
}
