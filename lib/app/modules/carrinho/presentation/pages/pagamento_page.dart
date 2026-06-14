import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../shared/widgets/buttons/custom_primary_button.dart';
import '../../../../shared/widgets/dialogs/custom_success_dialog.dart';

class PagamentoPage extends StatefulWidget {
  final double total;
  final Future<void> Function(String formaPagamento) onConfirmar;

  const PagamentoPage({
    super.key,
    required this.total,
    required this.onConfirmar,
  });

  @override
  State<PagamentoPage> createState() => _PagamentoPageState();
}

class _PagamentoPageState extends State<PagamentoPage> {
  String _formaPagamento = 'pix';
  bool _processando = false;

  static const _chavePix = 'lourencoconfeitaria@pix.com.br';

  Future<void> _confirmar() async {
    setState(() => _processando = true);

    await widget.onConfirmar(_formaPagamento);

    if (!mounted) return;
    setState(() => _processando = false);

    await CustomSuccessDialog.show(
      context,
      titulo: 'Pedido confirmado!',
      mensagem: _formaPagamento == 'pix'
          ? 'Pagamento via PIX registrado. Em breve confirmaremos o recebimento.'
          : 'Pedido registrado! Pague em dinheiro na entrega ou retirada.',
    );

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Pagamento',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.lg),
              decoration: BoxDecoration(
                color: AppColors.surfacePink,
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              ),
              child: Column(
                children: [
                  const Text('Total a pagar',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: AppSizes.fontSm,
                      )),
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    'R\$ ${widget.total.toStringAsFixed(2).replaceAll('.', ',')}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.lg),

            const Text(
              'Forma de Pagamento',
              style: TextStyle(
                fontSize: AppSizes.fontLg,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSizes.sm + 4),

            _OpcaoPagamento(
              icon: Icons.qr_code_2,
              titulo: 'PIX',
              subtitulo: 'Pagamento instantâneo via QR Code ou chave',
              selecionado: _formaPagamento == 'pix',
              onTap: () => setState(() => _formaPagamento = 'pix'),
            ),
            const SizedBox(height: AppSizes.sm),
            _OpcaoPagamento(
              icon: Icons.payments_outlined,
              titulo: 'Dinheiro',
              subtitulo: 'Pague na entrega ou retirada',
              selecionado: _formaPagamento == 'dinheiro',
              onTap: () => setState(() => _formaPagamento = 'dinheiro'),
            ),

            const SizedBox(height: AppSizes.lg),

            if (_formaPagamento == 'pix') _buildPix(),
            if (_formaPagamento == 'dinheiro') _buildDinheiro(),

            const SizedBox(height: AppSizes.xl),

            CustomPrimaryButton(
              text: 'Confirmar Pedido',
              icon: Icons.check_circle_outline,
              isLoading: _processando,
              onPressed: _confirmar,
            ),
            const SizedBox(height: AppSizes.md),
          ],
        ),
      ),
    );
  }

  Widget _buildPix() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.surfacePink),
      ),
      child: Column(
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: AppColors.surfacePink,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: const Icon(Icons.qr_code_2,
                size: 100, color: AppColors.primary),
          ),
          const SizedBox(height: AppSizes.md),
          const Text(
            'Chave PIX (e-mail)',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: AppSizes.fontXs,
            ),
          ),
          const SizedBox(height: AppSizes.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                _chavePix,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              IconButton(
                icon: const Icon(Icons.copy,
                    size: 18, color: AppColors.primary),
                onPressed: () {
                  Clipboard.setData(const ClipboardData(text: _chavePix));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Chave PIX copiada!')),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          const Text(
            'Após realizar o pagamento, toque em "Confirmar Pedido".',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: AppSizes.fontXs,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDinheiro() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.surfacePink),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.primary),
          SizedBox(width: AppSizes.sm + 4),
          Expanded(
            child: Text(
              'O pagamento em dinheiro deve ser feito no momento da entrega ou retirada do pedido.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: AppSizes.fontSm,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OpcaoPagamento extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String subtitulo;
  final bool selecionado;
  final VoidCallback onTap;

  const _OpcaoPagamento({
    required this.icon,
    required this.titulo,
    required this.subtitulo,
    required this.selecionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(
            color: selecionado ? AppColors.primary : AppColors.surfacePink,
            width: selecionado ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: selecionado
                    ? AppColors.primary
                    : AppColors.surfacePink,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon,
                  color: selecionado
                      ? AppColors.surface
                      : AppColors.primary,
                  size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: selecionado
                            ? AppColors.primary
                            : AppColors.textPrimary,
                      )),
                  const SizedBox(height: 2),
                  Text(subtitulo,
                      style: const TextStyle(
                        fontSize: AppSizes.fontXs,
                        color: AppColors.textSecondary,
                      )),
                ],
              ),
            ),
            Icon(
              selecionado
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: selecionado ? AppColors.primary : AppColors.textHint,
            ),
          ],
        ),
      ),
    );
  }
}