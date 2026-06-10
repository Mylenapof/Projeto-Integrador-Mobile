import 'base_model.dart';
import 'base_repository.dart';
import 'base_validation.dart';

abstract class BaseService<
    E extends BaseModel,
    R extends BaseRepository<E>,
    V extends BaseValidation<E, R>> {
  final R repository;
  final V validation;

  const BaseService(this.repository, this.validation);

  // ── CREATE ────────────────────────────────────────────────
  Future<(int?, String?)> create(E entity) async {
    final error = await validation.validateCreate(entity);
    if (error != null) return (null, error);

    try {
      final id = await repository.insert(entity);
      return (id, null);
    } catch (e) {
      return (null, 'Erro ao salvar: ${e.toString()}');
    }
  }

  // ── UPDATE ────────────────────────────────────────────────
  Future<String?> update(E entity) async {
    final error = await validation.validateUpdate(entity);
    if (error != null) return error;

    try {
      await repository.update(entity);
      return null;
    } catch (e) {
      return 'Erro ao atualizar: ${e.toString()}';
    }
  }

  // ── DELETE ────────────────────────────────────────────────
  Future<String?> remove(int id) async {
    try {
      await repository.delete(id);
      return null;
    } catch (e) {
      return 'Erro ao remover: ${e.toString()}';
    }
  }

  // ── READ ──────────────────────────────────────────────────
  Future<List<E>> getAll() => repository.findAll();

  Future<E?> getById(int id) => repository.findById(id);
}