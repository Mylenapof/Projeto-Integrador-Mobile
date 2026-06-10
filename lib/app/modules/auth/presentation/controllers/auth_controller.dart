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
    _logger.info('AuthController', '_inicializar',
        user != null ? 'Sessão restaurada: ${user.email}' : 'Sem sessão ativa');
  }

  Future<String?> login(BuildContext context, String email, String senha) async {
    final (user, error) = await _service.login(email, senha);
    if (error != null) return error;
    state = user;
    return null;
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

  bool get isLogado => state != null;
  UserModel? get usuario => state;
}

// ── Providers ─────────────────────────────────────────────
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authControllerProvider =
    StateNotifierProvider<AuthController, UserModel?>((ref) {
  return AuthController(ref.read(authServiceProvider));
});