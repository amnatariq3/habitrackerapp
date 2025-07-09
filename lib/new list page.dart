import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewListPage extends StatefulWidget {
  @override
  _NewListPageState createState() => _NewListPageState();
}

class _NewListPageState extends State<NewListPage> {
  final _formKey = GlobalKey<FormState>();
  String _listName = '';
  String _icon = 'None';
  String _activities = 'All';
  String _categories = 'Show all';

  void _saveList() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        await FirebaseFirestore.instance.collection('lists').add({
          'name': _listName,
          'icon': _icon,
          'activities': _activities,
          'categories': _categories,
          'createdAt': Timestamp.now(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('List "$_listName" saved!')),
        );

        // Optionally clear form or navigate back
        _formKey.currentState!.reset();
        setState(() {
          _icon = 'None';
          _activities = 'All';
          _categories = 'Show all';
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving list: $e')),
        );
      }
    }
  }

  void _pickIcon() {
    setState(() {
      _icon = 'Calendar Icon';
    });
  }

  void _selectActivities() {
    setState(() {
      _activities = 'Custom Activities';
    });
  }

  void _selectCategories() {
    setState(() {
      _categories = 'Selected Categories';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New List'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            ListTile(
              leading: Icon(Icons.edit),
              title: TextFormField(
                decoration: InputDecoration(
                  labelText: 'List name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? 'Please enter a list name' : null,
                onSaved: (value) => _listName = value ?? '',
              ),
            ),
            SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.image),
              title: Text('Icon'),
              subtitle: Text(_icon),
              onTap: _pickIcon,
            ),
            ListTile(
              leading: Icon(Icons.remove_red_eye),
              title: Text('Activities'),
              subtitle: Text(_activities),
              onTap: _selectActivities,
            ),
            ListTile(
              leading: Icon(Icons.category),
              title: Text('Categories'),
              subtitle: Text(_categories),
              onTap: _selectCategories,
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _saveList,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'SAVE',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
