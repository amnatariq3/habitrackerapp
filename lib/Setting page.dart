import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'Color Compound class.dart'; //  <-  must define Appcolors.theme & Appcolors.subtheme

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  String _appVersion = 'Loading…';

  @override
  void initState() {
    super.initState();
    _loadVersionInfo();
  }

  /*────────────────────────  Helpers  ────────────────────────*/

  Future<void> _loadVersionInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (!mounted) return;
      setState(() => _appVersion = '${info.version} (${info.buildNumber})');
    } catch (_) {
      if (!mounted) return;
      setState(() => _appVersion = 'Unknown');
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    // TODO: adjust route name if you use a different login page
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
  }

  /*────────────────────────  Build  ──────────────────────────*/

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? 'Not logged in';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Appcolors.theme,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: [
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.orange,
              child: Icon(Icons.person, color: Colors.white),
            ),
            title: const Text('User Profile', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(email),
          ),
          const Divider(),

          SwitchListTile(
            title: const Text('Dark Mode'),
            value: _isDarkMode,
            activeColor: Appcolors.theme,
            onChanged: (v) => setState(() => _isDarkMode = v),
          ),

          SwitchListTile(
            title: const Text('Enable Notifications'),
            value: _notificationsEnabled,
            activeColor: Appcolors.theme,
            onChanged: (v) => setState(() => _notificationsEnabled = v),
          ),

          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Change Password'),
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Password reset not implemented.')),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: _logout,
          ),

          const Divider(),
          ListTile(
            title: const Text('App Version'),
            subtitle: Text(_appVersion),
          ),
        ],
      ),
    );
  }
}
