import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'color compound class.dart';
import 'logout page.dart'; // <-- For Appcolors.subtheme

class ProfileSettingsPage extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) onThemeToggle;

  const ProfileSettingsPage({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  String _username = 'User';
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadSavedUserInfo();
  }

  Future<void> _loadSavedUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? 'User';
      _profileImageUrl = prefs.getString('profileImage');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Profile Settings", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey[900],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 👤 Profile Header
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: _profileImageUrl != null
                    ? NetworkImage(_profileImageUrl!)
                    : null,
                backgroundColor: Appcolors.subtheme,
                child: _profileImageUrl == null
                    ? const Icon(Icons.person, size: 30, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 16),
              Text(
                _username,
                style: const TextStyle(fontSize: 20, color: Colors.white),
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(color: Colors.grey),

          // 🌙 Dark Mode Switch
          SwitchListTile(
            title: const Text("Dark Mode", style: TextStyle(color: Colors.white)),
            value: widget.isDarkMode,
            activeColor: Appcolors.subtheme,
            onChanged: widget.onThemeToggle,
          ),

          const Divider(color: Colors.grey),

          // 🚪 Logout
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text("Logout", style: TextStyle(color: Colors.redAccent)),
            onTap: () => LogoutHelper.confirmLogout(context),
          ),
        ],
      ),
    );
  }
}
