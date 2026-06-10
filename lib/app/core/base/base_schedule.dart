import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../logging/log_service.dart';
import 'base_model.dart';
import 'base_repository.dart';
import 'base_provider.dart';

abstract class BaseSchedule<
    E extends BaseModel,
    R extends BaseRepository<E>,
    P extends BaseProvider<E>> {
  final R repository;
  final P provider;
  final LogService _logger = LogService();

  Timer? _timer;
  bool _isSyncing = false;

  static const _interval = Duration(minutes: 5);

  BaseSchedule(this.repository, this.provider);

  String get featureName;

  // ── Inicia o agendamento periódico ────────────────────────
  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(_interval, (_) => syncNow());
    _logger.info(featureName, 'start', 'Agendamento iniciado — intervalo: 5min');
  }

  // ── Para o agendamento ────────────────────────────────────
  void stop() {
    _timer?.cancel();
    _timer = null;
    _logger.info(featureName, 'stop', 'Agendamento parado');
  }

  // ── Sincronização manual/forçada ──────────────────────────
  Future<void> syncNow() async {
    if (_isSyncing) return;

    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      _logger.info(featureName, 'syncNow', 'Sem conexão — sincronização ignorada');
      return;
    }

    _isSyncing = true;
    _logger.info(featureName, 'syncNow', 'Iniciando sincronização');

    try {
      final pending = await repository.findPendingSync();
      _logger.info(featureName, 'syncNow', '${pending.length} item(s) pendente(s)');

      for (final entity in pending) {
        final valid = await provider.validateBeforeSync(entity);
        if (!valid) continue;

        final success = await provider.sync(entity);
        if (success && entity.id != null) {
          await repository.markAsSynced(entity.id!);
        }
      }

      _logger.info(featureName, 'syncNow', 'Sincronização concluída');
    } catch (e) {
      _logger.error(featureName, 'syncNow', 'Erro na sincronização: $e');
    } finally {
      _isSyncing = false;
    }
  }

  bool get isRunning => _timer?.isActive ?? false;
}