import '../../../core/base/base_repository.dart';
import 'product_model.dart';

class ProductRepository extends BaseRepository<ProductModel> {
  @override
  String get tableName => 'products';

  @override
  ProductModel fromMap(Map<String, dynamic> map) => ProductModel.fromMap(map);

  Future<List<ProductModel>> findDisponiveis() async {
    final db = await dbHelper.database;
    final result = await db.query(
      tableName,
      where: 'disponivel = ?',
      whereArgs: [1],
      orderBy: 'nome ASC',
    );
    return result.map(fromMap).toList();
  }

  Future<List<ProductModel>> findByCategoria(int categoryId) async {
    final db = await dbHelper.database;
    final result = await db.query(
      tableName,
      where: 'category_id = ? AND disponivel = ?',
      whereArgs: [categoryId, 1],
      orderBy: 'nome ASC',
    );
    return result.map(fromMap).toList();
  }

  Future<List<ProductModel>> findDestaques({int limit = 4}) async {
    final db = await dbHelper.database;
    final result = await db.query(
      tableName,
      where: 'disponivel = ?',
      whereArgs: [1],
      orderBy: 'id ASC',
      limit: limit,
    );
    return result.map(fromMap).toList();
  }
}