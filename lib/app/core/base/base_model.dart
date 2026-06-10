abstract class BaseModel {
  final int? id;
  final int isSync;
  final String createdAt;

  const BaseModel({
    this.id,
    this.isSync = 0,
    String? createdAt,
  }) : createdAt = createdAt ?? '';

  Map<String, dynamic> toMap();

  bool get isSynced => isSync == 1;
  bool get isPendingSync => isSync == 0;
}