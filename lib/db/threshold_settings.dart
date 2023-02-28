import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:sqflite/sqflite.dart';

class ThresholdDatabase {
  static final ThresholdDatabase instance = ThresholdDatabase._init();

  static Database? _database;
  ThresholdDatabase._init();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDB("thresh.db");

    return _database!;
  }

  Future<Database> _initDB(String filepath) async {
    final dbpath = await getDatabasesPath();
    final path = '$dbpath/$filepath';

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    final textType = "TEXT NOT NULL";
    final integerType = "INTEGER NOT NULL";
    await db.execute('''
    CREATE TABLE IF NOT EXISTS thresh(
      _id $textType PRIMARY KEY,
      _threshVal $integerType)''');
  }

  Future<Map> add(Map<String, dynamic> map) async {
    final db = await instance.database;
    final id = await db.insert(
      "thresh",
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return {
      "id": id,
      "val": map,
    };
  }

  Future<List> getAllAvailableThresh() async {
    final db = await instance.database;
    final orderby = '_id DESC';
    final result = await db.query('thresh', orderBy: orderby);

    return result;
  }

  Future<int> getThresh(String id) async {
    final db = await instance.database;
    // String enc = sha1.convert(utf8.encode(id)).toString();
    final result = await db.query(
      'thresh',
      where: '_id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) {
      return 100000;
    }
    print("[DB] $result , $id");

    return result[0]["_threshVal"] as int;
  }

  Future<Map> edit(Map<String, dynamic> map) async {
    final db = await instance.database;
    final id =
        await db.update('thresh', map, where: '_id = ?', whereArgs: map["id"]);

    return {
      "id": id,
      "val": map,
    };
  }

  Future close() async {
    final db = await instance.database;

    db.close();
  }
}
