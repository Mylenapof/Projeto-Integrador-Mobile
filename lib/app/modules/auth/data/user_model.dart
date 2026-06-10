import '../../../core/base/base_model.dart';

class UserModel extends BaseModel {
  final String nome;
  final String email;
  final String senha;

  const UserModel({
    super.id,
    required this.nome,
    required this.email,
    required this.senha,
    super.isSync,
    super.createdAt,
  });

  @override
  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'nome':       nome,
    'email':      email,
    'senha':      senha,
    'is_sync':    isSync,
    'created_at': createdAt,
  };

  factory UserModel.fromMap(Map<String, dynamic> m) => UserModel(
    id:        m['id'],
    nome:      m['nome'],
    email:     m['email'],
    senha:     m['senha'],
    isSync:    m['is_sync'] ?? 0,
    createdAt: m['created_at'],
  );

  UserModel copyWith({
    int? id, String? nome, String? email, String? senha,
    int? isSync, String? createdAt,
  }) => UserModel(
    id:        id        ?? this.id,
    nome:      nome      ?? this.nome,
    email:     email     ?? this.email,
    senha:     senha     ?? this.senha,
    isSync:    isSync    ?? this.isSync,
    createdAt: createdAt ?? this.createdAt,
  );
}