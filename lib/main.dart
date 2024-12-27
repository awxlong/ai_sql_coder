import 'package:flutter/material.dart';
import 'package:sql_ai_app/services/sql_database.dart';
import 'screens/query_generator_screen.dart'; // Import the screen
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize FFI for desktop platforms
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Initialize and populate the database
  await initializeAndPopulateDatabase();

  runApp(const MyApp());
}


Future<void> initializeAndPopulateDatabase() async {
  // Initialize the database
  final db = await DatabaseHelper.instance.database;

  // Populate the database
  await populateDatabase();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'AI SQL Query Generator',
      home: QueryGeneratorScreen(), // Set the home screen
    );
  }
}
