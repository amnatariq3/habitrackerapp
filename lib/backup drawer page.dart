import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:untitled7/Color%20Compound%20class.dart';

class BackupPage extends StatefulWidget {
  @override
  _BackupPageState createState() => _BackupPageState();
}

class _BackupPageState extends State<BackupPage> {
  late String userId;
  DateTime? lastBackupDate;
  int csvUsesLeft = 1;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    userId = user?.uid ?? 'guest'; // Replace with real Firebase user ID
    loadLastBackup();
  }

  Future<void> loadLastBackup() async {
    var doc = await FirebaseFirestore.instance.collection('backups').doc(userId).get();
    if (doc.exists) {
      var timestamp = doc.data()?['timestamp'];
      if (timestamp != null) {
        setState(() {
          lastBackupDate = (timestamp as Timestamp).toDate();
        });
      }
    }
  }

  Future<void> uploadBackup() async {
    // 🔄 Simulated backup data - replace with actual data from Firestore or SharedPreferences
    Map<String, dynamic> dummyData = {
      'notes': ['Task A', 'Task B'],
      'timestamp': Timestamp.now()
    };

    await FirebaseFirestore.instance.collection('backups').doc(userId).set(dummyData);
    setState(() {
      lastBackupDate = DateTime.now();
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("✅ Backup uploaded to cloud")));
  }

  Future<void> importFromCloud() async {
    var doc = await FirebaseFirestore.instance.collection('backups').doc(userId).get();
    if (doc.exists) {
      var data = doc.data();
      print("✅ Imported data from Firebase: $data");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("✅ Backup imported from cloud")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("⚠️ No backup found.")));
    }
  }

  Future<void> createBackupFile() async {
    Directory dir = await getApplicationDocumentsDirectory();
    File file = File('${dir.path}/backup.json');
    await file.writeAsString('{"backup": "This is a dummy local backup."}');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("📁 Local backup file created")));
  }

  Future<void> importBackupFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result != null) {
      String content = await File(result.files.single.path!).readAsString();
      print("📂 Imported file content: $content");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("📂 File imported successfully")));
    }
  }

  Future<void> exportCSV() async {
    if (csvUsesLeft <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("⚠️ CSV limit reached.")));
      return;
    }

    List<List<dynamic>> rows = [
      ["Name", "Task"],
      ["Ali", "Math HW"],
      ["Sara", "Science HW"],
    ];

    String csv = const ListToCsvConverter().convert(rows);
    Directory dir = await getApplicationDocumentsDirectory();
    File file = File('${dir.path}/backup.csv');
    await file.writeAsString(csv);

    setState(() => csvUsesLeft--);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("📄 CSV exported.")));
  }

  @override
  Widget build(BuildContext context) {
    final isDark= Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(title: Text("Backup"), backgroundColor: Colors.black),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                Icon(Icons.cloud_upload, size: 60, color: Appcolors.subtheme),
                Text("Last cloud backup", style: TextStyle(color: Colors.white54)),
                Text(
                  lastBackupDate != null ? lastBackupDate.toString() : "-",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Appcolors.subtheme),
            onPressed: uploadBackup,
            child: Text("UPLOAD BACKUP"),
          ),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: Appcolors.subtheme,
              side: BorderSide(color: Appcolors.subtheme),
            ),
            onPressed: importFromCloud,
            child: Text("IMPORT FROM CLOUD"),
          ),
          Divider(color: Colors.white24, height: 32),
          ListTile(
            leading: Icon(Icons.add_box, color: Appcolors.theme),
            title: Text("Create backup file", style: TextStyle(color: Colors.white)),
            onTap: createBackupFile,
          ),
          ListTile(
            leading: Icon(Icons.restore, color: Appcolors.theme),
            title: Text("Import backup file", style: TextStyle(color: Colors.white)),
            onTap: importBackupFile,
          ),
          ListTile(
            leading: Icon(Icons.table_chart, color: Appcolors.theme),
            title: Text("CSV data export", style: TextStyle(color: Colors.white)),
            subtitle: Text("One free use remaining", style: TextStyle(color: Appcolors.subtheme)),
            onTap: exportCSV,
          ),
        ],
      ),
    );
  }
}
