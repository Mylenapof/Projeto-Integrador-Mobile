import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

mixin MessagesMixin {
  // Sucesso — fecha automaticamente em 3s
  void showSuccess(BuildContext context, String message) {
    _show(
      context,
      message: message,
      color: AppColors.success,
      icon: Icons.check_circle_outline,
      duration: const Duration(seconds: 3),
    );
  }

  // Erro — fecha manualmente (ação obrigatória)
  void showError(BuildContext context, String message) {
    _show(
      context,
      message: message,
      color: AppColors.error,
      icon: Icons.error_outline,
      duration: const Duration(seconds: 6),
    );
  }

  // Aviso — fecha automaticamente em 4s
  void showWarning(BuildContext context, String message) {
    _show(
      context,
      message: message,
      color: AppColors.warning,
      icon: Icons.warning_amber_outlined,
      duration: const Duration(seconds: 4),
    );
  }

  void _show(
    BuildContext context, {
    required String message,
    required Color color,
    required IconData icon,
    required Duration duration,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}