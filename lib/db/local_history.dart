import 'dart:async';
import 'package:sqflite/sqflite.dart';
import '../model/LocalHistory.dart';

class LocalHistoryDatabase {
  static final LocalHistoryDatabase instance = LocalHistoryDatabase._init();

  static Database? _database;
  LocalHistoryDatabase._init();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDB("localHist.db");

    return _database!;
  }

  Future<Database> _initDB(String filepath) async {
    final dbpath = await getDatabasesPath();
    final path = '$dbpath/$filepath';
    print(path);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    final textType = "TEXT NOT NULL";
    await db.execute('''
    CREATE TABLE IF NOT EXISTS $table(
      ${LocalHistFields.dateUnixAsId} TEXT NOT NULL PRIMARY KEY,
      ${LocalHistFields.device} $textType,
      ${LocalHistFields.farm} $textType,
      ${LocalHistFields.value} $textType,
      ${LocalHistFields.comment} $textType)''');
  }

  Future<LocalHist> add(LocalHist local) async {
    final db = await instance.database;
    final id = await db.insert(
      table,
      local.toJson(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );

    return local.response(id: id.toString());
  }

  Future<List<LocalHist>> getAllHistory() async {
    final db = await instance.database;
    final orderby = '${LocalHistFields.dateUnixAsId} DESC';
    final result = await db.query(table, orderBy: orderby);

    return result.map((e) => LocalHist.fromJson(e)).toList();
  }

  Future<List<LocalHist>> getHistoryOf({required String device}) async {
    final db = await instance.database;
    final orderby = '${LocalHistFields.dateUnixAsId} DESC';
    final result = await db.query(
      table,
      orderBy: orderby,
      where: 'device = ?',
      whereArgs: [device],
    );

    return result.map((e) => LocalHist.fromJson(e)).toList();
  }

  Future close() async {
    final db = await instance.database;

    db.close();
  }
}
