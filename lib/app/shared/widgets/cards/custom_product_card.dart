import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
          // Imagem
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppSizes.radiusLg),
            ),
            child: SizedBox(
              height: 95,
              width: double.infinity,
              child: imagemUrl != null
                  ? CachedNetworkImage(
                      imageUrl: imagemUrl!,
                      height: 95,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        height: 95,
                        color: AppColors.surfacePink,
                        child: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primaryLight,
                            ),
                          ),
                        ),
                      ),
                      errorWidget: (_, __, ___) => _placeholder(),
                    )
                  : _placeholder(),
            ),
          ),

          // Conteúdo
          Padding(
            padding: const EdgeInsets.all(10),
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
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Preço
                Text(
                  'R\$ ${preco.toStringAsFixed(2).replaceAll('.', ',')}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: AppSizes.fontMd,
                  ),
                ),
                const SizedBox(height: 4),

                // Botão Ver Detalhes
                SizedBox(
                  width: double.infinity,
                  height: 30,
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
                  const SizedBox(height: 4),
                  SizedBox(
                    width: double.infinity,
                    height: 30,
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
      height: 95,
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