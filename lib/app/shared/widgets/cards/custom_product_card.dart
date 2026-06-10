import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_sizes.dart';
import '../buttons/custom_primary_button.dart';
import '../buttons/custom_outlined_button.dart';

class CustomProductCard extends StatelessWidget {
  final String nome;
  final String descricao;
  final double preco;
  final String? imagemUrl;
  final VoidCallback? onVerDetalhes;
  final VoidCallback? onAdicionar;

  const CustomProductCard({
    super.key,
    required this.nome,
    required this.descricao,
    required this.preco,
    this.imagemUrl,
    this.onVerDetalhes,
    this.onAdicionar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.surfacePink, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagem
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppSizes.radiusLg),
            ),
            child: imagemUrl != null
                ? Image.network(
                    imagemUrl!,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder(),
                  )
                : _placeholder(),
          ),

          // Infos
          Padding(
            padding: const EdgeInsets.all(AppSizes.sm + 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nome,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: AppSizes.fontMd,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  descricao,
                  style: const TextStyle(
                    fontSize: AppSizes.fontXs,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSizes.sm),
                Text(
                  'R\$ ${preco.toStringAsFixed(2).replaceAll('.', ',')}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: AppSizes.fontMd,
                  ),
                ),
                const SizedBox(height: AppSizes.sm),
                CustomOutlinedButton(
                  text: 'Ver Detalhes',
                  onPressed: onVerDetalhes,
                  width: double.infinity,
                ),
                if (onAdicionar != null) ...[
                  const SizedBox(height: AppSizes.xs + 2),
                  CustomPrimaryButton(
                    text: 'Adicionar',
                    icon: Icons.add,
                    onPressed: onAdicionar,
                    width: double.infinity,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      height: 120,
      width: double.infinity,
      color: AppColors.surfacePink,
      child: const Icon(
        Icons.cake_outlined,
        size: 40,
        color: AppColors.primaryLight,
      ),
    );
  }
}