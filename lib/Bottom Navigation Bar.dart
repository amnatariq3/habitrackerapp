import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Import your pages
import 'Setting page.dart';
import 'Todaypage.dart';
import 'habits page.dart';
import 'Tasks page.dart';
import 'categories page.dart';
import 'timer page.dart';
import 'Color Compound class.dart'; // for Appcolors.theme

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    TodayPage(),
    HabitsPage(),
    TasksPage(),
    CategoriesPage(),
    TimerPage(),
    SettingsPage(),
  ];

  final List<String> _titles = [
    'Today',
    'Habits',
    'Tasks',
    'Categories',
    'Timer',
    'Settings',
  ];

  void _onSelectDrawer(int index) {
    if (index >= _screens.length) return; // prevent out-of-range crash
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context); // Close drawer after selection
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        backgroundColor: Appcolors.theme,
      ),

      drawer: Drawer(
        backgroundColor: Colors.black,
        child: ListView(
          children: [
            DrawerHeader(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("HabitNow",
                      style: TextStyle(fontSize: 24, color: Appcolors.theme)),
                  SizedBox(height: 5),
                  Text("Welcome!",
                      style: TextStyle(color: Colors.white70)),
                  Text(
                    FirebaseAuth.instance.currentUser?.email ?? "Guest",
                    style: TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                ],
              ),
            ),
            _drawerItem(Icons.today, 'Today', 0),
            _drawerItem(Icons.star_border, 'Habits', 1),
            _drawerItem(Icons.check_circle_outline, 'Tasks', 2),
            _drawerItem(Icons.grid_view, 'Categories', 3),
            _drawerItem(Icons.timer, 'Timer', 4),
            _drawerItem(Icons.settings, 'Settings', 5),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title: const Text("Logout", style: TextStyle(color: Colors.white)),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                // Optionally navigate to login page
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ],
        ),
      ),

      body: _screens[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex > 4 ? 0 : _selectedIndex,
        onTap: _onBottomNavTap,
        selectedItemColor: Appcolors.theme,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.today), label: 'Today'),
          BottomNavigationBarItem(icon: Icon(Icons.star_border), label: 'Habits'),
          BottomNavigationBarItem(icon: Icon(Icons.check), label: 'Tasks'),
          BottomNavigationBarItem(icon: Icon(Icons.category), label: 'Categories'),
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: 'Timer'),
        ],
      ),
    );
  }

  ListTile _drawerItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      selected: _selectedIndex == index,
      selectedTileColor: Colors.orange.withOpacity(0.3),
      onTap: () => _onSelectDrawer(index),
    );
  }
}
