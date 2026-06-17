import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/mixins/messages_mixin.dart';
import '../../../../shared/widgets/buttons/custom_primary_button.dart';
import '../../../../shared/widgets/forms/custom_text_field.dart';
import '../../../auth/data/user_model.dart';

class DadosEntrega {
  final String tipo; // 'retirada' ou 'entrega'
  final String? endereco;
  final String? linkLocalizacao;
  final String? telefone;
  final String? observacoes;

  DadosEntrega({
    required this.tipo,
    this.endereco,
    this.linkLocalizacao,
    this.telefone,
    this.observacoes,
  });
}

class EntregaPage extends StatefulWidget {
  final UserModel? user;
  final void Function(DadosEntrega) onConfirmar;

  const EntregaPage({
    super.key,
    required this.user,
    required this.onConfirmar,
  });

  @override
  State<EntregaPage> createState() => _EntregaPageState();
}

class _EntregaPageState extends State<EntregaPage> with MessagesMixin {
  String _tipo = 'retirada';
  bool _usarEnderecoCadastrado = true;

  late final _enderecoController =
      TextEditingController(text: widget.user?.endereco ?? '');
  late final _telefoneController =
      TextEditingController(text: widget.user?.telefone ?? '');
  final _linkController = TextEditingController();
  final _obsController  = TextEditingController();

  bool get _temEnderecoCadastrado =>
      widget.user?.endereco != null && widget.user!.endereco!.isNotEmpty;

  @override
  void dispose() {
    _enderecoController.dispose();
    _telefoneController.dispose();
    _linkController.dispose();
    _obsController.dispose();
    super.dispose();
  }

  void _confirmar() {
    if (_tipo == 'entrega' && _enderecoController.text.trim().isEmpty) {
      showWarning(context, 'Informe o endereço de entrega');
      return;
    }

    widget.onConfirmar(DadosEntrega(
      tipo:           _tipo,
      endereco:       _tipo == 'entrega' ? _enderecoController.text.trim() : null,
      linkLocalizacao: _tipo == 'entrega' && _linkController.text.trim().isNotEmpty
          ? _linkController.text.trim() : null,
      telefone:       _telefoneController.text.trim(),
      observacoes:    _obsController.text.trim(),
    ));

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
          'Entrega ou Retirada',
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
            const Text(
              'Como você quer receber seu pedido?',
              style: TextStyle(
                fontSize: AppSizes.fontLg,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSizes.md),

            _OpcaoTipo(
              icon: Icons.storefront_outlined,
              titulo: 'Retirar na loja',
              subtitulo: 'Rua 619, nº 80, Qd 544, Lote 19 - Setor São José',
              selecionado: _tipo == 'retirada',
              onTap: () => setState(() => _tipo = 'retirada'),
            ),
            const SizedBox(height: AppSizes.sm),
            _OpcaoTipo(
              icon: Icons.delivery_dining_outlined,
              titulo: 'Receber em casa',
              subtitulo: 'Entregamos no endereço informado',
              selecionado: _tipo == 'entrega',
              onTap: () => setState(() => _tipo = 'entrega'),
            ),

            if (_tipo == 'entrega') ...[
              const SizedBox(height: AppSizes.lg),

              if (_temEnderecoCadastrado) ...[
                const Text(
                  'Endereço de entrega',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    fontSize: AppSizes.fontSm,
                  ),
                ),
                const SizedBox(height: AppSizes.sm),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Usar endereço cadastrado'),
                        selected: _usarEnderecoCadastrado,
                        onSelected: (_) => setState(() {
                          _usarEnderecoCadastrado = true;
                          _enderecoController.text = widget.user!.endereco!;
                        }),
                        backgroundColor: AppColors.surface,
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          fontSize: AppSizes.fontXs,
                          color: _usarEnderecoCadastrado
                              ? AppColors.surface
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSizes.sm),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Novo endereço'),
                        selected: !_usarEnderecoCadastrado,
                        onSelected: (_) => setState(() {
                          _usarEnderecoCadastrado = false;
                          _enderecoController.clear();
                        }),
                        backgroundColor: AppColors.surface,
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          fontSize: AppSizes.fontXs,
                          color: !_usarEnderecoCadastrado
                              ? AppColors.surface
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.sm + 4),
              ],

              CustomTextField(
                controller: _enderecoController,
                label: 'Endereço completo',
                hint: 'Rua, número, bairro, cidade',
                prefixIcon: Icons.location_on_outlined,
                maxLines: 2,
              ),
              const SizedBox(height: AppSizes.sm + 4),

              CustomTextField(
                controller: _linkController,
                label: 'Link da localização (opcional)',
                hint: 'Cole o link do Google Maps',
                prefixIcon: Icons.map_outlined,
              ),
              const SizedBox(height: AppSizes.sm + 4),

              CustomTextField(
                controller: _telefoneController,
                label: 'Telefone para contato',
                hint: '(62) 99999-9999',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: AppSizes.sm + 4),
            ],

            if (_tipo == 'retirada') ...[
              const SizedBox(height: AppSizes.md),
              CustomTextField(
                controller: _telefoneController,
                label: 'Telefone para contato',
                hint: '(62) 99999-9999',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
            ],

            const SizedBox(height: AppSizes.sm + 4),
            CustomTextField(
              controller: _obsController,
              label: 'Observações (opcional)',
              hint: 'Ponto de referência, horário preferido...',
              maxLines: 2,
            ),

            const SizedBox(height: AppSizes.xl),
            CustomPrimaryButton(
              text: 'Confirmar',
              icon: Icons.check_circle_outline,
              onPressed: _confirmar,
            ),
            const SizedBox(height: AppSizes.md),
          ],
        ),
      ),
    );
  }
}

class _OpcaoTipo extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String subtitulo;
  final bool selecionado;
  final VoidCallback onTap;

  const _OpcaoTipo({
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
                color: selecionado ? AppColors.primary : AppColors.surfacePink,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon,
                  color: selecionado ? AppColors.surface : AppColors.primary,
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