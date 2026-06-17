import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/mixins/messages_mixin.dart';
import '../../../../shared/widgets/buttons/custom_primary_button.dart';
import '../../../../shared/widgets/forms/custom_text_field.dart';
import '../../../encomenda/data/order_model.dart';
import '../../../encomenda/presentation/controllers/order_controller.dart';
import '../../../../core/services/push_notification_service.dart';
import '../../../auth/data/user_repository.dart';

class OrcamentosPage extends ConsumerStatefulWidget {
  const OrcamentosPage({super.key});

  @override
  ConsumerState<OrcamentosPage> createState() => _OrcamentosPageState();
}

class _OrcamentosPageState extends ConsumerState<OrcamentosPage>
    with MessagesMixin {
  bool _mostrarApenasPendentes = true;

 void _abrirResponder(OrderModel pedido) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _ResponderSheet(
      pedido: pedido,
      onResponder: (valor, resposta) async {
        final erro = await ref
            .read(adminOrderControllerProvider.notifier)
            .responderOrcamento(pedido.id!, valor, resposta);
        if (!mounted) return;
        Navigator.pop(context);
        if (erro != null) {
          showError(context, erro);
        } else {
          showSuccess(context, 'Orçamento enviado ao cliente!');

          // Notifica o cliente via push
          final tokenCliente =
              await UserRepository().getFcmToken(pedido.userId);
          if (tokenCliente != null) {
            await PushNotificationService().enviarNotificacao(
              tokenDestino: tokenCliente,
              titulo: 'Seu orçamento chegou! 🎂',
              corpo:
                  'Valor: R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}. Confira em Meus Pedidos.',
            );
          }
        }
      },
    ),
  );
}
  @override
  Widget build(BuildContext context) {
    final pedidos = ref.watch(adminOrderControllerProvider);
    final filtrados = _mostrarApenasPendentes
        ? pedidos.where((p) => p.status == 'pendente').toList()
        : pedidos;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Orçamentos',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            onPressed: () =>
                ref.read(adminOrderControllerProvider.notifier).carregar(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Pendentes'),
                    selected: _mostrarApenasPendentes,
                    onSelected: (_) =>
                        setState(() => _mostrarApenasPendentes = true),
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: _mostrarApenasPendentes
                          ? AppColors.surface : AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Todos'),
                    selected: !_mostrarApenasPendentes,
                    onSelected: (_) =>
                        setState(() => _mostrarApenasPendentes = false),
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: !_mostrarApenasPendentes
                          ? AppColors.surface : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: filtrados.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhuma encomenda encontrada',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                    itemCount: filtrados.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSizes.sm + 4),
                    itemBuilder: (context, i) {
                      final p = filtrados[i];
                      return _PedidoAdminCard(
                        pedido: p,
                        onResponder: () => _abrirResponder(p),
                      );
                    },
                  ),
          ),
          const SizedBox(height: AppSizes.md),
        ],
      ),
    );
  }
}

class _PedidoAdminCard extends StatelessWidget {
  final OrderModel pedido;
  final VoidCallback onResponder;

  const _PedidoAdminCard({required this.pedido, required this.onResponder});

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
                  pedido.tipo == 'salgados'
                      ? 'Salgados — ${pedido.tipoProduto}'
                      : 'Personalizada — ${pedido.tipoProduto}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 4),
                decoration: BoxDecoration(
                  color: pendente
                      ? AppColors.warning.withOpacity(0.15)
                      : AppColors.success.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                ),
                child: Text(
                  pendente ? 'Pendente' : 'Respondido',
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

          if (pedido.sabor != null) Text('Sabor: ${pedido.sabor}',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: AppSizes.fontSm)),
          if (pedido.tamanho != null) Text('Tamanho/Qtd: ${pedido.tamanho}',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: AppSizes.fontSm)),
          if (pedido.decoracao != null && pedido.decoracao!.isNotEmpty)
            Text('Decoração: ${pedido.decoracao}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: AppSizes.fontSm)),
          if (pedido.observacoes != null && pedido.observacoes!.isNotEmpty)
            Text('Obs: ${pedido.observacoes}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: AppSizes.fontSm)),
          Text(
            'Entrega: ${pedido.tipoEntrega == "entrega" ? "Receber em casa" : "Retirar na loja"}',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: AppSizes.fontSm),
          ),
          if (pedido.endereco != null)
            Text('Endereço: ${pedido.endereco}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: AppSizes.fontSm)),
          if (pedido.telefone != null && pedido.telefone!.isNotEmpty)
            Text('Telefone: ${pedido.telefone}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: AppSizes.fontSm)),

          if (pedido.status == 'respondido' && pedido.valorOrcamento != null) ...[
            const SizedBox(height: AppSizes.sm),
            Text(
              'Valor enviado: R\$ ${pedido.valorOrcamento!.toStringAsFixed(2).replaceAll('.', ',')}',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],

          if (pendente) ...[
            const SizedBox(height: AppSizes.sm + 4),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onResponder,
                icon: const Icon(Icons.reply, size: 18),
                label: const Text('Responder Orçamento'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.surface,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Sheet de resposta do orçamento ────────────────────────
class _ResponderSheet extends StatefulWidget {
  final OrderModel pedido;
  final void Function(double valor, String resposta) onResponder;

  const _ResponderSheet({required this.pedido, required this.onResponder});

  @override
  State<_ResponderSheet> createState() => _ResponderSheetState();
}

class _ResponderSheetState extends State<_ResponderSheet> with MessagesMixin {
  final _valorController    = TextEditingController();
  final _respostaController = TextEditingController();

  @override
  void dispose() {
    _valorController.dispose();
    _respostaController.dispose();
    super.dispose();
  }

  void _enviar() {
    final valor = double.tryParse(_valorController.text.replaceAll(',', '.'));
    if (valor == null || valor <= 0) {
      showWarning(context, 'Informe um valor válido');
      return;
    }
    widget.onResponder(
      valor,
      _respostaController.text.trim().isEmpty
          ? 'Orçamento enviado pela confeitaria.'
          : _respostaController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSizes.md, right: AppSizes.md, top: AppSizes.md,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSizes.md,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Responder Orçamento',
                  style: TextStyle(
                    fontSize: AppSizes.fontXl,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.md),

            CustomTextField(
              controller: _valorController,
              label: 'Valor do orçamento (R\$)',
              hint: 'Ex: 150.00',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppSizes.sm + 4),
            CustomTextField(
              controller: _respostaController,
              label: 'Mensagem para o cliente (opcional)',
              hint: 'Ex: Prazo de produção: 3 dias',
              maxLines: 3,
            ),
            const SizedBox(height: AppSizes.lg),

            CustomPrimaryButton(
              text: 'Enviar Orçamento',
              icon: Icons.send_outlined,
              onPressed: _enviar,
            ),
            const SizedBox(height: AppSizes.md),
          ],
        ),
      ),
    );
  }
}