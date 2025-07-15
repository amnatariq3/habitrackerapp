import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:untitled7/Color%20Compound%20class.dart';
import 'package:untitled7/taskpage.dart' show NewTaskPage, tasksPage;

import 'Recurring taks page.dart';
import 'habit category page.dart' show HabitCategoryPage;

class ActivityTypePage extends StatelessWidget {
  void navigateTo(BuildContext context, String title) {
    Widget page;

    if (title == 'Habit') {
      page = HabitCategoryPage();
    } else if (title == 'Recurring Task') {
      page = Recurringtaskspage();
    } else if (title == 'Task') {
      page = NewTaskPage();
    } else {
      // fallback to your generic DetailPage
      page = DetailPage(title: title);
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }


  Widget buildItem(
      {required BuildContext context,
        required IconData icon,
        required String title,
        required String subtitle}) {
    return GestureDetector(
      onTap: () => navigateTo(context, title),
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Appcolors.theme,
            child: Icon(icon, color: Colors.white),
          ),
          title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(subtitle),
          trailing: Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Activity Type"),
        backgroundColor: Appcolors.subtheme,
      ),
      body: Column(
        children: [
          buildItem(
            context: context,
            icon: Iconsax.cup,
            title: 'Habit',
            subtitle:
            'Activity that repeats over time. It has detailed tracking and statistics.',

          ),
          buildItem(
            context: context,
            icon: Iconsax.repeat,
            title: 'Recurring Task',
            subtitle:
            'Activity that repeats over time without tracking or statistics.',
          ),
          buildItem(
            context: context,
            icon: Iconsax.tick_circle,
            title: 'Task',
            subtitle:
            'Single instance activity without tracking over time.',
          ),
        ],
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final String title;
  const DetailPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Center(
            child: Text(
              "$title Page",
              style: TextStyle(fontSize: 22),
            ),
            ),
       );
    }
}