import 'package:sqflite/sqflite.dart';
import '../helpers/database_helper.dart';
import 'base_model.dart';

abstract class BaseRepository<E extends BaseModel> {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;

  String get tableName;

  E fromMap(Map<String, dynamic> map);

  // ── CREATE ────────────────────────────────────────────────
  Future<int> insert(E entity) async {
    final db = await dbHelper.database;
    return db.insert(
      tableName,
      entity.toMap()..remove('id'),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ── READ ──────────────────────────────────────────────────
  Future<List<E>> findAll() async {
    final db = await dbHelper.database;
    final result = await db.query(tableName, orderBy: 'created_at DESC');
    return result.map(fromMap).toList();
  }

  Future<E?> findById(int id) async {
    final db = await dbHelper.database;
    final result = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return fromMap(result.first);
  }

  Future<List<E>> findPendingSync() async {
    final db = await dbHelper.database;
    final result = await db.query(
      tableName,
      where: 'is_sync = ?',
      whereArgs: [0],
    );
    return result.map(fromMap).toList();
  }

  // ── UPDATE ────────────────────────────────────────────────
  Future<int> update(E entity) async {
    final db = await dbHelper.database;
    return db.update(
      tableName,
      entity.toMap(),
      where: 'id = ?',
      whereArgs: [entity.id],
    );
  }

  Future<int> markAsSynced(int id) async {
    final db = await dbHelper.database;
    return db.update(
      tableName,
      {'is_sync': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ── DELETE ────────────────────────────────────────────────
  Future<int> delete(int id) async {
    final db = await dbHelper.database;
    return db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAll() async {
    final db = await dbHelper.database;
    return db.delete(tableName);
  }

  // ── COUNT ─────────────────────────────────────────────────
  Future<int> count() async {
    final db = await dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as total FROM $tableName');
    return result.first['total'] as int;
  }
}