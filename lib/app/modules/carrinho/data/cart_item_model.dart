import '../../../core/base/base_model.dart';

class CartItemModel extends BaseModel {
  final int userId;
  final int productId;
  final int quantidade;
  final String? produtoNome;
  final double? produtoPreco;

  const CartItemModel({
    super.id,
    required this.userId,
    required this.productId,
    this.quantidade = 1,
    this.produtoNome,
    this.produtoPreco,
    super.isSync,
    super.createdAt,
  });

  double get total => (produtoPreco ?? 0) * quantidade;

  @override
  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'user_id':    userId,
    'product_id': productId,
    'quantidade': quantidade,
    'is_sync':    isSync,
    'created_at': createdAt ?? DateTime.now().toIso8601String(),
  };

  factory CartItemModel.fromMap(Map<String, dynamic> m) => CartItemModel(
    id:           m['id'],
    userId:       m['user_id'],
    productId:    m['product_id'],
    quantidade:   m['quantidade'],
    produtoNome:  m['nome'],
    produtoPreco: m['preco'],
    isSync:       m['is_sync'] ?? 0,
    createdAt:    m['created_at'],
  );
}