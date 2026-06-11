import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/sweet_points_model.dart';
import '../../domain/points_service.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../admin/data/recompensa_model.dart';
import '../../../admin/data/recompensa_repository.dart';

class PointsController extends StateNotifier<SweetPointsModel?> {
  final PointsService _service;
  final int? userId;

  PointsController(this._service, this.userId) : super(null) {
    if (userId != null) carregar();
  }

  Future<void> carregar() async {
    if (userId == null) return;
    state = await _service.getByUser(userId!);
  }

  Future<String?> adicionar(int pontos) async {
    if (userId == null) return 'Faça login para acumular pontos';
    final erro = await _service.adicionar(userId!, pontos);
    if (erro == null) await carregar();
    return erro;
  }

  Future<String?> resgatar(int pontos) async {
    if (userId == null) return 'Faça login para resgatar pontos';
    final erro = await _service.resgatar(userId!, pontos);
    if (erro == null) await carregar();
    return erro;
  }

  int get pontos => state?.pontos ?? 0;
}

// ── Providers ─────────────────────────────────────────────
final pointsServiceProvider =
    Provider<PointsService>((ref) => PointsService());

final pointsControllerProvider =
    StateNotifierProvider<PointsController, SweetPointsModel?>((ref) {
  final user = ref.watch(authControllerProvider);
  return PointsController(ref.read(pointsServiceProvider), user?.id);
});

// Provider de recompensas ativas do banco
final recompensasProvider = FutureProvider<List<RecompensaModel>>((ref) async {
  return RecompensaRepository().findAtivas();
});