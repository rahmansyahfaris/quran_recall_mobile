// lib/main.dart
import 'package:flutter/material.dart';
import 'load_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key); 

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quran Recall',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const LoadPage(),
    );
  }
}
