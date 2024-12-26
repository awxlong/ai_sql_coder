import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'dummy_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Pacientes (
        id_paciente INTEGER PRIMARY KEY,
        nombre TEXT,
        apellido TEXT,
        fecha_nacimiento TEXT,
        genero TEXT,
        telefono TEXT,
        correo_electronico TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Factores_Fisiologicos (
        id_factor INTEGER PRIMARY KEY,
        id_paciente INTEGER,
        altura REAL,
        peso REAL,
        presion_arterial TEXT,
        frecuencia_cardiaca INTEGER,
        fecha_registro TEXT,
        FOREIGN KEY (id_paciente) REFERENCES Pacientes(id_paciente)
      )
    ''');
  }
}

Future<void> populateDatabase() async {
  final db = await DatabaseHelper.instance.database;

  // Insert data into Pacientes
  for (int i = 1; i <= 10; i++) {
    await db.insert('Pacientes', {
      'id_paciente': i,
      'nombre': 'Nombre$i',
      'apellido': 'Apellido$i',
      'fecha_nacimiento': '198${i}-01-01',
      'genero': i % 2 == 0 ? 'M' : 'F',
      'telefono': '555-${i.toString().padLeft(4, '0')}',
      'correo_electronico': 'email$i@example.com',
    });
  }

  // Insert data into Factores_Fisiologicos
  for (int i = 1; i <= 20; i++) {
    await db.insert('Factores_Fisiologicos', {
      'id_factor': i,
      'id_paciente': (i % 10) + 1,
      'altura': (1.5 + (i % 5) * 0.1).toStringAsFixed(2),
      'peso': (50 + (i % 5) * 10).toStringAsFixed(2),
      'presion_arterial': '${100 + (i % 5) * 10}/70',
      'frecuencia_cardiaca': 60 + (i % 5) * 10,
      'fecha_registro': '2024-${(i % 12) + 1}-01',
    });
  }
}

