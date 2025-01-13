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
    
    // Check if the database exists
    bool exists = await databaseExists(path);

    if (!exists) {
      // If the database doesn't exist, copy it from the assets
      try {
        // Ensure the parent directory exists
        await Directory(dirname(path)).create(recursive: true);

        // Load database from asset
        ByteData data = await rootBundle.load('assets/mimic_iv_demo_admissions.db');
        List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

        // Write the bytes to the file
        await File(path).writeAsBytes(bytes, flush: true);
        
        print('Database copied from assets to $path');
      } catch (e) {
        print('Error copying database: $e');
        rethrow;
      }
    } else {
      print('Opening existing database at $path');
    }

    return await openDatabase(
      path,
    );
  }


  Future<List<Map<String, dynamic>>> executeQueryExisting(String query) async {
    final db = await database;
    return await db.rawQuery(query);
  }

  Future<void> debugTableNames() async {
    final db = await database;
    final result = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table';");

    print(result);
}
}