import 'package:flutter/material.dart';
import 'screens/query_generator_screen.dart'; // Import the screen

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI SQL Query Generator',
      home: QueryGeneratorScreen(), // Set the home screen
    );
  }
}
