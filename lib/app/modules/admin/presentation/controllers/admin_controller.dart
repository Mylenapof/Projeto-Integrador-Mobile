import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/admin_service.dart';
import '../../data/recompensa_model.dart';
import 'package:lourenco_confeitaria_app/app/modules/produto/data/product_model.dart';

class AdminController extends StateNotifier<bool> {
  final AdminService _service;

  AdminController(this._service) : super(false);

  bool get isLogado => state;

  Future<bool> login(String email, String senha) async {
    final ok = await _service.login(email, senha);
    state = ok;
    return ok;
  }

  void logout() => state = false;

  // Produtos
  Future<List<ProductModel>> getProdutos() => _service.getProdutos();
  Future<String?> salvarProduto(ProductModel p) => _service.salvarProduto(p);
  Future<String?> excluirProduto(int id) => _service.excluirProduto(id);

  // Recompensas
  Future<List<RecompensaModel>> getRecompensas() => _service.getRecompensas();
  Future<String?> salvarRecompensa(RecompensaModel r) => _service.salvarRecompensa(r);
  Future<String?> excluirRecompensa(int id) => _service.excluirRecompensa(id);
}

final adminServiceProvider    = Provider<AdminService>((ref) => AdminService());
final adminControllerProvider = StateNotifierProvider<AdminController, bool>(
  (ref) => AdminController(ref.read(adminServiceProvider)),
);