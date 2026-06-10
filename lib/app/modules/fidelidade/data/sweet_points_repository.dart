import '../../../core/base/base_repository.dart';
import 'sweet_points_model.dart';

class SweetPointsRepository extends BaseRepository<SweetPointsModel> {
  @override
  String get tableName => 'sweet_points';

  @override
  SweetPointsModel fromMap(Map<String, dynamic> map) =>
      SweetPointsModel.fromMap(map);

  Future<SweetPointsModel?> findByUser(int userId) async {
    final db = await dbHelper.database;
    final result = await db.query(
      tableName,
      where: 'user_id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return fromMap(result.first);
  }

  Future<void> adicionarPontos(int userId, int pontos) async {
    final db = await dbHelper.database;
    final atual = await findByUser(userId);
    if (atual == null) {
      await db.insert(tableName, {
        'user_id':    userId,
        'pontos':     pontos,
        'is_sync':    0,
        'created_at': DateTime.now().toIso8601String(),
      });
    } else {
      await db.update(
        tableName,
        {'pontos': atual.pontos + pontos, 'is_sync': 0},
        where: 'user_id = ?',
        whereArgs: [userId],
      );
    }
  }

  Future<String?> resgatarPontos(int userId, int pontos) async {
    final db = await dbHelper.database;
    final atual = await findByUser(userId);
    if (atual == null || atual.pontos < pontos) {
      return 'Pontos insuficientes';
    }
    await db.update(
      tableName,
      {'pontos': atual.pontos - pontos, 'is_sync': 0},
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return null;
  }
}