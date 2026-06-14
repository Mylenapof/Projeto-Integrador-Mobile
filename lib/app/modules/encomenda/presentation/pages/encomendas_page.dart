import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/mixins/messages_mixin.dart';

import '../../../../shared/widgets/home/custom_app_bar.dart';
import '../../../../shared/widgets/drawer/custom_app_drawer.dart';

import '../../../../shared/widgets/buttons/custom_primary_button.dart';

import '../../../../shared/widgets/forms/custom_dropdown.dart';
import '../../../../shared/widgets/forms/custom_text_field.dart';

import '../../../../shared/widgets/dialogs/custom_success_dialog.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';

import '../../data/order_model.dart';
import '../controllers/order_controller.dart';

class EncomendasPage extends ConsumerStatefulWidget {
  const EncomendasPage({super.key});

  @override
  ConsumerState<EncomendasPage> createState() => _EncomendasPageState();
}

class _EncomendasPageState extends ConsumerState<EncomendasPage>
    with MessagesMixin {
  final _formKey             = GlobalKey<FormState>();
  final _saborController     = TextEditingController();
  final _decoracaoController = TextEditingController();
  final _obsController       = TextEditingController();
  final _qtdPersonalizadaController = TextEditingController();

  int     _tipoSelecionado = 0;
  String? _tipoProduto;
  String? _tamanho;
  bool    _carregando = false;

  // ── Salgados ────────────────────────────────────────────
  String? _categoriaSalgado;            // 'Fritos' ou 'Assados'
  final Set<String> _saboresSelecionados = {};
  String? _quantidadeSalgado;           // '100', '200', 'Personalizado'

  static const _tiposProduto = ['Bolo','Torta','Cupcakes','Docinhos','Outro'];
  static const _tamanhos     = ['Pequeno (10 fatias)','Médio (20 fatias)','Grande (30 fatias)','Personalizado'];

  static const _saboresFritos = [
    'Coxinha de Frango',
    'Bolinha de Queijo',
    'Kibe',
    'Risole de Presunto e Queijo',
    'Enroladinho de Salsicha',
    'Croquete de Carne',
  ];

  static const _saboresAssados = [
    'Esfiha de Carne',
    'Esfiha de Frango',
    'Empada de Frango',
    'Folhado de Presunto e Queijo',
    'Enroladinho de Queijo',
    'Quiche de Alho-poró',
  ];

  List<String> get _saboresDisponiveis {
    if (_categoriaSalgado == 'Fritos')  return _saboresFritos;
    if (_categoriaSalgado == 'Assados') return _saboresAssados;
    return [];
  }

  @override
  void dispose() {
    _saborController.dispose();
    _decoracaoController.dispose();
    _obsController.dispose();
    _qtdPersonalizadaController.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(authControllerProvider);
    if (user == null) {
      showWarning(context, 'Faça login para enviar uma encomenda');
      return;
    }

    String tipoProdutoFinal;
    String tamanhoFinal;
    String saborFinal;

    if (_tipoSelecionado == 0) {
      // Encomenda personalizada
      tipoProdutoFinal = _tipoProduto ?? '';
      tamanhoFinal     = _tamanho ?? '';
      saborFinal       = _saborController.text;
    } else {
      // Centos de salgados
      if (_categoriaSalgado == null) {
        showWarning(context, 'Selecione a categoria: Fritos ou Assados');
        return;
      }
      if (_saboresSelecionados.isEmpty) {
        showWarning(context, 'Selecione ao menos um sabor');
        return;
      }
      if (_quantidadeSalgado == null) {
        showWarning(context, 'Selecione a quantidade');
        return;
      }
      if (_quantidadeSalgado == 'Personalizado') {
        final qtd = int.tryParse(_qtdPersonalizadaController.text);
        if (qtd == null || qtd <= 0) {
          showWarning(context, 'Informe uma quantidade válida');
          return;
        }
        tamanhoFinal = '${_qtdPersonalizadaController.text} unidades';
      } else {
        tamanhoFinal = '$_quantidadeSalgado unidades';
      }

      tipoProdutoFinal = _categoriaSalgado!;
      saborFinal       = _saboresSelecionados.join(', ');
    }

    setState(() => _carregando = true);

    final order = OrderModel(
      userId:      user.id!,
      tipo:        _tipoSelecionado == 0 ? 'personalizada' : 'salgados',
      tipoProduto: tipoProdutoFinal,
      tamanho:     tamanhoFinal,
      sabor:       saborFinal,
      decoracao:   _decoracaoController.text,
      observacoes: _obsController.text,
      createdAt:   DateTime.now().toIso8601String(),
    );

    final erro = await ref.read(orderControllerProvider.notifier).enviar(order);
    if (!mounted) return;
    setState(() => _carregando = false);

    if (erro != null) {
      showError(context, erro);
    } else {
      await CustomSuccessDialog.show(
        context,
        titulo: 'Encomenda enviada!',
        mensagem: 'Recebemos sua encomenda.\nEntraremos em contato em breve para confirmar.',
      );
      _resetForm();
    }
  }

  void _resetForm() {
    setState(() {
      _tipoProduto         = null;
      _tamanho             = null;
      _categoriaSalgado    = null;
      _quantidadeSalgado   = null;
      _saboresSelecionados.clear();
    });
    _saborController.clear();
    _decoracaoController.clear();
    _obsController.clear();
    _qtdPersonalizadaController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const CustomAppDrawer(),
      appBar: const CustomAppBar(title: 'Lourenço'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Faça sua Encomenda',
                style: TextStyle(
                  fontSize: AppSizes.fontXxl,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Personalize seu pedido ou encomende centos de salgados',
                style: TextStyle(color: AppColors.textSecondary, fontSize: AppSizes.fontSm),
              ),
              const SizedBox(height: AppSizes.lg),

              // Seleção de tipo
              _TipoCard(
                titulo: 'Encomenda Personalizada',
                subtitulo: 'Bolos, tortas e doces especiais sob medida',
                icon: Icons.cake_outlined,
                selecionado: _tipoSelecionado == 0,
                onTap: () => setState(() {
                  _tipoSelecionado = 0;
                  _tipoProduto = null;
                  _tamanho = null;
                }),
              ),
              const SizedBox(height: AppSizes.sm + 2),
              _TipoCard(
                titulo: 'Centos de Salgados',
                subtitulo: 'Salgados fritos e assados para eventos',
                icon: Icons.restaurant_outlined,
                selecionado: _tipoSelecionado == 1,
                onTap: () => setState(() {
                  _tipoSelecionado = 1;
                  _categoriaSalgado = null;
                  _quantidadeSalgado = null;
                  _saboresSelecionados.clear();
                }),
              ),
              const SizedBox(height: AppSizes.lg),

              // Formulário
              Container(
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  border: Border.all(color: AppColors.surfacePink),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Detalhes da Encomenda',
                      style: TextStyle(
                        fontSize: AppSizes.fontLg,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.md),

                    // Campos personalizada
                    if (_tipoSelecionado == 0) ...[
                      CustomDropdown<String>(
                        label: 'Tipo de Produto',
                        value: _tipoProduto,
                        items: _tiposProduto,
                        itemLabel: (e) => e,
                        hint: 'Selecione o tipo',
                        validator: (v) => v == null ? 'Selecione o tipo de produto' : null,
                        onChanged: (v) => setState(() => _tipoProduto = v),
                      ),
                      const SizedBox(height: AppSizes.sm + 4),
                      CustomDropdown<String>(
                        label: 'Tamanho',
                        value: _tamanho,
                        items: _tamanhos,
                        itemLabel: (e) => e,
                        hint: 'Selecione o tamanho',
                        validator: (v) => v == null ? 'Selecione o tamanho' : null,
                        onChanged: (v) => setState(() => _tamanho = v),
                      ),
                      const SizedBox(height: AppSizes.sm + 4),
                      CustomTextField(
                        controller: _saborController,
                        label: 'Sabor / Recheio',
                        hint: 'Ex: Chocolate com brigadeiro',
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Informe o sabor ou recheio' : null,
                      ),
                      const SizedBox(height: AppSizes.sm + 4),
                      CustomTextField(
                        controller: _decoracaoController,
                        label: 'Decoração / Tema',
                        hint: 'Descreva a decoração desejada',
                      ),
                    ],

                    // Campos salgados
                    if (_tipoSelecionado == 1) ...[
                      const Text(
                        'Categoria',
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
                            child: _CategoriaSalgadoCard(
                              titulo: 'Fritos',
                              icon: Icons.local_fire_department_outlined,
                              selecionado: _categoriaSalgado == 'Fritos',
                              onTap: () => setState(() {
                                _categoriaSalgado = 'Fritos';
                                _saboresSelecionados.clear();
                              }),
                            ),
                          ),
                          const SizedBox(width: AppSizes.sm + 4),
                          Expanded(
                            child: _CategoriaSalgadoCard(
                              titulo: 'Assados',
                              icon: Icons.outdoor_grill_outlined,
                              selecionado: _categoriaSalgado == 'Assados',
                              onTap: () => setState(() {
                                _categoriaSalgado = 'Assados';
                                _saboresSelecionados.clear();
                              }),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.md),

                      // Sabores
                      if (_categoriaSalgado != null) ...[
                        const Text(
                          'Sabores (selecione um ou mais)',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            fontSize: AppSizes.fontSm,
                          ),
                        ),
                        const SizedBox(height: AppSizes.sm),
                        Wrap(
                          spacing: AppSizes.sm,
                          runSpacing: AppSizes.sm,
                          children: _saboresDisponiveis.map((sabor) {
                            final selecionado = _saboresSelecionados.contains(sabor);
                            return FilterChip(
                              label: Text(sabor),
                              selected: selecionado,
                              onSelected: (_) => setState(() {
                                if (selecionado) {
                                  _saboresSelecionados.remove(sabor);
                                } else {
                                  _saboresSelecionados.add(sabor);
                                }
                              }),
                              backgroundColor: AppColors.surface,
                              selectedColor: AppColors.primary,
                              labelStyle: TextStyle(
                                color: selecionado
                                    ? AppColors.surface
                                    : AppColors.textSecondary,
                                fontSize: AppSizes.fontXs,
                                fontWeight: selecionado
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                              side: BorderSide(
                                color: selecionado
                                    ? AppColors.primary
                                    : AppColors.surfacePink,
                              ),
                              showCheckmark: false,
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: AppSizes.md),
                      ],

                      // Quantidade
                      const Text(
                        'Quantidade',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          fontSize: AppSizes.fontSm,
                        ),
                      ),
                      const SizedBox(height: AppSizes.sm),
                      Wrap(
                        spacing: AppSizes.sm,
                        runSpacing: AppSizes.sm,
                        children: ['100', '200', 'Personalizado'].map((q) {
                          final selecionado = _quantidadeSalgado == q;
                          return ChoiceChip(
                            label: Text(q == 'Personalizado' ? q : '$q unidades'),
                            selected: selecionado,
                            onSelected: (_) => setState(() => _quantidadeSalgado = q),
                            backgroundColor: AppColors.surface,
                            selectedColor: AppColors.primary,
                            labelStyle: TextStyle(
                              color: selecionado
                                  ? AppColors.surface
                                  : AppColors.textSecondary,
                              fontSize: AppSizes.fontXs,
                              fontWeight: selecionado
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                            side: BorderSide(
                              color: selecionado
                                  ? AppColors.primary
                                  : AppColors.surfacePink,
                            ),
                          );
                        }).toList(),
                      ),

                      // Campo de quantidade personalizada
                      if (_quantidadeSalgado == 'Personalizado') ...[
                        const SizedBox(height: AppSizes.sm + 4),
                        CustomTextField(
                          controller: _qtdPersonalizadaController,
                          label: 'Quantidade de salgados',
                          hint: 'Ex: 350',
                          keyboardType: TextInputType.number,
                        ),
                      ],

                      const SizedBox(height: AppSizes.sm + 4),
                    ],

                    // OBSERVAÇÕES
                    CustomTextField(
                      controller: _obsController,
                      label: 'Observações Adicionais',
                      hint: 'Alergias, preferências...',
                      maxLines: 3,
                      alignLabelWithHint: true,
                    ),
                    const SizedBox(height: AppSizes.lg),
                    CustomPrimaryButton(
                      text: 'Enviar Encomenda',
                      icon: Icons.send_outlined,
                      isLoading: _carregando,
                      onPressed: _enviar,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.lg),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Card de tipo de encomenda ──────────────────────────────
class _TipoCard extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final IconData icon;
  final bool selecionado;
  final VoidCallback onTap;

  const _TipoCard({
    required this.titulo,
    required this.subtitulo,
    required this.icon,
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
                      color: selecionado ? AppColors.primary : AppColors.textPrimary,
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
              selecionado ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selecionado ? AppColors.primary : AppColors.textHint,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Card de categoria do salgado (Fritos / Assados) ───────
class _CategoriaSalgadoCard extends StatelessWidget {
  final String titulo;
  final IconData icon;
  final bool selecionado;
  final VoidCallback onTap;

  const _CategoriaSalgadoCard({
    required this.titulo,
    required this.icon,
    required this.selecionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.sm + 4),
        decoration: BoxDecoration(
          color: selecionado ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(
            color: selecionado ? AppColors.primary : AppColors.surfacePink,
            width: selecionado ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon,
                color: selecionado ? AppColors.surface : AppColors.primary,
                size: 26),
            const SizedBox(height: AppSizes.xs + 2),
            Text(
              titulo,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: selecionado ? AppColors.surface : AppColors.textPrimary,
                fontSize: AppSizes.fontSm,
              ),
            ),
          ],
        ),
      ),
    );
  }
}