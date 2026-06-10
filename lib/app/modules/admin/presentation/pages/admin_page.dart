import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/mixins/messages_mixin.dart';
import '../../../../shared/widgets/dialogs/custom_confirm_dialog.dart';
import '../controllers/admin_controller.dart';
import 'package:lourenco_confeitaria_app/app/modules/produto/data/product_model.dart';
import '../../data/recompensa_model.dart';

class AdminPage extends ConsumerStatefulWidget {
  const AdminPage({super.key});

  @override
  ConsumerState<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends ConsumerState<AdminPage>
    with SingleTickerProviderStateMixin, MessagesMixin {
  late TabController _tabController;
  List<ProductModel>    _produtos     = [];
  List<RecompensaModel> _recompensas  = [];
  bool _carregando = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _carregar();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
    setState(() => _carregando = true);
    final admin = ref.read(adminControllerProvider.notifier);
    _produtos    = await admin.getProdutos();
    _recompensas = await admin.getRecompensas();
    if (mounted) setState(() => _carregando = false);
  }

  // ── Produto ───────────────────────────────────────────────
  void _abrirFormProduto([ProductModel? produto]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _FormProduto(
        produto: produto,
        onSalvar: (p) async {
          final erro = await ref
              .read(adminControllerProvider.notifier)
              .salvarProduto(p);
          if (!mounted) return;
          Navigator.pop(context);
          if (erro != null) {
            showError(context, erro);
          } else {
            showSuccess(context, 'Produto salvo com sucesso!');
            _carregar();
          }
        },
      ),
    );
  }

  Future<void> _excluirProduto(ProductModel produto) async {
    await CustomConfirmDialog.show(
      context,
      titulo: 'Excluir produto',
      mensagem: 'Deseja excluir "${produto.nome}"?',
      textoBotaoConfirmar: 'Excluir',
      icon: Icons.delete_outline,
      iconColor: AppColors.error,
      onConfirmar: () async {
        final erro = await ref
            .read(adminControllerProvider.notifier)
            .excluirProduto(produto.id!);
        if (!mounted) return;
        if (erro != null) {
          showError(context, erro);
        } else {
          showSuccess(context, 'Produto excluído!');
          _carregar();
        }
      },
    );
  }

  // ── Recompensa ────────────────────────────────────────────
  void _abrirFormRecompensa([RecompensaModel? recompensa]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _FormRecompensa(
        recompensa: recompensa,
        onSalvar: (r) async {
          final erro = await ref
              .read(adminControllerProvider.notifier)
              .salvarRecompensa(r);
          if (!mounted) return;
          Navigator.pop(context);
          if (erro != null) {
            showError(context, erro);
          } else {
            showSuccess(context, 'Recompensa salva!');
            _carregar();
          }
        },
      ),
    );
  }

  Future<void> _excluirRecompensa(RecompensaModel r) async {
    await CustomConfirmDialog.show(
      context,
      titulo: 'Excluir recompensa',
      mensagem: 'Deseja excluir "${r.descricao}"?',
      textoBotaoConfirmar: 'Excluir',
      icon: Icons.delete_outline,
      iconColor: AppColors.error,
      onConfirmar: () async {
        await ref
            .read(adminControllerProvider.notifier)
            .excluirRecompensa(r.id!);
        if (!mounted) return;
        showSuccess(context, 'Recompensa excluída!');
        _carregar();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () {
            ref.read(adminControllerProvider.notifier).logout();
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Painel Admin',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(icon: Icon(Icons.cake_outlined),     text: 'Produtos'),
            Tab(icon: Icon(Icons.star_outline),      text: 'Recompensas'),
          ],
        ),
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildProdutos(),
                _buildRecompensas(),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          if (_tabController.index == 0) {
            _abrirFormProduto();
          } else {
            _abrirFormRecompensa();
          }
        },
        child: const Icon(Icons.add, color: AppColors.surface),
      ),
    );
  }

  Widget _buildProdutos() {
    if (_produtos.isEmpty) {
      return const Center(
        child: Text('Nenhum produto cadastrado',
            style: TextStyle(color: AppColors.textSecondary)),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppSizes.md),
      itemCount: _produtos.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSizes.sm),
      itemBuilder: (context, i) {
        final p = _produtos[i];
        return Container(
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(color: AppColors.surfacePink),
          ),
          child: Row(
            children: [
              // Imagem ou placeholder
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                child: p.imagemUrl != null
                    ? Image.network(p.imagemUrl!,
                        width: 56, height: 56, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholderImg())
                    : _placeholderImg(),
              ),
              const SizedBox(width: AppSizes.sm + 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.nome,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        )),
                    Text(
                      'R\$ ${p.preco.toStringAsFixed(2).replaceAll('.', ',')}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      p.disponivel ? 'Disponível' : 'Indisponível',
                      style: TextStyle(
                        fontSize: AppSizes.fontXs,
                        color: p.disponivel
                            ? AppColors.success
                            : AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                onPressed: () => _abrirFormProduto(p),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                onPressed: () => _excluirProduto(p),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecompensas() {
    if (_recompensas.isEmpty) {
      return const Center(
        child: Text('Nenhuma recompensa cadastrada',
            style: TextStyle(color: AppColors.textSecondary)),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppSizes.md),
      itemCount: _recompensas.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSizes.sm),
      itemBuilder: (context, i) {
        final r = _recompensas[i];
        return Container(
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(
              color: r.ativo ? AppColors.primaryLight : AppColors.surfacePink,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.sm + 2),
                decoration: BoxDecoration(
                  color: AppColors.surfacePink,
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: const Icon(Icons.star, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: AppSizes.sm + 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.descricao,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        )),
                    Text(
                      '${r.pontos} pontos • ${r.desconto.toStringAsFixed(0)}% desconto',
                      style: const TextStyle(
                        fontSize: AppSizes.fontSm,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      r.ativo ? 'Ativa' : 'Inativa',
                      style: TextStyle(
                        fontSize: AppSizes.fontXs,
                        color: r.ativo ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                onPressed: () => _abrirFormRecompensa(r),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                onPressed: () => _excluirRecompensa(r),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _placeholderImg() => Container(
    width: 56, height: 56,
    color: AppColors.surfacePink,
    child: const Icon(Icons.cake_outlined,
        color: AppColors.primaryLight, size: 28),
  );
}

// ── Form Produto ──────────────────────────────────────────
class _FormProduto extends StatefulWidget {
  final ProductModel? produto;
  final void Function(ProductModel) onSalvar;

  const _FormProduto({this.produto, required this.onSalvar});

  @override
  State<_FormProduto> createState() => _FormProdutoState();
}

class _FormProdutoState extends State<_FormProduto> {
  final _nomeController      = TextEditingController();
  final _descricaoController = TextEditingController();
  final _precoController     = TextEditingController();
  final _imagemController    = TextEditingController();
  int  _categoriaSelecionada = 1;
  bool _disponivel           = true;

  static const _categorias = {
    1: 'Cupcakes', 2: 'Bolos', 3: 'Macarons',
    4: 'Tortas Doces', 5: 'Salgados', 6: 'Donuts',
    7: 'Docinhos', 8: 'Especiais',
  };

  @override
  void initState() {
    super.initState();
    if (widget.produto != null) {
      final p = widget.produto!;
      _nomeController.text      = p.nome;
      _descricaoController.text = p.descricao;
      _precoController.text     = p.preco.toStringAsFixed(2);
      _imagemController.text    = p.imagemUrl ?? '';
      _categoriaSelecionada     = p.categoryId;
      _disponivel               = p.disponivel;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _precoController.dispose();
    _imagemController.dispose();
    super.dispose();
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
                Text(
                  widget.produto == null ? 'Novo Produto' : 'Editar Produto',
                  style: const TextStyle(
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

            // Preview da imagem
            if (_imagemController.text.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                child: Image.network(
                  _imagemController.text,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 120,
                    color: AppColors.surfacePink,
                    child: const Center(
                      child: Text('URL inválida',
                          style: TextStyle(color: AppColors.error)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.md),
            ],

            _campo(_nomeController, 'Nome do produto'),
            const SizedBox(height: AppSizes.sm + 4),
            _campo(_descricaoController, 'Descrição'),
            const SizedBox(height: AppSizes.sm + 4),
            _campo(_precoController, 'Preço (ex: 12.90)',
                tipo: TextInputType.number),
            const SizedBox(height: AppSizes.sm + 4),
            _campo(_imagemController, 'URL da imagem',
                hint: 'https://...', onChanged: (_) => setState(() {})),
            const SizedBox(height: AppSizes.sm + 4),

            // Categoria
            DropdownButtonFormField<int>(
              value: _categoriaSelecionada,
              decoration: _inputDecoration('Categoria'),
              items: _categorias.entries.map((e) =>
                DropdownMenuItem(value: e.key, child: Text(e.value))
              ).toList(),
              onChanged: (v) => setState(() => _categoriaSelecionada = v!),
            ),
            const SizedBox(height: AppSizes.sm + 4),

            // Disponível
            Row(
              children: [
                const Text('Disponível',
                    style: TextStyle(color: AppColors.textSecondary)),
                const Spacer(),
                Switch(
                  value: _disponivel,
                  activeColor: AppColors.primary,
                  onChanged: (v) => setState(() => _disponivel = v),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.md),

            SizedBox(
              width: double.infinity,
              height: AppSizes.buttonHeight,
              child: ElevatedButton(
                onPressed: () {
                  final preco = double.tryParse(
                    _precoController.text.replaceAll(',', '.')) ?? 0;
                  widget.onSalvar(ProductModel(
                    id:          widget.produto?.id,
                    nome:        _nomeController.text.trim(),
                    descricao:   _descricaoController.text.trim(),
                    preco:       preco,
                    imagemUrl:   _imagemController.text.trim().isEmpty
                                   ? null : _imagemController.text.trim(),
                    categoryId:  _categoriaSelecionada,
                    disponivel:  _disponivel,
                    createdAt:   widget.produto?.createdAt ??
                                   DateTime.now().toIso8601String(),
                  ));
                },
                child: const Text('Salvar'),
              ),
            ),
            const SizedBox(height: AppSizes.md),
          ],
        ),
      ),
    );
  }

  Widget _campo(TextEditingController ctrl, String label,
      {TextInputType tipo = TextInputType.text,
      String? hint,
      void Function(String)? onChanged}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: tipo,
      onChanged: onChanged,
      decoration: _inputDecoration(label, hint: hint),
    );
  }

  InputDecoration _inputDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        borderSide: const BorderSide(color: AppColors.surfacePink),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        borderSide: const BorderSide(color: AppColors.surfacePink),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      labelStyle: const TextStyle(color: AppColors.textSecondary),
    );
  }
}

// ── Form Recompensa ───────────────────────────────────────
class _FormRecompensa extends StatefulWidget {
  final RecompensaModel? recompensa;
  final void Function(RecompensaModel) onSalvar;

  const _FormRecompensa({this.recompensa, required this.onSalvar});

  @override
  State<_FormRecompensa> createState() => _FormRecompensaState();
}

class _FormRecompensaState extends State<_FormRecompensa> {
  final _descricaoController = TextEditingController();
  final _pontosController    = TextEditingController();
  final _descontoController  = TextEditingController();
  bool _ativo = true;

  @override
  void initState() {
    super.initState();
    if (widget.recompensa != null) {
      final r = widget.recompensa!;
      _descricaoController.text = r.descricao;
      _pontosController.text    = r.pontos.toString();
      _descontoController.text  = r.desconto.toStringAsFixed(0);
      _ativo                    = r.ativo;
    }
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    _pontosController.dispose();
    _descontoController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        borderSide: const BorderSide(color: AppColors.surfacePink),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        borderSide: const BorderSide(color: AppColors.surfacePink),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      labelStyle: const TextStyle(color: AppColors.textSecondary),
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
                Text(
                  widget.recompensa == null
                      ? 'Nova Recompensa' : 'Editar Recompensa',
                  style: const TextStyle(
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

            TextFormField(
              controller: _descricaoController,
              decoration: _inputDecoration('Descrição (ex: 10% OFF)'),
            ),
            const SizedBox(height: AppSizes.sm + 4),
            TextFormField(
              controller: _pontosController,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration('Pontos necessários'),
            ),
            const SizedBox(height: AppSizes.sm + 4),
            TextFormField(
              controller: _descontoController,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration('Desconto % (ex: 10)'),
            ),
            const SizedBox(height: AppSizes.sm + 4),

            Row(
              children: [
                const Text('Ativa',
                    style: TextStyle(color: AppColors.textSecondary)),
                const Spacer(),
                Switch(
                  value: _ativo,
                  activeColor: AppColors.primary,
                  onChanged: (v) => setState(() => _ativo = v),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.md),

            SizedBox(
              width: double.infinity,
              height: AppSizes.buttonHeight,
              child: ElevatedButton(
                onPressed: () {
                  widget.onSalvar(RecompensaModel(
                    id:        widget.recompensa?.id,
                    descricao: _descricaoController.text.trim(),
                    pontos:    int.tryParse(_pontosController.text) ?? 0,
                    desconto:  double.tryParse(_descontoController.text) ?? 0,
                    ativo:     _ativo,
                    createdAt: widget.recompensa?.createdAt ??
                               DateTime.now().toIso8601String(),
                  ));
                },
                child: const Text('Salvar'),
              ),
            ),
            const SizedBox(height: AppSizes.md),
          ],
        ),
      ),
    );
  }
}