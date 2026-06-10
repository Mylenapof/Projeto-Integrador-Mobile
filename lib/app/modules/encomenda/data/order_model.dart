// ── Model ─────────────────────────────────────────────────
import '../../../core/base/base_model.dart';

class OrderModel extends BaseModel {
  final int userId;
  final String tipo;
  final String? tipoProduto;
  final String? tamanho;
  final String? sabor;
  final String? decoracao;
  final String? observacoes;
  final String status;

  const OrderModel({
    super.id,
    required this.userId,
    required this.tipo,
    this.tipoProduto,
    this.tamanho,
    this.sabor,
    this.decoracao,
    this.observacoes,
    this.status = 'pendente',
    super.isSync,
    super.createdAt,
  });

  @override
  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'user_id':      userId,
    'tipo':         tipo,
    'tipo_produto': tipoProduto,
    'tamanho':      tamanho,
    'sabor':        sabor,
    'decoracao':    decoracao,
    'observacoes':  observacoes,
    'status':       status,
    'is_sync':      isSync,
    'created_at':   createdAt ?? DateTime.now().toIso8601String(),
  };

  factory OrderModel.fromMap(Map<String, dynamic> m) => OrderModel(
    id:          m['id'],
    userId:      m['user_id'],
    tipo:        m['tipo'],
    tipoProduto: m['tipo_produto'],
    tamanho:     m['tamanho'],
    sabor:       m['sabor'],
    decoracao:   m['decoracao'],
    observacoes: m['observacoes'],
    status:      m['status'],
    isSync:      m['is_sync'] ?? 0,
    createdAt:   m['created_at'],
  );
}