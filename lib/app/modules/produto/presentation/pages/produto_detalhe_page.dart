import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/mixins/messages_mixin.dart';
import '../../../../shared/widgets/buttons/custom_primary_button.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../carrinho/presentation/controllers/cart_controller.dart';
import '../../data/product_model.dart';

class ProdutoDetalhePage extends ConsumerWidget with MessagesMixin {
  final ProductModel produto;

  const ProdutoDetalhePage({super.key, required this.produto});

  static const _categoriaNomes = {
    1: 'Cupcakes',     2: 'Bolos',    3: 'Macarons',
    4: 'Tortas Doces', 5: 'Salgados', 6: 'Donuts',
    7: 'Docinhos',     8: 'Especiais',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Imagem grande com app bar sobreposta
          SliverAppBar(
            backgroundColor: AppColors.surface,
            expandedHeight: 260,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.primary),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: produto.imagemUrl != null
                  ? Image.network(
                      produto.imagemUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(),
                    )
                  : _placeholder(),
            ),
          ),

          // Conteúdo
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categoria
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.sm + 4, vertical: AppSizes.xs),
                    decoration: BoxDecoration(
                      color: AppColors.surfacePink,
                      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                    ),
                    child: Text(
                      _categoriaNomes[produto.categoryId] ?? 'Produto',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: AppSizes.fontXs,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm + 4),

                  // Nome
                  Text(
                    produto.nome,
                    style: const TextStyle(
                      fontSize: AppSizes.fontXxl,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.xs),

                  // Preço
                  Text(
                    'R\$ ${produto.preco.toStringAsFixed(2).replaceAll('.', ',')}',
                    style: const TextStyle(
                      fontSize: AppSizes.fontXxl,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.lg),

                  // Descrição
                  const Text(
                    'Descrição',
                    style: TextStyle(
                      fontSize: AppSizes.fontLg,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  Text(
                    produto.descricao,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: AppSizes.fontMd,
                      height: 1.5,
                    ),
                  ),

                  // Ingredientes
                  if (produto.ingredientes != null &&
                      produto.ingredientes!.isNotEmpty) ...[
                    const SizedBox(height: AppSizes.lg),
                    const Text(
                      'Ingredientes',
                      style: TextStyle(
                        fontSize: AppSizes.fontLg,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.sm),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSizes.md),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                        border: Border.all(color: AppColors.surfacePink),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.eco_outlined,
                              color: AppColors.primary, size: 20),
                          const SizedBox(width: AppSizes.sm),
                          Expanded(
                            child: Text(
                              produto.ingredientes!,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: AppSizes.fontSm,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Disponibilidade
                  const SizedBox(height: AppSizes.lg),
                  Row(
                    children: [
                      Icon(
                        produto.disponivel
                            ? Icons.check_circle
                            : Icons.cancel,
                        color: produto.disponivel
                            ? AppColors.success
                            : AppColors.error,
                        size: 20,
                      ),
                      const SizedBox(width: AppSizes.sm),
                      Text(
                        produto.disponivel
                            ? 'Disponível'
                            : 'Indisponível no momento',
                        style: TextStyle(
                          color: produto.disponivel
                              ? AppColors.success
                              : AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.xxl),

                  // Botão adicionar
                  CustomPrimaryButton(
                    text: 'Adicionar ao Carrinho',
                    icon: Icons.add_shopping_cart,
                    onPressed: !produto.disponivel
                        ? null
                        : () async {
                            if (user == null) {
                              showWarning(context,
                                  'Faça login para adicionar ao carrinho');
                              return;
                            }
                            await ref
                                .read(cartControllerProvider.notifier)
                                .adicionar(produto.id!);
                            if (!context.mounted) return;
                            showSuccess(
                                context, '${produto.nome} adicionado!');
                          },
                  ),
                  const SizedBox(height: AppSizes.md),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.surfacePink,
      child: const Center(
        child: Icon(
          Icons.cake_outlined,
          size: 80,
          color: AppColors.primaryLight,
        ),
      ),
    );
  }
}