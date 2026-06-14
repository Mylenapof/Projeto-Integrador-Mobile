import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/mixins/messages_mixin.dart';
import '../../../../shared/widgets/home/custom_app_bar.dart';
import '../../../../shared/widgets/drawer/custom_app_drawer.dart';
import '../../../../shared/widgets/cards/custom_product_card.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../carrinho/presentation/controllers/cart_controller.dart';
import '../../../produto/presentation/controllers/product_controller.dart';
import '../../../busca_ia/presentation/pages/busca_ia_page.dart';
import '../../../produto/presentation/pages/produto_detalhe_page.dart';
import 'package:go_router/go_router.dart';

class CardapioPage extends ConsumerStatefulWidget {
  const CardapioPage({super.key});

  @override
  ConsumerState<CardapioPage> createState() => _CardapioPageState();
}

class _CardapioPageState extends ConsumerState<CardapioPage>
    with MessagesMixin {
  String _categoriaSelecionada = 'Todos';

  static const _categorias = [
    'Todos',
    'Cupcakes',
    'Bolos',
    'Macarons',
    'Tortas Doces',
    'Salgados',
    'Donuts',
    'Docinhos',
    'Especiais',
  ];

  static const _catMap = {
    'Cupcakes': 1,
    'Bolos': 2,
    'Macarons': 3,
    'Tortas Doces': 4,
    'Salgados': 5,
    'Donuts': 6,
    'Docinhos': 7,
    'Especiais': 8,
  };

  @override
  Widget build(BuildContext context) {
    final produtosAV = ref.watch(productControllerProvider);
    final user = ref.watch(authControllerProvider);
    final cartCount = ref.watch(cartControllerProvider).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const CustomAppDrawer(),
      appBar: CustomAppBar(
        title: 'Lourenço',
        showCart: true,
        cartCount: cartCount,
        onCartTap: () => context.go('/carrinho'),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome, color: AppColors.primary),
            tooltip: 'Busca Inteligente',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BuscaIAPage()),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(
                AppSizes.md, AppSizes.lg, AppSizes.md, AppSizes.sm + 4),
            child: Text(
              'Nosso Cardápio',
              style: TextStyle(
                fontSize: AppSizes.fontXxl,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),

          // Chips de categoria
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              itemCount: _categorias.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSizes.sm),
              itemBuilder: (context, i) {
                final cat = _categorias[i];
                final selected = cat == _categoriaSelecionada;
                return FilterChip(
                  label: Text(cat),
                  selected: selected,
                  onSelected: (_) =>
                      setState(() => _categoriaSelecionada = cat),
                  backgroundColor: AppColors.surface,
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color:
                        selected ? AppColors.surface : AppColors.textSecondary,
                    fontSize: AppSizes.fontXs,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  side: BorderSide(
                    color: selected ? AppColors.primary : AppColors.surfacePink,
                  ),
                  showCheckmark: false,
                );
              },
            ),
          ),
          const SizedBox(height: AppSizes.sm + 4),

          // Grid de produtos
          Expanded(
            child: produtosAV.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (e, _) => Center(
                child: Text('Erro ao carregar: $e',
                    style: const TextStyle(color: AppColors.error)),
              ),
              data: (produtos) {
                final filtrados = _categoriaSelecionada == 'Todos'
                    ? produtos
                    : produtos
                        .where((p) =>
                            p.categoryId == _catMap[_categoriaSelecionada])
                        .toList();

                if (filtrados.isEmpty) {
                  return const Center(
                    child: Text(
                      'Nenhum produto nessa categoria',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppSizes.sm + 4,
                    mainAxisSpacing: AppSizes.sm + 4,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: filtrados.length,
                  itemBuilder: (context, i) {
                    final p = filtrados[i];
                    return CustomProductCard(
                      nome: p.nome,
                      descricao: p.descricao,
                      preco: p.preco,
                      imagemUrl: p.imagemUrl,
                      onVerDetalhes: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ProdutoDetalhePage(produto: p)),
                      ),
                      onAdicionar: () async {
                        if (user == null) {
                          showWarning(
                              context, 'Faça login para adicionar ao carrinho');
                          return;
                        }
                        await ref
                            .read(cartControllerProvider.notifier)
                            .adicionar(p.id!);
                        if (!context.mounted) return;
                        showSuccess(context, '${p.nome} adicionado!');
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
