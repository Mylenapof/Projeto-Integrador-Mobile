import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/mixins/messages_mixin.dart';
import '../../../../shared/widgets/buttons/custom_primary_button.dart';
import '../../../../shared/widgets/dialogs/custom_confirm_dialog.dart';
import '../../../admin/data/recompensa_model.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/cart_controller.dart';
import '../../../fidelidade/presentation/controllers/points_controller.dart';

class CarrinhoPage extends ConsumerStatefulWidget {
  const CarrinhoPage({super.key});

  @override
  ConsumerState<CarrinhoPage> createState() => _CarrinhoPageState();
}

class _CarrinhoPageState extends ConsumerState<CarrinhoPage> with MessagesMixin {
  RecompensaModel? _recompensaSelecionada;

  Future<void> _limparCarrinho() async {
    await CustomConfirmDialog.show(
      context,
      titulo: 'Limpar carrinho',
      mensagem: 'Deseja remover todos os itens do carrinho?',
      textoBotaoConfirmar: 'Limpar',
      icon: Icons.delete_outline,
      iconColor: AppColors.error,
      onConfirmar: () async {
        await ref.read(cartControllerProvider.notifier).limpar();
        setState(() => _recompensaSelecionada = null);
      },
    );
  }

  Future<void> _finalizarPedido(double total) async {
    // Deduz pontos se usou recompensa
    if (_recompensaSelecionada != null) {
      await ref
          .read(pointsControllerProvider.notifier)
          .resgatar(_recompensaSelecionada!.pontos);
    }

    // Adiciona pontos pela compra (1 ponto por real gasto)
    final pontosGanhos = total.toInt();
    await ref.read(pointsControllerProvider.notifier).adicionar(pontosGanhos);

    await ref.read(cartControllerProvider.notifier).limpar();
    setState(() => _recompensaSelecionada = null);

    if (!mounted) return;
    showSuccess(context,
        'Pedido realizado! +$pontosGanhos Sweet Points adicionados!');
  }

  @override
  Widget build(BuildContext context) {
    final itens         = ref.watch(cartControllerProvider);
    final cart          = ref.read(cartControllerProvider.notifier);
    final user          = ref.watch(authControllerProvider);
    final pontos        = ref.watch(pointsControllerProvider)?.pontos ?? 0;
    final recompensasAV = ref.watch(recompensasProvider);

    final subtotal  = cart.total;
    final desconto  = _recompensaSelecionada != null
        ? subtotal * (_recompensaSelecionada!.desconto / 100)
        : 0.0;
    final total     = subtotal - desconto;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => context.go('/home'),
        ),
        title: const Text(
          'Meu Carrinho',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          if (itens.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: _limparCarrinho,
            ),
        ],
      ),
      body: user == null
          ? _buildNaoLogado()
          : itens.isEmpty
              ? _buildVazio()
              : _buildLista(
                  itens, cart, subtotal, desconto, total,
                  pontos, recompensasAV),
    );
  }

  Widget _buildNaoLogado() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_outline,
              size: 64, color: AppColors.primaryLight),
          const SizedBox(height: AppSizes.md),
          const Text(
            'Faça login para ver seu carrinho',
            style: TextStyle(
              fontSize: AppSizes.fontLg,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          CustomPrimaryButton(
            text: 'Fazer Login',
            onPressed: () => context.go('/login'),
            width: 200,
          ),
        ],
      ),
    );
  }

  Widget _buildVazio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_bag_outlined,
              size: 80, color: AppColors.primaryLight),
          const SizedBox(height: AppSizes.md),
          const Text(
            'Carrinho vazio',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          const Text(
            'Adicione produtos do cardápio',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSizes.lg),
          CustomPrimaryButton(
            text: 'Ver Cardápio',
            onPressed: () => context.go('/cardapio'),
            width: 200,
          ),
        ],
      ),
    );
  }

  Widget _buildLista(itens, cart, double subtotal, double desconto,
      double total, int pontos, AsyncValue<List<RecompensaModel>> recompensasAV) {
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(AppSizes.md),
            itemCount: itens.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSizes.sm),
            itemBuilder: (context, i) {
              final item = itens[i];
              return Container(
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(color: AppColors.surfacePink),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.surfacePink,
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusSm),
                      ),
                      child: const Icon(Icons.cake_outlined,
                          color: AppColors.primaryLight, size: 28),
                    ),
                    const SizedBox(width: AppSizes.sm + 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.produtoNome ?? 'Produto',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'R\$ ${item.produtoPreco?.toStringAsFixed(2).replaceAll('.', ',') ?? '0,00'}',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        _BotaoQuantidade(
                          icon: Icons.remove,
                          onTap: () => ref
                              .read(cartControllerProvider.notifier)
                              .diminuir(item.id!, item.quantidade),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.sm),
                          child: Text(
                            '${item.quantidade}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: AppSizes.fontLg,
                            ),
                          ),
                        ),
                        _BotaoQuantidade(
                          icon: Icons.add,
                          onTap: () => ref
                              .read(cartControllerProvider.notifier)
                              .adicionar(item.productId),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // Seção de fidelidade
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md, vertical: AppSizes.sm),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.surfacePink)),
          ),
          child: recompensasAV.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (recompensas) {
              final disponiveis = recompensas
                  .where((r) => pontos >= r.pontos)
                  .toList();

              if (disponiveis.isEmpty) {
                return Row(
                  children: [
                    const Icon(Icons.star_outline,
                        color: AppColors.textHint, size: 18),
                    const SizedBox(width: AppSizes.sm),
                    Text(
                      '$pontos pontos — acumule mais para descontos!',
                      style: const TextStyle(
                        color: AppColors.textHint,
                        fontSize: AppSizes.fontSm,
                      ),
                    ),
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(children: [
                    Icon(Icons.star, color: AppColors.primary, size: 18),
                    SizedBox(width: AppSizes.sm),
                    Text(
                      'Usar recompensa de fidelidade',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                        fontSize: AppSizes.fontSm,
                      ),
                    ),
                  ]),
                  const SizedBox(height: AppSizes.sm),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // Opção "Sem desconto"
                        GestureDetector(
                          onTap: () =>
                              setState(() => _recompensaSelecionada = null),
                          child: Container(
                            margin: const EdgeInsets.only(right: AppSizes.sm),
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSizes.sm + 4,
                                vertical: AppSizes.xs + 2),
                            decoration: BoxDecoration(
                              color: _recompensaSelecionada == null
                                  ? AppColors.primary
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(
                                  AppSizes.radiusFull),
                              border: Border.all(
                                color: _recompensaSelecionada == null
                                    ? AppColors.primary
                                    : AppColors.surfacePink,
                              ),
                            ),
                            child: Text(
                              'Sem desconto',
                              style: TextStyle(
                                fontSize: AppSizes.fontXs,
                                color: _recompensaSelecionada == null
                                    ? AppColors.surface
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                        // Recompensas disponíveis
                        ...disponiveis.map((r) {
                          final selecionada =
                              _recompensaSelecionada?.id == r.id;
                          return GestureDetector(
                            onTap: () => setState(
                                () => _recompensaSelecionada = r),
                            child: Container(
                              margin:
                                  const EdgeInsets.only(right: AppSizes.sm),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSizes.sm + 4,
                                  vertical: AppSizes.xs + 2),
                              decoration: BoxDecoration(
                                color: selecionada
                                    ? AppColors.primary
                                    : AppColors.surface,
                                borderRadius: BorderRadius.circular(
                                    AppSizes.radiusFull),
                                border: Border.all(
                                  color: selecionada
                                      ? AppColors.primary
                                      : AppColors.surfacePink,
                                ),
                              ),
                              child: Text(
                                '${r.descricao} (${r.pontos}pts)',
                                style: TextStyle(
                                  fontSize: AppSizes.fontXs,
                                  color: selecionada
                                      ? AppColors.surface
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),

        // Rodapé com total
        Container(
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.surfacePink)),
          ),
          child: Column(
            children: [
              // Subtotal
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Subtotal',
                      style: TextStyle(color: AppColors.textSecondary)),
                  Text(
                    'R\$ ${subtotal.toStringAsFixed(2).replaceAll('.', ',')}',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),

              // Desconto
              if (_recompensaSelecionada != null) ...[
                const SizedBox(height: AppSizes.xs),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Desconto (${_recompensaSelecionada!.desconto.toStringAsFixed(0)}%)',
                      style: const TextStyle(color: AppColors.success),
                    ),
                    Text(
                      '- R\$ ${desconto.toStringAsFixed(2).replaceAll('.', ',')}',
                      style: const TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],

              const Divider(height: AppSizes.md),

              // Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      fontSize: AppSizes.fontXl,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'R\$ ${total.toStringAsFixed(2).replaceAll('.', ',')}',
                    style: const TextStyle(
                      fontSize: AppSizes.fontXl,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.md),
              CustomPrimaryButton(
                text: 'Finalizar Pedido',
                icon: Icons.check_circle_outline,
                onPressed: () => _finalizarPedido(total),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BotaoQuantidade extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _BotaoQuantidade({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: AppColors.surfacePink,
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        ),
        child: Icon(icon, size: 16, color: AppColors.primary),
      ),
    );
  }
}