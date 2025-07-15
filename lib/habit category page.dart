import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:iconsax/iconsax.dart';

import 'Evaluation method page.dart';
import 'category picker page.dart';
import 'Color Compound class.dart';

class HabitCategoryPage extends StatelessWidget {
  const HabitCategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Select a category for your habit',
          style: TextStyle(color: Appcolors.subtheme, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.grey[900],
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: FirebaseDatabase.instance.ref("users/$userId/categories").onValue,
              builder: (context, snapshot) {
                final userCategories = <Category>[];

                if (snapshot.hasData && snapshot.data?.snapshot.value != null) {
                  final data = Map<String, dynamic>.from(
                      (snapshot.data!.snapshot.value as Map<dynamic, dynamic>).map(
                            (key, value) => MapEntry(key.toString(), value as Map),
                      ));

                  data.forEach((key, value) {
                    userCategories.add(
                      Category(
                        value['name'] ?? 'Unnamed',
                        IconData(
                          value['icon'] ?? Icons.category.codePoint,
                          fontFamily: value['iconFont'] ?? 'MaterialIcons',
                        ),
                        Color(value['color'] ?? Colors.grey.value),
                      ),
                    );
                  });
                }

                // Static categories
                final defaultCategories = [
                  Category("Quit a bad habit", Iconsax.warning_2, Colors.red),
                  Category("Art", Iconsax.paintbucket, Colors.redAccent),
                  Category("Meditation", Icons.self_improvement, Colors.purple),
                  Category("Study", Iconsax.book, Colors.purpleAccent),
                  Category("Sports", Iconsax.activity, Colors.blue),
                  Category("Entertainment", Iconsax.star, Colors.teal),
                  Category("Social", Iconsax.message, Colors.green),
                  Category("Finance", Iconsax.dollar_circle, Colors.green.shade700),
                  Category("Health", Iconsax.health, Colors.lightGreen),
                  Category("Work", Iconsax.briefcase, Colors.lightGreen.shade700),
                  Category("Nutrition", Iconsax.ranking, Colors.orange),
                  Category("Home", Iconsax.home, Colors.deepOrange),
                  Category("Outdoor", Iconsax.location, Colors.orange.shade700),
                  Category("Other", Iconsax.gift, Colors.redAccent),
                ];

                final allCategories = [...defaultCategories, ...userCategories];

                return GridView.count(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 3.5,
                  children: [
                    ...allCategories.map((cat) => CategoryCard(cat: cat)),
                    CreateCategoryCard(userId: userId),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "CANCEL",
                    style: TextStyle(
                      color: Appcolors.subtheme,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    4,
                        (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Appcolors.subtheme,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class Category {
  final String name;
  final IconData icon;
  final Color color;

  Category(this.name, this.icon, this.color);
}

class CategoryCard extends StatelessWidget {
  final Category cat;
  const CategoryCard({super.key, required this.cat});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EvaluationMethodPage()),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: cat.color,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(6),
              child: Icon(cat.icon, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(cat.name,
                  style: const TextStyle(fontSize: 14, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class CreateCategoryCard extends StatelessWidget {
  final String userId;

  const CreateCategoryCard({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (userId.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please log in to create a category")),
          );
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CategoryPickerPage(userId: userId),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(6),
              child: const Icon(Iconsax.add, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 15),
            const Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Create category',
                      style: TextStyle(fontSize: 14, color: Colors.white)),
                  Text('5 available',
                      style: TextStyle(fontSize: 11, color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
