import '../../../core/base/base_repository.dart';
import 'recompensa_model.dart';

class RecompensaRepository extends BaseRepository<RecompensaModel> {
  @override
  String get tableName => 'recompensas';

  @override
  RecompensaModel fromMap(Map<String, dynamic> map) =>
      RecompensaModel.fromMap(map);

  Future<List<RecompensaModel>> findAtivas() async {
    final db = await dbHelper.database;
    final result = await db.query(
      tableName,
      where: 'ativo = ?',
      whereArgs: [1],
      orderBy: 'pontos ASC',
    );
    return result.map(fromMap).toList();
  }
}