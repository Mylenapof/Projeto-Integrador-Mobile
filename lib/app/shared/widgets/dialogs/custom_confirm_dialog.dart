import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_sizes.dart';
import '../buttons/custom_primary_button.dart';
import '../buttons/custom_outlined_button.dart';

class CustomConfirmDialog extends StatelessWidget {
  final String titulo;
  final String mensagem;
  final String textoBotaoConfirmar;
  final String textoBotaoCancelar;
  final VoidCallback onConfirmar;
  final IconData? icon;
  final Color? iconColor;

  const CustomConfirmDialog({
    super.key,
    required this.titulo,
    required this.mensagem,
    required this.onConfirmar,
    this.textoBotaoConfirmar = 'Confirmar',
    this.textoBotaoCancelar = 'Cancelar',
    this.icon,
    this.iconColor,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String titulo,
    required String mensagem,
    required VoidCallback onConfirmar,
    String textoBotaoConfirmar = 'Confirmar',
    String textoBotaoCancelar = 'Cancelar',
    IconData? icon,
    Color? iconColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => CustomConfirmDialog(
        titulo: titulo,
        mensagem: mensagem,
        onConfirmar: onConfirmar,
        textoBotaoConfirmar: textoBotaoConfirmar,
        textoBotaoCancelar: textoBotaoCancelar,
        icon: icon,
        iconColor: iconColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      title: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: iconColor ?? AppColors.primary),
            const SizedBox(width: AppSizes.sm),
          ],
          Text(
            titulo,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: AppSizes.fontXl,
            ),
          ),
        ],
      ),
      content: Text(
        mensagem,
        style: const TextStyle(color: AppColors.textSecondary),
      ),
      actions: [
        CustomOutlinedButton(
          text: textoBotaoCancelar,
          onPressed: () => Navigator.pop(context, false),
          width: 110,
        ),
        const SizedBox(width: AppSizes.sm),
        CustomPrimaryButton(
          text: textoBotaoConfirmar,
          onPressed: () {
            Navigator.pop(context, true);
            onConfirmar();
          },
          width: 130,
        ),
      ],
      actionsPadding: const EdgeInsets.fromLTRB(
        AppSizes.md, 0, AppSizes.md, AppSizes.md,
      ),
    );
  }
}