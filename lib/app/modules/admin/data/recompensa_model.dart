import '../../../core/base/base_model.dart';

class RecompensaModel extends BaseModel {
  final int pontos;
  final String descricao;
  final double desconto;
  final bool ativo;

  const RecompensaModel({
    super.id,
    required this.pontos,
    required this.descricao,
    required this.desconto,
    this.ativo = true,
    super.isSync,
    super.createdAt,
  });

  @override
  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'pontos':     pontos,
    'descricao':  descricao,
    'desconto':   desconto,
    'ativo':      ativo ? 1 : 0,
    'is_sync':    isSync,
    'created_at': createdAt ?? DateTime.now().toIso8601String(),
  };

  factory RecompensaModel.fromMap(Map<String, dynamic> m) => RecompensaModel(
    id:        m['id'],
    pontos:    m['pontos'],
    descricao: m['descricao'],
    desconto:  m['desconto'],
    ativo:     m['ativo'] == 1,
    isSync:    m['is_sync'] ?? 0,
    createdAt: m['created_at'],
  );

  RecompensaModel copyWith({
    int? id, int? pontos, String? descricao,
    double? desconto, bool? ativo,
  }) => RecompensaModel(
    id:        id        ?? this.id,
    pontos:    pontos    ?? this.pontos,
    descricao: descricao ?? this.descricao,
    desconto:  desconto  ?? this.desconto,
    ativo:     ativo     ?? this.ativo,
  );
}