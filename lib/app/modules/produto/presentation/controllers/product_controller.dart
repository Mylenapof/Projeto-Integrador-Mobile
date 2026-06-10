import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/product_model.dart';
import '../../domain/product_service.dart';

class ProductController extends StateNotifier<AsyncValue<List<ProductModel>>> {
  final ProductService _service;

  ProductController(this._service) : super(const AsyncValue.loading()) {
    carregar();
  }

  Future<void> carregar() async {
    state = const AsyncValue.loading();
    try {
      final produtos = await _service.getDisponiveis();
      state = AsyncValue.data(produtos);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<List<ProductModel>> getByCategoria(int categoryId) =>
      _service.getByCategoria(categoryId);

  Future<List<ProductModel>> getDestaques() =>
      _service.getDestaques();
}

// ── Providers ─────────────────────────────────────────────
final productServiceProvider =
    Provider<ProductService>((ref) => ProductService());

final productControllerProvider = StateNotifierProvider<ProductController,
    AsyncValue<List<ProductModel>>>((ref) {
  return ProductController(ref.read(productServiceProvider));
});

// Provider de destaques para a home
final destaquesProvider = FutureProvider<List<ProductModel>>((ref) async {
  return ref.read(productServiceProvider).getDestaques();
});