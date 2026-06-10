import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/cart_item_model.dart';
import '../../domain/cart_service.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';

class CartController extends StateNotifier<List<CartItemModel>> {
  final CartService _service;
  final int? userId;

  CartController(this._service, this.userId) : super([]) {
    if (userId != null) carregar();
  }

  Future<void> carregar() async {
    if (userId == null) return;
    state = await _service.getItens(userId!);
  }

  Future<void> adicionar(int productId) async {
    if (userId == null) return;
    await _service.adicionar(userId!, productId);
    await carregar();
  }

  Future<void> diminuir(int itemId, int quantidade) async {
    await _service.diminuir(itemId, quantidade);
    await carregar();
  }

  Future<void> remover(int itemId) async {
    await _service.remover(itemId);
    await carregar();
  }

  Future<void> limpar() async {
    if (userId == null) return;
    await _service.limpar(userId!);
    state = [];
  }

  double get total => state.fold(0, (sum, item) => sum + item.total);
  int get quantidade => state.length;
}

// ── Providers ─────────────────────────────────────────────
final cartServiceProvider = Provider<CartService>((ref) => CartService());

final cartControllerProvider =
    StateNotifierProvider<CartController, List<CartItemModel>>((ref) {
  final user = ref.watch(authControllerProvider);
  return CartController(ref.read(cartServiceProvider), user?.id);
});