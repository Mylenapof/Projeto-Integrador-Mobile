import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_sizes.dart';
import '../buttons/custom_primary_button.dart';

class CustomSuccessDialog extends StatelessWidget {
  final String titulo;
  final String mensagem;
  final VoidCallback? onOk;

  const CustomSuccessDialog({
    super.key,
    required this.titulo,
    required this.mensagem,
    this.onOk,
  });

  static Future<void> show(
    BuildContext context, {
    required String titulo,
    required String mensagem,
    VoidCallback? onOk,
  }) {
    return showDialog(
      context: context,
      builder: (_) => CustomSuccessDialog(
        titulo: titulo,
        mensagem: mensagem,
        onOk: onOk,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      title: const Row(
        children: [
          Icon(Icons.check_circle, color: AppColors.success),
          SizedBox(width: AppSizes.sm),
          Text(
            'Sucesso!',
            style: TextStyle(color: AppColors.primary, fontSize: AppSizes.fontXl),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.xs),
          Text(
            mensagem,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
      actions: [
        CustomPrimaryButton(
          text: 'OK',
          onPressed: () {
            Navigator.pop(context);
            onOk?.call();
          },
          width: double.infinity,
        ),
      ],
      actionsPadding: const EdgeInsets.fromLTRB(
        AppSizes.md, 0, AppSizes.md, AppSizes.md,
      ),
    );
  }
}