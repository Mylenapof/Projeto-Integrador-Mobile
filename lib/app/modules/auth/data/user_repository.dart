import '../../../core/base/base_repository.dart';
import 'user_model.dart';

class UserRepository extends BaseRepository<UserModel> {
  @override
  String get tableName => 'users';

  @override
  UserModel fromMap(Map<String, dynamic> map) => UserModel.fromMap(map);

  Future<UserModel?> findByEmailAndSenha(String email, String senha) async {
    final db = await dbHelper.database;
    final result = await db.query(
      tableName,
      where: 'email = ? AND senha = ?',
      whereArgs: [email, senha],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return fromMap(result.first);
  }

  Future<bool> emailExiste(String email) async {
    final db = await dbHelper.database;
    final result = await db.query(
      tableName,
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    return result.isNotEmpty;
  }
}