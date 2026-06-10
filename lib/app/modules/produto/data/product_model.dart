import '../../../core/base/base_model.dart';

class ProductModel extends BaseModel {
  final String nome;
  final String descricao;
  final double preco;
  final String? imagemUrl;
  final String? ingredientes;
  final int categoryId;
  final bool disponivel;

  const ProductModel({
    super.id,
    required this.nome,
    required this.descricao,
    required this.preco,
    this.imagemUrl,
    this.ingredientes,
    required this.categoryId,
    this.disponivel = true,
    super.isSync,
    super.createdAt,
  });

  @override
  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'nome':        nome,
    'descricao':   descricao,
    'preco':       preco,
    'imagem_url':  imagemUrl,
    'ingredientes': ingredientes,
    'category_id': categoryId,
    'disponivel':  disponivel ? 1 : 0,
    'is_sync':     isSync,
    'created_at':  createdAt,
  };

  factory ProductModel.fromMap(Map<String, dynamic> m) => ProductModel(
    id:           m['id'],
    nome:         m['nome'],
    descricao:    m['descricao'],
    preco:        m['preco'],
    imagemUrl:    m['imagem_url'],
    ingredientes: m['ingredientes'],
    categoryId:   m['category_id'],
    disponivel:   m['disponivel'] == 1,
    isSync:       m['is_sync'] ?? 0,
    createdAt:    m['created_at'],
  );
}