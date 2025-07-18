import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

// Import your pages
import 'Archieved habit page.dart';
import 'Customize drawer page.dart';
import 'Rate this up alert dialogue.dart';
import 'Todaypage.dart';
import 'backup drawer page.dart';
import 'calendar page.dart';
import 'category picker page.dart';
import 'contact us drawer page.dart';
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
  late DatabaseReference habitsRef;

  DateTime selectedDay = DateTime.now();
  String get selectedDateStr => DateFormat('yyyy-MM-dd').format(selectedDay);
  @override
  void initState() {
    super.initState();

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userId = user.uid;
      habitsRef = FirebaseDatabase.instance.ref().child('habits').child(userId);
    } else {
      // Optional: handle unauthenticated user (e.g., navigate to login)
      print("User not logged in!");
    }

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
      CustomizePage(),
      BackupPage(),
    ];
  }

  final List<String> _titles = [
    'Today',
    'Habits',
    'Tasks',
    'Categories',
    'Timer',
    'Settings',
    'Customize'
    'Backup'
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
          IconButton(
            icon: Icon(Icons.archive_outlined),
            onPressed: () {
              final userId = FirebaseAuth.instance.currentUser?.uid;
              if (userId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ArchivedHabitsPage(userId: userId),
                  ),
                );
              }
            },
          ),

        ];
      case 2: // Tasks Page
        return [
          IconButton(icon: Icon(Icons.search), onPressed: () => _showSearchDialog(context),),
          IconButton(icon: Icon(Icons.filter_list), onPressed: () => _showFilterOptionsDialog(context),),
          IconButton(
            icon: Icon(Icons.archive_outlined),
            onPressed: () {
              final userId = FirebaseAuth.instance.currentUser?.uid;
              if (userId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ArchivedHabitsPage(userId: userId),
                  ),
                );
              }
            },
          ),
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
    Navigator.pop(context); // close the drawer

    if (index == 6) {
      // Customize
      Navigator.push(context, MaterialPageRoute(builder: (context)=>CustomizePage())
      );
    } else if (index == 7) {
      // 🔁 Backup → navigate to BackupPage
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => BackupPage()),
      );
    } else if (index == 8) {
      // Rate this app
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        showFeedbackDialog(context, user.uid);
      }
    } else if (index == 9) {
      // Contact us
      Navigator.push(context, MaterialPageRoute(builder: (context)=>contactusPage())
      );
    } else if (index < _screens.length) {
      setState(() => _selectedIndex = index);
    }
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
  void _showArchiveDialog(BuildContext context, DatabaseReference habitsRef) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Archived Habits"),
        content: SizedBox(
          width: double.maxFinite,
          child: StreamBuilder<DatabaseEvent>(
            stream: habitsRef.onValue,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final data = snapshot.data?.snapshot.value;
              if (data == null || data is! Map) {
                return const Text("No archived habits found.");
              }

              final archivedHabits = data.entries.where((e) {
                final archived = e.value['isArchived'];
                return archived == true || archived == 'true' || archived == 1 || archived == '1';
              }).toList();

              if (archivedHabits.isEmpty) {
                return const Text("No archived habits found.");
              }

              return ListView.builder(
                shrinkWrap: true,
                itemCount: archivedHabits.length,
                itemBuilder: (context, index) {
                  final habit = Map<String, dynamic>.from(archivedHabits[index].value);
                  final title = habit['title'] ?? 'Untitled';
                  return ListTile(
                    leading: const Icon(Icons.archive),
                    title: Text(title),
                    subtitle: Text("This habit is archived."),
                  );
                },
              );
            },
          ),
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
            _drawerItem(Icons.dashboard_customize, 'Customize', 6),
            _drawerItem(Icons.backup_outlined, 'Backup', 7),
            _drawerItem(Icons.rate_review_outlined, 'Rate this app', 8),
            _drawerItem(Icons.contacts_outlined, 'Contact us', 9),
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
          onTap: (index) => setState(() => _selectedIndex = index),

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
