import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/order_model.dart';
import '../../domain/order_service.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';

class OrderController extends StateNotifier<List<OrderModel>> {
  final OrderService _service;
  final int? userId;

  OrderController(this._service, this.userId) : super([]) {
    if (userId != null) carregar();
  }

  Future<void> carregar() async {
    if (userId == null) return;
    state = await _service.getByUser(userId!);
  }

  Future<String?> enviar(OrderModel order) async {
    final (_, error) = await _service.enviar(order);
    if (error == null) await carregar();
    return error;
  }
}

// ── Controller para o admin ver/responder todas as encomendas ──
class AdminOrderController extends StateNotifier<List<OrderModel>> {
  final OrderService _service;

  AdminOrderController(this._service) : super([]) {
    carregar();
  }

  Future<void> carregar() async {
    state = await _service.getTodas();
  }

  Future<String?> responderOrcamento(int orderId, double valor, String resposta) async {
    final erro = await _service.responderOrcamento(orderId, valor, resposta);
    if (erro == null) await carregar();
    return erro;
  }
}

// ── Providers ─────────────────────────────────────────────
final orderServiceProvider = Provider<OrderService>((ref) => OrderService());

final orderControllerProvider =
    StateNotifierProvider<OrderController, List<OrderModel>>((ref) {
  final user = ref.watch(authControllerProvider);
  return OrderController(ref.read(orderServiceProvider), user?.id);
});

final adminOrderControllerProvider =
    StateNotifierProvider<AdminOrderController, List<OrderModel>>((ref) {
  return AdminOrderController(ref.read(orderServiceProvider));
});