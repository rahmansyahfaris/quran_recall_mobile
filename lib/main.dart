// lib/main.dart
import 'package:flutter/material.dart';
import 'load_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quran Recall',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: LoadPage(),
    );
  }
}