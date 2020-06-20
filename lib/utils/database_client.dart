
import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/todo_item.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = new DatabaseHelper.internal();

  DatabaseHelper.internal();

  factory DatabaseHelper() => _instance;

  final String tableName = "todoTable";
  final String columnId = "id";
  final String columnItemName = "itemName";
  final String columnDateCreated = "dateCreated";

  static Database _db;


  Future<Database> get db async {
    if(_db != null) {
      return _db;
    }

    _db = await initDb();
    return _db;
  }

  initDb() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, "todo_db.db");
    var ourDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return ourDb;
  }

  void _onCreate(Database db, int version) async {
    await db.execute(
      "CREATE TABLE $tableName($columnId INTEGER PRIMARY KEY, $columnItemName VARCHAR(255), $columnDateCreated VARCHAR(255));"
    );
    print("===--- table created successfully ---===");
  }

  //  insertion
Future<int> saveItem(ToDoItem item) async {
    var dbClient = await db;
    int res = await dbClient.insert("$tableName", item.toMap());
    print("====== saveItem() :: ${res.toString()}");
    return res;
}

//  get
Future<List> getItems() async {
    var dbClient = await db;
    var result = await dbClient.rawQuery(
      "SELECT * FROM $tableName ORDER BY $columnItemName ASC"
    );
    return result.toList();
}

//  get count
Future<int> getCount() async {
    var dbClient = await db;
    return Sqflite.firstIntValue(await dbClient.rawQuery(
        "SELECT COUNT(*) FROM $tableName"
    ));
}

//  getting one item
Future<ToDoItem> getItem(int id) async {
    var dbClient = await db;
    var result = await dbClient.rawQuery(
      "SELECT * FROM $tableName WHERE id=$id"
    );
    if(result.length == 0) return null;

    return new ToDoItem.fromMap(result.first);
}

Future<int> deleteItem(int id) async {
    var dbClient = await db;
    return await dbClient.delete("$tableName", where: "$columnId=?", whereArgs: [id]);
}

Future<int> updateItem(ToDoItem item) async {
    var dbClient = await db;
    debugPrint("updated item is: ${item.itemName}");
    return await dbClient.update("$tableName", item.toMap(), where: "$columnId=?", whereArgs: [item.id]);
}

Future close() async {
    var dbClient = await db;
    return dbClient.close();
}

}