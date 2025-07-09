import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

// Import your pages
import 'Todaypage.dart';
import 'calendar page.dart';
import 'category picker page.dart';
import 'habits page.dart';
import 'Tasks page.dart';
import 'categories page.dart';
import 'timer page.dart';
import 'Setting page.dart';
import 'Color Compound class.dart'; // Make sure this defines Appcolors.theme

class HomeScreen extends StatefulWidget {
  final bool isDarkMode;
  final void Function(bool) onThemeToggle;

  const HomeScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;
  final firestore = FirebaseFirestore.instance;
  late String userId;

  DateTime selectedDay = DateTime.now();
  String get selectedDateStr => DateFormat('yyyy-MM-dd').format(selectedDay);
  @override
  void initState() {
    super.initState();

    // Initialize user ID
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userId = user.uid;
    } else {
      // Handle unauthenticated user
      // You can navigate to login screen or show error
    }

    // Initialize screens
    _screens = [
      TodayPage(),
      HabitsPage(),
      TasksPage(),
      CategoriesPage(),
      TimerPage(),
      SettingsPage(
        isDarkMode: widget.isDarkMode,
        onThemeToggle: widget.onThemeToggle,
      ),
    ];
  }


  final List<String> _titles = [
    'Today',
    'Habits',
    'Tasks',
    'Categories',
    'Timer',
    'Settings',
  ];
  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  /// This function provides different icons for each page
  List<Widget> _getAppBarActions() {
    switch (_selectedIndex) {
      case 0: // Today Page
        return [
          IconButton(icon: Icon(Icons.search), onPressed: () => _showSearchDialog(context),),
          IconButton(icon: Icon(Icons.filter_list),onPressed: () => _showFilterOptionsDialog(context)),
          IconButton(icon: Icon(Icons.calendar_today), onPressed: () async {
            final picked = await showCalendarSheet(context, initialDate: selectedDay);
            if (picked != null) {
              setState(() => selectedDay = picked);
            }
          },),
        ];
      case 1: // Habits Page
        return [
          IconButton(icon: Icon(Icons.search), onPressed: () => _showSearchDialog(context),),
          IconButton(icon: Icon(Icons.filter_list),  onPressed: () => _showFilterOptionsDialog(context),),
          IconButton(icon: Icon(Icons.archive_outlined), onPressed: () =>_showArchiveDialog(context)),
        ];
      case 2: // Tasks Page
        return [
          IconButton(icon: Icon(Icons.search), onPressed: () => _showSearchDialog(context),),
          IconButton(icon: Icon(Icons.filter_list), onPressed: () => _showFilterOptionsDialog(context),),
          IconButton(icon: Icon(Icons.archive_outlined), onPressed: () =>_showArchiveDialog(context)),
        ];
      case 3: // Categories Page
        return [
          IconButton(icon: Icon(Icons.category), onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CategoryPickerPage(userId: userId),
              ),
            );
          }),
        ];
      case 4: // Timer Page
        return [
          IconButton(icon: Icon(Icons.timer), onPressed: () {}),
        ];
      default:
        return [];
    }
  }


  void _onSelectDrawer(int index) {
    if (index >= _screens.length) return;
    setState(() => _selectedIndex = index);
    Navigator.pop(context); // close drawer
  }

  void _onBottomNavTap(int index) {
    setState(() => _selectedIndex = index);
  }
  void _showFilterOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).dialogBackgroundColor,
        title: const Text("Filter Options"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Container(
                decoration: BoxDecoration(
                  color: Appcolors.subtheme,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: const Text(
                  'All',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.playlist_add),
              title: const Text('New list'),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("New List"),
                    content: const Text("Create a new habit list here."),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Close"),
                      ),
                    ],
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.tune),
              title: const Text('Filters'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Filter menu coming soon")),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Help'),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Help"),
                    content: const Text("Here's how to use the app..."),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Got it"),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  void _showSearchDialog(BuildContext context) {
    final TextEditingController _searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Search"),
        content: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Enter search keyword'),
          onChanged: (value) {
            // TODO: Filter your list based on keyword (implement inside your screen logic)
            print('Search for: $value');
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }
  void _showArchiveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Archived Items"),
        content: const Text("Here you can see or restore archived items."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        backgroundColor: Appcolors.theme,
        actions:
         _getAppBarActions(),

      ),
      drawer: Drawer(
        backgroundColor: Colors.black,
        child: ListView(
          children: [
            DrawerHeader(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("HabitNow", style: TextStyle(fontSize: 24, color: Appcolors.theme)),
                  const SizedBox(height: 5),
                  const Text("Welcome!", style: TextStyle(color: Colors.white70)),
                  Text(
                    FirebaseAuth.instance.currentUser?.email ?? "Guest",
                    style: const TextStyle(color: Colors.white60, fontSize: 12),
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
