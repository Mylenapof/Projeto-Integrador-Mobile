import '../helpers/database_helper.dart';
import 'log_model.dart';

class LogRepository {
  final _db = DatabaseHelper.instance;

  Future<void> insert(LogEntry entry) async {
    try {
      final db = await _db.database;
      await db.insert('system_logs', entry.toMap());
    } catch (_) {
      // Silencia erros do próprio sistema de log para não causar loops
    }
  }

  Future<List<LogEntry>> findByLevel(String nivel) async {
    final db = await _db.database;
    final result = await db.query(
      'system_logs',
      where: 'nivel = ?',
      whereArgs: [nivel],
      orderBy: 'created_at DESC',
      limit: 100,
    );
    return result.map(LogEntry.fromMap).toList();
  }

  Future<List<LogEntry>> findAll({int limit = 200}) async {
    final db = await _db.database;
    final result = await db.query(
      'system_logs',
      orderBy: 'created_at DESC',
      limit: limit,
    );
    return result.map(LogEntry.fromMap).toList();
  }

  Future<void> clearOld() async {
    final db = await _db.database;
    await db.delete(
      'system_logs',
      where: "created_at < datetime('now', '-30 days')",
    );
  }
}