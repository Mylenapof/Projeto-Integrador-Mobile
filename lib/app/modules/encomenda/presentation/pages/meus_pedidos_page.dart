import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../data/order_model.dart';
import '../controllers/order_controller.dart';

class MeusPedidosPage extends ConsumerWidget {
  const MeusPedidosPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pedidos = ref.watch(orderControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Meus Pedidos',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            onPressed: () =>
                ref.read(orderControllerProvider.notifier).carregar(),
          ),
        ],
      ),
      body: pedidos.isEmpty
          ? const Center(
              child: Text(
                'Você ainda não fez nenhuma encomenda',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSizes.md),
              itemCount: pedidos.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSizes.sm + 4),
              itemBuilder: (context, i) => _PedidoCard(pedido: pedidos[i]),
            ),
    );
  }
}

class _PedidoCard extends StatelessWidget {
  final OrderModel pedido;
  const _PedidoCard({required this.pedido});

  String get _tituloTipo {
    if (pedido.tipo == 'salgados') {
      return 'Centos de Salgados — ${pedido.tipoProduto}';
    }
    return 'Encomenda Personalizada — ${pedido.tipoProduto}';
  }

  @override
  Widget build(BuildContext context) {
    final pendente = pedido.status == 'pendente';

    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: pendente ? AppColors.warning : AppColors.surfacePink,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _tituloTipo,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.sm, vertical: 4),
                decoration: BoxDecoration(
                  color: pendente
                      ? AppColors.warning.withOpacity(0.15)
                      : AppColors.success.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                ),
                child: Text(
                  pendente ? 'Aguardando orçamento' : 'Respondido',
                  style: TextStyle(
                    fontSize: AppSizes.fontXs,
                    fontWeight: FontWeight.w600,
                    color: pendente ? AppColors.warning : AppColors.success,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),

          if (pedido.sabor != null && pedido.sabor!.isNotEmpty)
            _InfoLinha(label: 'Sabor', valor: pedido.sabor!),
          if (pedido.tamanho != null && pedido.tamanho!.isNotEmpty)
            _InfoLinha(label: 'Tamanho/Qtd', valor: pedido.tamanho!),
          _InfoLinha(
            label: 'Entrega',
            valor: pedido.tipoEntrega == 'entrega' ? 'Receber em casa' : 'Retirar na loja',
          ),

          if (pedido.status == 'respondido') ...[
            const SizedBox(height: AppSizes.sm + 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.sm + 4),
              decoration: BoxDecoration(
                color: AppColors.surfacePink,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (pedido.valorOrcamento != null)
                    Text(
                      'Valor: R\$ ${pedido.valorOrcamento!.toStringAsFixed(2).replaceAll('.', ',')}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        fontSize: AppSizes.fontLg,
                      ),
                    ),
                  if (pedido.respostaAdmin != null) ...[
                    const SizedBox(height: AppSizes.xs),
                    Text(
                      pedido.respostaAdmin!,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: AppSizes.fontSm,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoLinha extends StatelessWidget {
  final String label;
  final String valor;
  const _InfoLinha({required this.label, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text(
        '$label: $valor',
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: AppSizes.fontSm,
        ),
      ),
    );
  }
}