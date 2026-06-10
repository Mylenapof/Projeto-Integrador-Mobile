import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';

import '../../../../shared/widgets/home/custom_app_bar.dart';
import '../../../../shared/widgets/drawer/custom_app_drawer.dart';
import '../../../../shared/widgets/cards/custom_product_card.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../carrinho/presentation/controllers/cart_controller.dart';
import '../../../produto/presentation/controllers/product_controller.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCount   = ref.watch(cartControllerProvider).length;
    final destaquesAV = ref.watch(destaquesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const CustomAppDrawer(),
      appBar: CustomAppBar(
        title: 'Lourenço',
        showCart: true,
        cartCount: cartCount,
        onCartTap: () => context.go('/carrinho'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner boas-vindas
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(AppSizes.md),
              padding: const EdgeInsets.all(AppSizes.lg),
              decoration: BoxDecoration(
                color: AppColors.surfacePink,
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bem-vindo à\nLourenço Confeitaria',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  const Text(
                    'Doces artesanais feitos com amor e ingredientes selecionados',
                    style: TextStyle(
                      fontSize: AppSizes.fontSm,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),
                  ElevatedButton.icon(
                    onPressed: () => context.go('/cardapio'),
                    icon: const Icon(Icons.arrow_forward, size: 18),
                    label: const Text('Ver Cardápio Completo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSizes.md),
              child: Text(
                'Nossos Destaques',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: AppSizes.sm + 4),

            // Grid de destaques — dados reais do banco
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              child: destaquesAV.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
                error: (e, _) => Center(
                  child: Text('Erro: $e',
                    style: const TextStyle(color: AppColors.error)),
                ),
                data: (destaques) => GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppSizes.sm + 4,
                    mainAxisSpacing: AppSizes.sm + 4,
                    childAspectRatio: 0.78,
                  ),
                  itemCount: destaques.length,
                  itemBuilder: (context, i) {
                    final p = destaques[i];
                    return CustomProductCard(
                      nome:      p.nome,
                      descricao: p.descricao,
                      preco:     p.preco,
                      imagemUrl: p.imagemUrl,
                      onVerDetalhes: () => context.go('/cardapio'),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: AppSizes.lg),
          ],
        ),
      ),
    );
  }
}