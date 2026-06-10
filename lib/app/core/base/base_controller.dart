import 'package:flutter/material.dart';
import '../mixins/loader_mixin.dart';
import '../mixins/messages_mixin.dart';
import 'base_model.dart';
import 'base_repository.dart';
import 'base_validation.dart';
import 'base_service.dart';

abstract class BaseController<
    E extends BaseModel,
    R extends BaseRepository<E>,
    V extends BaseValidation<E, R>,
    S extends BaseService<E, R, V>> extends ChangeNotifier
    with LoaderMixin, MessagesMixin {
  final S service;

  List<E> items = [];
  bool isLoading = false;

  BaseController(this.service);

  // ── Operação genérica com loader + mensagem ───────────────
  Future<T?> executeOperation<T>(
    BuildContext context,
    Future<T> Function() operation, {
    String? successMessage,
    bool showLoader = true,
  }) async {
    if (showLoader) {
      isLoading = true;
      notifyListeners();
      showLoading(context);
    }

    try {
      final result = await operation();
      if (successMessage != null && context.mounted) {
        showSuccess(context, successMessage);
      }
      return result;
    } catch (e) {
      if (context.mounted) {
        showError(context, 'Erro inesperado: ${e.toString()}');
      }
      return null;
    } finally {
      if (showLoader) {
        isLoading = false;
        notifyListeners();
        if (context.mounted) hideLoading(context);
      }
    }
  }

  // ── Carregar lista ────────────────────────────────────────
  Future<void> executeListOperation(BuildContext context) async {
    await executeOperation(context, () async {
      items = await service.getAll();
      notifyListeners();
    });
  }

  // ── CRUD completo com feedback ────────────────────────────
  Future<bool> executeCrudOperation(
    BuildContext context,
    Future<String?> Function() operation, {
    required String successMessage,
  }) async {
    String? error;

    await executeOperation(context, () async {
      error = await operation();
    });

    if (error != null && context.mounted) {
      showError(context, error!);
      return false;
    }

    if (context.mounted) showSuccess(context, successMessage);
    return true;
  }
}