import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_sizes.dart';

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
        mainAxisSize: MainAxisSize.min,
        children: [
          // Imagem com altura fixa e controlada
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppSizes.radiusLg),
            ),
            child: SizedBox(
              height: 100,
              width: double.infinity,
              child: imagemUrl != null
                  ? Image.network(
                      imagemUrl!,
                      height: 100,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(),
                    )
                  : _placeholder(),
            ),
          ),

          // Conteúdo
          Padding(
            padding: const EdgeInsets.all(AppSizes.sm + 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Nome
                Text(
                  nome,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: AppSizes.fontSm,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),

                // Descrição
                Text(
                  descricao,
                  style: const TextStyle(
                    fontSize: AppSizes.fontXs,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSizes.xs + 2),

                // Preço
                Text(
                  'R\$ ${preco.toStringAsFixed(2).replaceAll('.', ',')}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: AppSizes.fontMd,
                  ),
                ),
                const SizedBox(height: AppSizes.xs + 2),

                // Botão Ver Detalhes
                SizedBox(
                  width: double.infinity,
                  height: 32,
                  child: OutlinedButton(
                    onPressed: onVerDetalhes,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                      ),
                      textStyle: const TextStyle(
                        fontSize: AppSizes.fontXs,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: const Text('Ver Detalhes'),
                  ),
                ),

                // Botão Adicionar
                if (onAdicionar != null) ...[
                  const SizedBox(height: AppSizes.xs),
                  SizedBox(
                    width: double.infinity,
                    height: 32,
                    child: ElevatedButton.icon(
                      onPressed: onAdicionar,
                      icon: const Icon(Icons.add, size: 14),
                      label: const Text('Adicionar'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusFull),
                        ),
                        textStyle: const TextStyle(
                          fontSize: AppSizes.fontXs,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
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
      height: 100,
      width: double.infinity,
      color: AppColors.surfacePink,
      child: const Icon(
        Icons.cake_outlined,
        size: 36,
        color: AppColors.primaryLight,
      ),
    );
  }
}