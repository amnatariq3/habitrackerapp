import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsPage extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) onThemeToggle;

  const SettingsPage({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  String _appVersion = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadVersionInfo();
  }

  Future<void> _loadVersionInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (!mounted) return;
      setState(() => _appVersion = "${info.version} (${info.buildNumber})");
    } catch (_) {
      setState(() => _appVersion = "Unknown");
    }
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? 'Not logged in';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: const Text("Settings"),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.orange,
              child: Icon(Icons.person, color: Colors.white),
            ),
            title: const Text("User Profile", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            subtitle: Text(email, style: const TextStyle(color: Colors.white70)),
          ),
          const Divider(color: Colors.white12),

          // 🔄 Dark Mode Toggle
          SwitchListTile(
            title: const Text("Dark Mode", style: TextStyle(color: Colors.white)),
            value: widget.isDarkMode,
            activeColor: Colors.orange,
            onChanged: widget.onThemeToggle,
          ),

          // 🔔 Notification Toggle
          SwitchListTile(
            title: const Text("Enable Notifications", style: TextStyle(color: Colors.white)),
            value: _notificationsEnabled,
            activeColor: Colors.orange,
            onChanged: (v) {
              setState(() => _notificationsEnabled = v);
              // Optional: Save to preferences
            },
          ),

          ListTile(
            leading: const Icon(Icons.lock_outline, color: Colors.white),
            title: const Text("Change Password", style: TextStyle(color: Colors.white)),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Password reset not implemented.")),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.white),
            title: const Text("Logout", style: TextStyle(color: Colors.white)),
            onTap: _logout,
          ),

          const Divider(color: Colors.white12),

          ListTile(
            title: const Text("App Version", style: TextStyle(color: Colors.white70)),
            subtitle: Text(_appVersion, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
