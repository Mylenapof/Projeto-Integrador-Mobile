import '../http/app_client.dart';
import '../logging/log_service.dart';
import 'base_model.dart';

abstract class BaseProvider<E extends BaseModel> {
  final AppClient _client = AppClient();
  final LogService _logger = LogService();

  String get endpoint;

  E fromMap(Map<String, dynamic> map);

  // ── GET ───────────────────────────────────────────────────
  Future<List<E>> fetchAll({Map<String, dynamic>? params}) async {
    try {
      final response = await _client.get(endpoint, queryParameters: params);
      final list = response.data as List;
      return list.map((e) => fromMap(e as Map<String, dynamic>)).toList();
    } catch (e) {
      handleError('fetchAll', e);
      return [];
    }
  }

  Future<E?> fetchById(int id) async {
    try {
      final response = await _client.get('$endpoint/$id');
      return fromMap(response.data as Map<String, dynamic>);
    } catch (e) {
      handleError('fetchById', e);
      return null;
    }
  }

  // ── POST ──────────────────────────────────────────────────
  Future<bool> sync(E entity) async {
    try {
      await _client.post(endpoint, entity.toMap());
      return true;
    } catch (e) {
      handleError('sync', e);
      return false;
    }
  }

  // ── PUT ───────────────────────────────────────────────────
  Future<bool> update(E entity) async {
    try {
      await _client.put('$endpoint/${entity.id}', entity.toMap());
      return true;
    } catch (e) {
      handleError('update', e);
      return false;
    }
  }

  // ── DELETE ────────────────────────────────────────────────
  Future<bool> remove(int id) async {
    try {
      await _client.delete('$endpoint/$id');
      return true;
    } catch (e) {
      handleError('remove', e);
      return false;
    }
  }

  // ── Validação antes de sincronizar ────────────────────────
  Future<bool> validateBeforeSync(E entity) async => true;

  // ── Log centralizado ──────────────────────────────────────
  void handleError(String operation, Object error) {
    _logger.error(
      runtimeType.toString(),
      operation,
      error.toString(),
    );
  }
}