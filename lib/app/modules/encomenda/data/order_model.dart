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
  final double? valorOrcamento;
  final String? respostaAdmin;
  final String tipoEntrega;
  final String? endereco;
  final String? linkLocalizacao;
  final String? telefone;
  final String? dataRetirada;
  final String? horarioRetirada;

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
    this.valorOrcamento,
    this.respostaAdmin,
    this.tipoEntrega = 'retirada',
    this.endereco,
    this.linkLocalizacao,
    this.telefone,
    this.dataRetirada,
    this.horarioRetirada,
    super.isSync,
    super.createdAt,
  });

  @override
  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'user_id':          userId,
    'tipo':              tipo,
    'tipo_produto':      tipoProduto,
    'tamanho':           tamanho,
    'sabor':             sabor,
    'decoracao':         decoracao,
    'observacoes':       observacoes,
    'status':            status,
    'valor_orcamento':   valorOrcamento,
    'resposta_admin':    respostaAdmin,
    'tipo_entrega':      tipoEntrega,
    'endereco':          endereco,
    'link_localizacao':  linkLocalizacao,
    'telefone':          telefone,
    'data_retirada':     dataRetirada,
    'horario_retirada':  horarioRetirada,
    'is_sync':           isSync,
    'created_at':        createdAt ?? DateTime.now().toIso8601String(),
  };

  factory OrderModel.fromMap(Map<String, dynamic> m) => OrderModel(
    id:              m['id'],
    userId:          m['user_id'],
    tipo:            m['tipo'],
    tipoProduto:     m['tipo_produto'],
    tamanho:         m['tamanho'],
    sabor:           m['sabor'],
    decoracao:       m['decoracao'],
    observacoes:     m['observacoes'],
    status:          m['status'],
    valorOrcamento:  m['valor_orcamento'],
    respostaAdmin:   m['resposta_admin'],
    tipoEntrega:     m['tipo_entrega'] ?? 'retirada',
    endereco:        m['endereco'],
    linkLocalizacao: m['link_localizacao'],
    telefone:        m['telefone'],
    dataRetirada:    m['data_retirada'],
    horarioRetirada: m['horario_retirada'],
    isSync:          m['is_sync'] ?? 0,
    createdAt:        m['created_at'],
  );

  OrderModel copyWith({
    String? status,
    double? valorOrcamento,
    String? respostaAdmin,
  }) => OrderModel(
    id:              id,
    userId:          userId,
    tipo:            tipo,
    tipoProduto:     tipoProduto,
    tamanho:         tamanho,
    sabor:           sabor,
    decoracao:       decoracao,
    observacoes:     observacoes,
    status:          status         ?? this.status,
    valorOrcamento:  valorOrcamento ?? this.valorOrcamento,
    respostaAdmin:   respostaAdmin  ?? this.respostaAdmin,
    tipoEntrega:     tipoEntrega,
    endereco:        endereco,
    linkLocalizacao: linkLocalizacao,
    telefone:        telefone,
    dataRetirada:    dataRetirada,
    horarioRetirada: horarioRetirada,
    isSync:          isSync,
    createdAt:       createdAt,
  );
}