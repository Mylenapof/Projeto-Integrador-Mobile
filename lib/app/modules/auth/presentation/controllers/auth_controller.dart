import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/mixins/messages_mixin.dart';
import '../../../../core/logging/log_service.dart';
import '../../data/user_model.dart';
import '../../domain/auth_service.dart';

class AuthController extends StateNotifier<UserModel?> with MessagesMixin {
  final AuthService _service;
  final LogService _logger = LogService();

  AuthController(this._service) : super(null) {
    _inicializar();
  }

  Future<void> _inicializar() async {
    final user = await _service.carregarSessao();
    state = user;
  }

  // Retorna: (erro, isAdmin)
  Future<(String?, bool)> login(
      BuildContext context, String email, String senha) async {
    final (user, error, isAdmin) = await _service.login(email, senha);
    if (error != null) return (error, false);
    if (isAdmin) return (null, true); // ← sinaliza que é admin
    state = user;
    return (null, false);
  }

  Future<String?> cadastrar(
      BuildContext context, String nome, String email, String senha) async {
    final (user, error) = await _service.cadastrar(nome, email, senha);
    if (error != null) return error;
    state = user;
    return null;
  }

  Future<void> logout() async {
    await _service.logout();
    state = null;
  }

  Future<String?> atualizarPerfil(UserModel user) async {
    final erro = await _service.atualizarPerfil(user);
    if (erro == null) state = user;
    return erro;
  }

  Future<String?> alterarSenha(String senhaAtual, String novaSenha) async {
    if (state == null) return 'Usuário não logado';
    return _service.alterarSenha(state!.id!, senhaAtual, novaSenha);
  }

  bool get isLogado => state != null;
  UserModel? get usuario => state;
}

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authControllerProvider =
    StateNotifierProvider<AuthController, UserModel?>((ref) {
  return AuthController(ref.read(authServiceProvider));
});
