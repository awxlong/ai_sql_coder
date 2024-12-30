import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart';
import 'dart:io';

class SQLDatabaseExisting {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initExistingDatabase();
    return _database!;
  }

  Future<Database> _initExistingDatabase() async {
    // Path to the SQLite database file
    String path = join(await getDatabasesPath(), 'mimic_iv_demo_admissions.db');
    
    // // Check if the database exists
    // bool exists = await databaseExists(path);
    // if (!exists) {
    //   // Copy the database from assets
    //   ByteData data = await rootBundle.load('assets/mimic_iv_demo.db');
    //   List<int> bytes = data.buffer.asUint8List();
    //   await File(path).writeAsBytes(bytes);
    //   print('Database copied from assets to $path');
    // }

    return await openDatabase(
      path,
    );
  }


  Future<List<Map<String, dynamic>>> executeQueryExisting(String query) async {
    final db = await database;
    return await db.rawQuery(query);
  }
}