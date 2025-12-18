import 'dart:async';

import 'package:sqflite/sqflite.dart';

import '../model/task_model.dart';

class TaskLocalDb {
  TaskLocalDb._();

  static final TaskLocalDb instance = TaskLocalDb._();
  static const _dbName = 'tasks.db';
  static const _table = 'tasks';

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _openDb();
    return _db!;
  }

  Future<Database> _openDb() async {
    final dbDir = await getDatabasesPath();
    final path = '$dbDir/$_dbName';
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE $_table(
          id INTEGER PRIMARY KEY,
          title TEXT NOT NULL,
          description TEXT NOT NULL,
          type TEXT NOT NULL,
          status TEXT NOT NULL,
          createdAt TEXT NOT NULL
        )
        ''');
      },
    );
  }

  Future<List<TaskModel>> fetchAll() async {
    final db = await database;
    final rows = await db.query(_table);
    return rows.map((row) => TaskModel.fromMap(row)).toList();
  }

  Future<int> insertTask(TaskModel task) async {
    final db = await database;
    return db.insert(
      _table,
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateTask(TaskModel task) async {
    final db = await database;
    return db.update(
      _table,
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await database;
    return db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clear() async {
    final db = await database;
    await db.delete(_table);
  }

  Future<void> importTask(List<TaskModel> tasks,
      {bool clearBeforeInsert = false}) async {
    final db = await database;
    await db.transaction((txn) async {
      if (clearBeforeInsert) {
        await txn.delete(_table);
      }
      final batch = txn.batch();
      for (final task in tasks) {
        batch.insert(
          _table,
          task.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    });
  }
}
