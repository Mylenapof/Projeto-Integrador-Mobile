import '../../../core/helpers/database_helper.dart';
import '../../../core/logging/log_service.dart';
import '../../../core/base/base_repository.dart';
import '../../../core/base/base_model.dart';
import '../data/recompensa_model.dart';
import '../data/recompensa_repository.dart';
import 'package:lourenco_confeitaria_app/app/modules/produto/data/product_model.dart';
import 'package:lourenco_confeitaria_app/app/modules/produto/data/product_repository.dart';

class AdminService {
  final _db = DatabaseHelper.instance;
  final _recompensaRepo = RecompensaRepository();
  final _productRepo = ProductRepository();
  final _logger = LogService();
  Future<bool> login(String email, String senha) async {
    try {
      final db = await _db.database;

      final todosAdmins = await db.query('admins');

      print("========= ADMINS NO BANCO =========");
      print(todosAdmins);

      print("EMAIL DIGITADO: $email");
      print("SENHA DIGITADA: $senha");

      final resultado = await db.query(
        'admins',
        where: 'email = ? AND senha = ?',
        whereArgs: [
          email.trim(),
          senha.trim(),
        ],
      );

      print("========= RESULTADO LOGIN =========");
      print(resultado);

      return resultado.isNotEmpty;
    } catch (e) {
      print("ERRO LOGIN: $e");
      return false;
    }
  }

  // ── Produtos ─────────────────────────────────────────────
  Future<List<ProductModel>> getProdutos() => _productRepo.findAll();

  Future<String?> salvarProduto(ProductModel produto) async {
    try {
      if (produto.id == null) {
        await _productRepo.insert(produto);
      } else {
        await _productRepo.update(produto);
      }
      _logger.info(
          'AdminService', 'salvarProduto', 'Produto salvo: ${produto.nome}');
      return null;
    } catch (e) {
      _logger.error('AdminService', 'salvarProduto', e.toString());
      return 'Erro ao salvar produto';
    }
  }

  Future<String?> excluirProduto(int id) async {
    try {
      await _productRepo.delete(id);
      return null;
    } catch (e) {
      return 'Erro ao excluir produto';
    }
  }

  // ── Recompensas ───────────────────────────────────────────
  Future<List<RecompensaModel>> getRecompensas() => _recompensaRepo.findAll();

  Future<String?> salvarRecompensa(RecompensaModel recompensa) async {
    try {
      if (recompensa.id == null) {
        await _recompensaRepo.insert(recompensa);
      } else {
        await _recompensaRepo.update(recompensa);
      }
      _logger.info('AdminService', 'salvarRecompensa', 'Recompensa salva');
      return null;
    } catch (e) {
      _logger.error('AdminService', 'salvarRecompensa', e.toString());
      return 'Erro ao salvar recompensa';
    }
  }

  Future<String?> excluirRecompensa(int id) async {
    try {
      await _recompensaRepo.delete(id);
      return null;
    } catch (e) {
      return 'Erro ao excluir recompensa';
    }
  }
  Future<void> salvarFcmToken(String email, String token) async {
  try {
    final db = await _db.database;
    await db.update(
      'admins',
      {'fcm_token': token},
      where: 'email = ?',
      whereArgs: [email.trim()],
    );
  } catch (e) {
    print("ERRO AO SALVAR FCM TOKEN ADMIN: $e");
  }
}

Future<String?> getFcmToken() async {
  try {
    final db = await _db.database;
    final resultado = await db.query('admins', columns: ['fcm_token']);
    if (resultado.isEmpty) return null;
    return resultado.first['fcm_token'] as String?;
  } catch (e) {
    return null;
  }
}
}
