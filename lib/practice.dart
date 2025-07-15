import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class myproject extends StatefulWidget {
  const myproject({super.key});

  @override
  State<myproject> createState() => _myprojectState();
}

class _myprojectState extends State<myproject> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("my project" , style:TextStyle(color: Colors.black ,fontSize:50 , fontWeight: FontWeight.bold )),
            centerTitle: true,
      ),
    );
  }
}
