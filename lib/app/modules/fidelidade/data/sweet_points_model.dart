import '../../../core/base/base_model.dart';

class SweetPointsModel extends BaseModel {
  final int userId;
  final int pontos;

  const SweetPointsModel({
    super.id,
    required this.userId,
    required this.pontos,
    super.isSync,
    super.createdAt,
  });

  @override
  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'user_id':    userId,
    'pontos':     pontos,
    'is_sync':    isSync,
    'created_at': createdAt ?? DateTime.now().toIso8601String(),
  };

  factory SweetPointsModel.fromMap(Map<String, dynamic> m) => SweetPointsModel(
    id:        m['id'],
    userId:    m['user_id'],
    pontos:    m['pontos'],
    isSync:    m['is_sync'] ?? 0,
    createdAt: m['created_at'],
  );
}