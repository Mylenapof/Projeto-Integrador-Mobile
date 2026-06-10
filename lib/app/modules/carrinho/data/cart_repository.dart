import '../../../core/base/base_repository.dart';
import 'cart_item_model.dart';

class CartRepository extends BaseRepository<CartItemModel> {
  @override
  String get tableName => 'cart_items';

  @override
  CartItemModel fromMap(Map<String, dynamic> map) => CartItemModel.fromMap(map);

  Future<List<CartItemModel>> findByUser(int userId) async {
    final db = await dbHelper.database;
    final result = await db.rawQuery('''
      SELECT c.*, p.nome, p.preco
      FROM cart_items c
      INNER JOIN products p ON c.product_id = p.id
      WHERE c.user_id = ?
      ORDER BY c.created_at DESC
    ''', [userId]);
    return result.map(fromMap).toList();
  }

  Future<void> adicionar(int userId, int productId) async {
    final db = await dbHelper.database;
    final existing = await db.query(
      tableName,
      where: 'user_id = ? AND product_id = ?',
      whereArgs: [userId, productId],
      limit: 1,
    );

    if (existing.isNotEmpty) {
      final atual = existing.first['quantidade'] as int;
      await db.update(
        tableName,
        {'quantidade': atual + 1},
        where: 'id = ?',
        whereArgs: [existing.first['id']],
      );
    } else {
      await db.insert(tableName, {
        'user_id':    userId,
        'product_id': productId,
        'quantidade': 1,
        'is_sync':    0,
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<void> diminuir(int itemId, int quantidadeAtual) async {
    final db = await dbHelper.database;
    if (quantidadeAtual <= 1) {
      await db.delete(tableName, where: 'id = ?', whereArgs: [itemId]);
    } else {
      await db.update(
        tableName,
        {'quantidade': quantidadeAtual - 1},
        where: 'id = ?',
        whereArgs: [itemId],
      );
    }
  }

  Future<void> limparCarrinho(int userId) async {
    final db = await dbHelper.database;
    await db.delete(tableName, where: 'user_id = ?', whereArgs: [userId]);
  }
}