import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/mixins/messages_mixin.dart';
import '../../../../core/services/push_notification_service.dart';

import '../../../../shared/widgets/home/custom_app_bar.dart';
import '../../../../shared/widgets/drawer/custom_app_drawer.dart';

import '../../../../shared/widgets/buttons/custom_primary_button.dart';

import '../../../../shared/widgets/forms/custom_dropdown.dart';
import '../../../../shared/widgets/forms/custom_text_field.dart';

import '../../../../shared/widgets/dialogs/custom_success_dialog.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../admin/domain/admin_service.dart';

import '../../data/order_model.dart';
import '../controllers/order_controller.dart';
import 'meus_pedidos_page.dart';
import '../../../carrinho/presentation/pages/pagamento_page.dart';

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
  final _qtdPessoasController = TextEditingController();
  final _enderecoController  = TextEditingController();
  final _linkController      = TextEditingController();
  final _telefoneController  = TextEditingController();

  int     _tipoSelecionado = 0;
  String? _tipoProduto;
  bool    _carregando = false;

  DateTime? _dataRetirada;
  TimeOfDay? _horarioRetirada;

  // ── Salgados ────────────────────────────────────────────
  String? _categoriaSalgado;
  final Set<String> _saboresSelecionados = {};
  String? _quantidadeSalgado;

  // ── Entrega ─────────────────────────────────────────────
  String _tipoEntrega = 'retirada';

  static const _precoSalgadoUnidade = 1.0; // R$1 por salgado

  static const _tiposProduto = ['Bolo','Torta','Cupcakes','Docinhos','Outro'];

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

  int get _quantidadeNumerica {
    if (_quantidadeSalgado == 'Personalizado') {
      return int.tryParse(_qtdPersonalizadaController.text) ?? 0;
    }
    return int.tryParse(_quantidadeSalgado ?? '0') ?? 0;
  }

  double get _valorEstimadoSalgados => _quantidadeNumerica * _precoSalgadoUnidade;

  @override
  void dispose() {
    _saborController.dispose();
    _decoracaoController.dispose();
    _obsController.dispose();
    _qtdPersonalizadaController.dispose();
    _qtdPessoasController.dispose();
    _enderecoController.dispose();
    _linkController.dispose();
    _telefoneController.dispose();
    super.dispose();
  }

  Future<void> _selecionarData() async {
    final hoje = DateTime.now();
    final data = await showDatePicker(
      context: context,
      initialDate: hoje.add(const Duration(days: 1)),
      firstDate: hoje,
      lastDate: hoje.add(const Duration(days: 90)),
    );
    if (data != null) setState(() => _dataRetirada = data);
  }

  Future<void> _selecionarHorario() async {
    final horario = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 14, minute: 0),
    );
    if (horario != null) setState(() => _horarioRetirada = horario);
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
    double? valorEstimado;

    if (_tipoSelecionado == 0) {
      tipoProdutoFinal = _tipoProduto ?? '';
      tamanhoFinal     = '${_qtdPessoasController.text} pessoas';
      saborFinal       = _saborController.text;
    } else {
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
      valorEstimado    = _valorEstimadoSalgados;
    }

    if (_dataRetirada == null) {
      showWarning(context, 'Selecione a data de retirada/entrega');
      return;
    }
    if (_horarioRetirada == null) {
      showWarning(context, 'Selecione o horário de retirada/entrega');
      return;
    }

    if (_tipoEntrega == 'entrega' && _enderecoController.text.trim().isEmpty) {
      showWarning(context, 'Informe o endereço de entrega');
      return;
    }

    // Salgados: precisa pagar antes de salvar
    if (_tipoSelecionado == 1 && valorEstimado != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PagamentoPage(
            total: valorEstimado!,
            onConfirmar: (formaPagamento) => _salvarEncomenda(
              user: user,
              tipoProdutoFinal: tipoProdutoFinal,
              tamanhoFinal: tamanhoFinal,
              saborFinal: saborFinal,
              valorEstimado: valorEstimado,
              formaPagamento: formaPagamento,
            ),
          ),
        ),
      );
      return;
    }

    // Personalizada: vai direto para orçamento pendente, sem pagamento
    await _salvarEncomenda(
      user: user,
      tipoProdutoFinal: tipoProdutoFinal,
      tamanhoFinal: tamanhoFinal,
      saborFinal: saborFinal,
      valorEstimado: null,
    );
  }

  Future<void> _salvarEncomenda({
    required dynamic user,
    required String tipoProdutoFinal,
    required String tamanhoFinal,
    required String saborFinal,
    double? valorEstimado,
    String? formaPagamento,
  }) async {
    setState(() => _carregando = true);

    final order = OrderModel(
      userId:          user.id!,
      tipo:            _tipoSelecionado == 0 ? 'personalizada' : 'salgados',
      tipoProduto:     tipoProdutoFinal,
      tamanho:         tamanhoFinal,
      sabor:           saborFinal,
      decoracao:       _decoracaoController.text,
      observacoes:     _obsController.text,
      valorOrcamento:  valorEstimado,
      status:          valorEstimado != null ? 'respondido' : 'pendente',
      respostaAdmin:   valorEstimado != null
          ? 'Valor calculado automaticamente: R\$ ${valorEstimado.toStringAsFixed(2).replaceAll('.', ',')}'
              '${formaPagamento != null ? ' • Pagamento: ${formaPagamento == 'pix' ? 'PIX' : 'Dinheiro'}' : ''}'
          : null,
      tipoEntrega:     _tipoEntrega,
      endereco:        _tipoEntrega == 'entrega' ? _enderecoController.text.trim() : null,
      linkLocalizacao: _linkController.text.trim().isEmpty ? null : _linkController.text.trim(),
      telefone:        _telefoneController.text.trim(),
      dataRetirada:    '${_dataRetirada!.day.toString().padLeft(2, '0')}/${_dataRetirada!.month.toString().padLeft(2, '0')}/${_dataRetirada!.year}',
      horarioRetirada: _horarioRetirada!.format(context),
      createdAt:       DateTime.now().toIso8601String(),
    );

    final erro = await ref.read(orderControllerProvider.notifier).enviar(order);
    if (!mounted) return;
    setState(() => _carregando = false);

    if (erro != null) {
      showError(context, erro);
      return;
    }

    await CustomSuccessDialog.show(
      context,
      titulo: _tipoSelecionado == 1 ? 'Encomenda enviada!' : 'Pedido de orçamento enviado!',
      mensagem: _tipoSelecionado == 1
          ? 'Centos de salgados confirmados! Valor: R\$ ${valorEstimado?.toStringAsFixed(2).replaceAll('.', ',')}.\nAcompanhe em "Meus Pedidos".'
          : 'Recebemos sua solicitação. Em breve enviaremos o orçamento.\nAcompanhe a resposta em "Meus Pedidos".',
    );

    // Notifica o admin sobre a nova encomenda personalizada (orçamento pendente)
    if (valorEstimado == null) {
      final tokenAdmin = await AdminService().getFcmToken();
      if (tokenAdmin != null) {
        await PushNotificationService().enviarNotificacao(
          tokenDestino: tokenAdmin,
          titulo: 'Nova encomenda recebida! 📦',
          corpo: '${user.nome} fez um pedido de orçamento personalizado.',
        );
      }
    }

    if (!mounted) return;
    _resetForm();
  }

  void _resetForm() {
    setState(() {
      _tipoProduto         = null;
      _categoriaSalgado    = null;
      _quantidadeSalgado   = null;
      _saboresSelecionados.clear();
      _tipoEntrega         = 'retirada';
      _dataRetirada        = null;
      _horarioRetirada     = null;
    });
    _saborController.clear();
    _decoracaoController.clear();
    _obsController.clear();
    _qtdPersonalizadaController.clear();
    _qtdPessoasController.clear();
    _enderecoController.clear();
    _linkController.clear();
    _telefoneController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const CustomAppDrawer(),
      appBar: CustomAppBar(
        title: 'Lourenço',
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long_outlined, color: AppColors.primary),
            tooltip: 'Meus Pedidos',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MeusPedidosPage()),
            ),
          ),
        ],
      ),
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

              _TipoCard(
                titulo: 'Encomenda Personalizada',
                subtitulo: 'Bolos, tortas e doces especiais — receba um orçamento',
                icon: Icons.cake_outlined,
                selecionado: _tipoSelecionado == 0,
                onTap: () => setState(() {
                  _tipoSelecionado = 0;
                  _tipoProduto = null;
                }),
              ),
              const SizedBox(height: AppSizes.sm + 2),
              _TipoCard(
                titulo: 'Centos de Salgados',
                subtitulo: 'Preço fixo: R\$ 1,00 por unidade',
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

                    if (_tipoSelecionado == 0) ...[
                      Container(
                        padding: const EdgeInsets.all(AppSizes.sm + 4),
                        margin: const EdgeInsets.only(bottom: AppSizes.sm + 4),
                        decoration: BoxDecoration(
                          color: AppColors.surfacePink,
                          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline, color: AppColors.primary, size: 18),
                            SizedBox(width: AppSizes.sm),
                            Expanded(
                              child: Text(
                                'Esse tipo de encomenda não tem preço fixo. Você receberá um orçamento personalizado.',
                                style: TextStyle(fontSize: AppSizes.fontXs, color: AppColors.textSecondary),
                              ),
                            ),
                          ],
                        ),
                      ),
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
                      CustomTextField(
                        controller: _qtdPessoasController,
                        label: 'Quantidade de pessoas',
                        hint: 'Ex: 20',
                        prefixIcon: Icons.groups_outlined,
                        keyboardType: TextInputType.number,
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Informe a quantidade de pessoas' : null,
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
                                color: selecionado ? AppColors.surface : AppColors.textSecondary,
                                fontSize: AppSizes.fontXs,
                                fontWeight: selecionado ? FontWeight.w600 : FontWeight.normal,
                              ),
                              side: BorderSide(
                                color: selecionado ? AppColors.primary : AppColors.surfacePink,
                              ),
                              showCheckmark: false,
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: AppSizes.md),
                      ],

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
                              color: selecionado ? AppColors.surface : AppColors.textSecondary,
                              fontSize: AppSizes.fontXs,
                              fontWeight: selecionado ? FontWeight.w600 : FontWeight.normal,
                            ),
                            side: BorderSide(
                              color: selecionado ? AppColors.primary : AppColors.surfacePink,
                            ),
                          );
                        }).toList(),
                      ),

                      if (_quantidadeSalgado == 'Personalizado') ...[
                        const SizedBox(height: AppSizes.sm + 4),
                        CustomTextField(
                          controller: _qtdPersonalizadaController,
                          label: 'Quantidade de salgados',
                          hint: 'Ex: 350',
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(() {}),
                        ),
                      ],

                      // Valor estimado
                      if (_quantidadeNumerica > 0) ...[
                        const SizedBox(height: AppSizes.md),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSizes.md),
                          decoration: BoxDecoration(
                            color: AppColors.surfacePink,
                            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Valor total',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                'R\$ ${_valorEstimadoSalgados.toStringAsFixed(2).replaceAll('.', ',')}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: AppSizes.fontLg,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: AppSizes.sm + 4),
                    ],

                    CustomTextField(
                      controller: _obsController,
                      label: 'Observações Adicionais',
                      hint: 'Alergias, preferências...',
                      maxLines: 3,
                      alignLabelWithHint: true,
                    ),
                    const SizedBox(height: AppSizes.lg),

                    // Data e horário de retirada/entrega
                    const Text(
                      'Data e Horário de Retirada/Entrega',
                      style: TextStyle(
                        fontSize: AppSizes.fontLg,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.sm + 4),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: _selecionarData,
                            child: Container(
                              padding: const EdgeInsets.all(AppSizes.md),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                                border: Border.all(color: AppColors.surfacePink),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today_outlined,
                                      color: AppColors.primary, size: 20),
                                  const SizedBox(width: AppSizes.sm),
                                  Expanded(
                                    child: Text(
                                      _dataRetirada == null
                                          ? 'Selecionar data'
                                          : '${_dataRetirada!.day.toString().padLeft(2, '0')}/${_dataRetirada!.month.toString().padLeft(2, '0')}/${_dataRetirada!.year}',
                                      style: TextStyle(
                                        color: _dataRetirada == null
                                            ? AppColors.textHint
                                            : AppColors.textPrimary,
                                        fontSize: AppSizes.fontSm,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSizes.sm + 4),
                        Expanded(
                          child: GestureDetector(
                            onTap: _selecionarHorario,
                            child: Container(
                              padding: const EdgeInsets.all(AppSizes.md),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                                border: Border.all(color: AppColors.surfacePink),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.access_time_outlined,
                                      color: AppColors.primary, size: 20),
                                  const SizedBox(width: AppSizes.sm),
                                  Expanded(
                                    child: Text(
                                      _horarioRetirada == null
                                          ? 'Selecionar horário'
                                          : _horarioRetirada!.format(context),
                                      style: TextStyle(
                                        color: _horarioRetirada == null
                                            ? AppColors.textHint
                                            : AppColors.textPrimary,
                                        fontSize: AppSizes.fontSm,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.lg),

                    // Entrega ou retirada
                    const Text(
                      'Entrega ou Retirada',
                      style: TextStyle(
                        fontSize: AppSizes.fontLg,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.sm + 4),

                    _OpcaoEntregaCard(
                      icon: Icons.storefront_outlined,
                      titulo: 'Retirar na loja',
                      subtitulo: 'Rua 619, nº 80, Qd 544, Lote 19 - Setor São José',
                      selecionado: _tipoEntrega == 'retirada',
                      onTap: () => setState(() => _tipoEntrega = 'retirada'),
                    ),
                    const SizedBox(height: AppSizes.sm),
                    _OpcaoEntregaCard(
                      icon: Icons.delivery_dining_outlined,
                      titulo: 'Receber em casa',
                      subtitulo: 'Entregamos no endereço informado',
                      selecionado: _tipoEntrega == 'entrega',
                      onTap: () => setState(() => _tipoEntrega = 'entrega'),
                    ),

                    if (_tipoEntrega == 'entrega') ...[
                      const SizedBox(height: AppSizes.sm + 4),
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
                    ],
                    const SizedBox(height: AppSizes.sm + 4),
                    CustomTextField(
                      controller: _telefoneController,
                      label: 'Telefone para contato',
                      hint: '(62) 99999-9999',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),

                    const SizedBox(height: AppSizes.lg),
                    CustomPrimaryButton(
                      text: _tipoSelecionado == 1 ? 'Confirmar Encomenda' : 'Solicitar Orçamento',
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

// ── Card de categoria do salgado ──────────────────────────
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

// ── Card de entrega/retirada ──────────────────────────────
class _OpcaoEntregaCard extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String subtitulo;
  final bool selecionado;
  final VoidCallback onTap;

  const _OpcaoEntregaCard({
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