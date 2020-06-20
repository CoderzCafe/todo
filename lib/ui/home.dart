


import 'package:flutter/material.dart';
import './todo_screen.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        centerTitle: true,
        backgroundColor: Colors.black54,
        title: new Text("ToDo", textDirection: TextDirection.ltr,),
      ),

      body: new ToDoScreen(),
    );
  }
}
