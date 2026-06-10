import '../../../core/base/base_repository.dart';
import 'order_model.dart';

class OrderRepository extends BaseRepository<OrderModel> {
  @override
  String get tableName => 'orders';

  @override
  OrderModel fromMap(Map<String, dynamic> map) => OrderModel.fromMap(map);

  Future<List<OrderModel>> findByUser(int userId) async {
    final db = await dbHelper.database;
    final result = await db.query(
      tableName,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return result.map(fromMap).toList();
  }
}