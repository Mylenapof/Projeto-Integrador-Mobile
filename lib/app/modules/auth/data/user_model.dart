import '../../../core/base/base_model.dart';

class UserModel extends BaseModel {
  final String nome;
  final String email;
  final String senha;
  final String? endereco;
  final String? telefone;

  const UserModel({
    super.id,
    required this.nome,
    required this.email,
    required this.senha,
    this.endereco,
    this.telefone,
    super.isSync,
    super.createdAt,
  });

  @override
  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'nome':       nome,
    'email':      email,
    'senha':      senha,
    'endereco':   endereco,
    'telefone':   telefone,
    'is_sync':    isSync,
    'created_at': createdAt,
  };

  factory UserModel.fromMap(Map<String, dynamic> m) => UserModel(
    id:        m['id'],
    nome:      m['nome'],
    email:     m['email'],
    senha:     m['senha'],
    endereco:  m['endereco'],
    telefone:  m['telefone'],
    isSync:    m['is_sync'] ?? 0,
    createdAt: m['created_at'],
  );

  UserModel copyWith({
    int? id, String? nome, String? email, String? senha,
    String? endereco, String? telefone,
    int? isSync, String? createdAt,
  }) => UserModel(
    id:        id        ?? this.id,
    nome:      nome      ?? this.nome,
    email:     email     ?? this.email,
    senha:     senha     ?? this.senha,
    endereco:  endereco  ?? this.endereco,
    telefone:  telefone  ?? this.telefone,
    isSync:    isSync    ?? this.isSync,
    createdAt: createdAt ?? this.createdAt,
  );
}