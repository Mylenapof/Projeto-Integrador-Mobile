import 'base_model.dart';
import 'base_repository.dart';

abstract class BaseValidation<E extends BaseModel, R extends BaseRepository<E>> {
  final R repository;

  const BaseValidation(this.repository);

  // Retorna null se válido, ou a mensagem de erro
  Future<String?> validateCreate(E entity);
  Future<String?> validateUpdate(E entity);

  // Validações comuns reutilizáveis
  bool isNotEmpty(String? value) => value != null && value.trim().isNotEmpty;

  bool isValidEmail(String? email) {
    if (email == null) return false;
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool hasMinLength(String? value, int min) {
    if (value == null) return false;
    return value.trim().length >= min;
  }
}