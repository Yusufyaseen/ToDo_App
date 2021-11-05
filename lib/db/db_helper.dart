import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:todo/models/task.dart';

class DBHelper {
  static Database? db;
  static const String _dbName = "Todo.db";
  static const String _tableName = "Tasks";

  static const int _version = 1;

  static Future<void> init() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, _dbName);
    if (db != null) {
      debugPrint("NOOOOOO");
    } else {
      db = await openDatabase(
        path,
        version: _version,
        onCreate: (database, _version) async {
          await database.execute('CREATE TABLE $_tableName('
              'id INTEGER PRIMARY KEY autoincrement,'
              'title VARCHAR(10), note VARCHAR(255), date VARCHAR(20),'
              'startTime VARCHAR(10), endTime VARCHAR(10),'
              'remind INTEGER, repeat VARCHAR(10),'
              'color TINYINT, isCompleted TINYINT);');
        },
      );
    }
  }

  static Future insert(Task task) async {
    await init();
    await db!.rawInsert(
        'INSERT INTO $_tableName(title,note,date,startTime,endTime,remind,repeat,color,isCompleted) VALUES("${task.title}", "${task.note}", "${task.date}", "${task.startTime}", "${task.endTime}", ${task.remind}, "${task.repeat}", ${task.color}, ${task.isCompleted})');
  }

  static Future update(int id) async {
    await init();
    await db!.rawUpdate(
        'UPDATE $_tableName SET isCompleted = ? where id = ?', [1, id]);
  }

  static Future delete(int id) async {
    await init();
    await db!.rawDelete('delete from $_tableName where id = ?', [id]);
  }

  static Future deleteAll() async {
    await init();
    await db!.rawDelete('delete from $_tableName');
  }

  static Future<List<Task>> getTasks() async {
    await init();
    final List<Map<String, dynamic>> maps =
        await db!.rawQuery('SELECT * FROM $_tableName');
    List<Task> lists = maps
        .map(
          (task) => Task(
              id: task['id'],
              title: task['title'],
              note: task['note'],
              isCompleted: task['isCompleted'],
              date: task['date'],
              startTime: task['startTime'],
              endTime: task['endTime'],
              color: task['color'],
              remind: task['remind'],
              repeat: task['repeat']),
        )
        .toList();

    return lists;
  }
}
