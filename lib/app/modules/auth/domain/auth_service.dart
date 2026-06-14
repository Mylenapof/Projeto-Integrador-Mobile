import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/base/base_service.dart';
import '../../../core/helpers/database_helper.dart';
import '../../../core/logging/log_service.dart';
import '../data/user_model.dart';
import '../data/user_repository.dart';
import '../domain/user_validation.dart';

class AuthService extends BaseService<UserModel, UserRepository, UserValidation> {
  final LogService _logger = LogService();
  final _db = DatabaseHelper.instance;

  AuthService()
      : super(UserRepository(), UserValidation(UserRepository()));

  // ── Login — verifica admin primeiro, depois usuário ───────
  Future<(UserModel?, String?, bool isAdmin)> login(String email, String senha) async {
    final validationError = await validation.validateLogin(email, senha);
    if (validationError != null) return (null, validationError, false);

    try {
      // 1) Verifica na tabela admins
      final db = await _db.database;
      final adminResult = await db.query(
        'admins',
        where: 'email = ? AND senha = ?',
        whereArgs: [email.trim(), senha.trim()],
        limit: 1,
      );

      if (adminResult.isNotEmpty) {
        _logger.info('AuthService', 'login', 'Login admin: $email');
        // Admin não precisa de sessão de usuário
        return (null, null, true);
      }

      // 2) Verifica na tabela users
      final user = await repository.findByEmailAndSenha(email, senha);
      if (user == null) return (null, 'E-mail ou senha incorretos', false);

      await _salvarSessao(user.id!);
      _logger.info('AuthService', 'login', 'Login usuário: ${user.email}');
      return (user, null, false);
    } catch (e) {
      _logger.error('AuthService', 'login', e.toString());
      return (null, 'Erro ao fazer login', false);
    }
  }

  // ── Cadastro ──────────────────────────────────────────────
  Future<(UserModel?, String?)> cadastrar(
      String nome, String email, String senha) async {
    final user = UserModel(
      nome:      nome,
      email:     email,
      senha:     senha,
      createdAt: DateTime.now().toIso8601String(),
    );

    final (id, error) = await create(user);
    if (error != null) return (null, error);

    final criado = await repository.findById(id!);
    if (criado == null) return (null, 'Erro ao criar conta');

    await _salvarSessao(criado.id!);
    _logger.info('AuthService', 'cadastrar', 'Cadastro realizado: $email');
    return (criado, null);
  }

  // ── Sessão ────────────────────────────────────────────────
  Future<UserModel?> carregarSessao() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getInt('user_id');
      if (id == null) return null;
      return repository.findById(id);
    } catch (e) {
      _logger.error('AuthService', 'carregarSessao', e.toString());
      return null;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    _logger.info('AuthService', 'logout', 'Sessão encerrada');
  }

  Future<void> _salvarSessao(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', userId);
  }
}