import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/services/gemini_service.dart';
import '../../../../core/mixins/messages_mixin.dart';
import '../../../../shared/widgets/buttons/custom_primary_button.dart';
import '../../../../shared/widgets/forms/custom_text_field.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../carrinho/presentation/controllers/cart_controller.dart';
import '../../../produto/presentation/controllers/product_controller.dart';
class BuscaIAPage extends ConsumerStatefulWidget {
  const BuscaIAPage({super.key});

  @override
  ConsumerState<BuscaIAPage> createState() => _BuscaIAPageState();
}

class _BuscaIAPageState extends ConsumerState<BuscaIAPage> with MessagesMixin {
  final _controller = TextEditingController();
  final _gemini     = GeminiService();

  bool _carregando = false;
  List<ProdutoSugerido> _sugestoes = [];
  bool _buscaRealizada = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _buscar() async {
    if (_controller.text.trim().isEmpty) {
      showWarning(context, 'Descreva o que você está procurando');
      return;
    }

    setState(() {
      _carregando    = true;
      _sugestoes     = [];
      _buscaRealizada = false;
    });

    // Busca os produtos do banco para enviar ao Gemini
    final produtos = await ref.read(productServiceProvider).getDisponiveis();
    final cardapio = produtos.map((p) => {
      'nome':      p.nome,
      'descricao': p.descricao,
      'preco':     p.preco,
    }).toList();

    final sugestoes = await _gemini.buscarProdutos(
      descricaoUsuario: _controller.text.trim(),
      cardapio:         cardapio,
    );

    if (!mounted) return;
    setState(() {
      _sugestoes      = sugestoes;
      _carregando     = false;
      _buscaRealizada = true;
    });

    if (sugestoes.isEmpty) {
      showError(context, 'Não encontrei sugestões. Tente descrever de outra forma.');
    }
  }

  Future<void> _adicionarAoCarrinho(String nomeProduto) async {
    final user = ref.read(authControllerProvider);
    if (user == null) {
      showWarning(context, 'Faça login para adicionar ao carrinho');
      return;
    }

    // Busca o produto pelo nome
    final produtos = await ref.read(productServiceProvider).getDisponiveis();
    final produto  = produtos.where((p) =>
        p.nome.toLowerCase() == nomeProduto.toLowerCase()).firstOrNull;

    if (produto == null) {
      showError(context, 'Produto não encontrado no cardápio');
      return;
    }

    await ref.read(cartControllerProvider.notifier).adicionar(produto.id!);
    if (!mounted) return;
    showSuccess(context, '$nomeProduto adicionado ao carrinho!');
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
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
            SizedBox(width: AppSizes.sm),
            Text(
              'Busca Inteligente',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header explicativo
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: AppColors.surfacePink,
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
                      SizedBox(width: AppSizes.sm),
                      Text(
                        'IA do Cardápio',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: AppSizes.fontLg,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSizes.sm),
                  Text(
                    'Descreva o que você está com vontade e nossa IA encontra os produtos perfeitos para você!',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: AppSizes.fontSm,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.lg),

            // Exemplos de busca
            const Text(
              'Exemplos de busca:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                fontSize: AppSizes.fontSm,
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            Wrap(
              spacing: AppSizes.sm,
              runSpacing: AppSizes.sm,
              children: [
                _ChipExemplo(
                  texto: '🍫 Algo com chocolate',
                  onTap: () => setState(() =>
                      _controller.text = 'Algo com chocolate'),
                ),
                _ChipExemplo(
                  texto: '🎂 Bolo para festa infantil',
                  onTap: () => setState(() =>
                      _controller.text = 'Bolo para festa infantil'),
                ),
                _ChipExemplo(
                  texto: '🥐 Salgado para evento',
                  onTap: () => setState(() =>
                      _controller.text = 'Salgado para evento'),
                ),
                _ChipExemplo(
                  texto: '💝 Presente doce barato',
                  onTap: () => setState(() =>
                      _controller.text = 'Presente doce barato'),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.lg),

            // Campo de busca
            CustomTextField(
              controller: _controller,
              label: 'O que você está procurando?',
              hint: 'Ex: quero algo doce com morango para presentear',
              maxLines: 3,
              alignLabelWithHint: true,
            ),
            const SizedBox(height: AppSizes.md),

            CustomPrimaryButton(
              text: 'Buscar com IA',
              icon: Icons.auto_awesome,
              isLoading: _carregando,
              onPressed: _buscar,
            ),

            // Loading
            if (_carregando) ...[
              const SizedBox(height: AppSizes.lg),
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(color: AppColors.primary),
                    SizedBox(height: AppSizes.sm),
                    Text(
                      'A IA está analisando o cardápio...',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: AppSizes.fontSm,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Resultados
            if (_buscaRealizada && _sugestoes.isNotEmpty) ...[
              const SizedBox(height: AppSizes.lg),
              const Row(
                children: [
                  Icon(Icons.recommend, color: AppColors.primary, size: 20),
                  SizedBox(width: AppSizes.sm),
                  Text(
                    'Sugestões para você',
                    style: TextStyle(
                      fontSize: AppSizes.fontLg,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.sm + 4),
              ...(_sugestoes.map((s) => _CardSugestao(
                sugestao: s,
                onAdicionar: () => _adicionarAoCarrinho(s.nome),
              ))),
            ],

            // Sem resultados
            if (_buscaRealizada && _sugestoes.isEmpty && !_carregando) ...[
              const SizedBox(height: AppSizes.lg),
              Center(
                child: Column(
                  children: [
                    const Icon(Icons.search_off,
                        size: 48, color: AppColors.primaryLight),
                    const SizedBox(height: AppSizes.sm),
                    const Text(
                      'Nenhuma sugestão encontrada',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppSizes.sm),
                    TextButton(
                      onPressed: () => _controller.clear(),
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Chip de exemplo ───────────────────────────────────────
class _ChipExemplo extends StatelessWidget {
  final String texto;
  final VoidCallback onTap;

  const _ChipExemplo({required this.texto, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.sm + 4,
          vertical: AppSizes.xs + 2,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          border: Border.all(color: AppColors.surfacePink),
        ),
        child: Text(
          texto,
          style: const TextStyle(
            fontSize: AppSizes.fontXs,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ── Card de sugestão ──────────────────────────────────────
class _CardSugestao extends StatelessWidget {
  final ProdutoSugerido sugestao;
  final VoidCallback onAdicionar;

  const _CardSugestao({required this.sugestao, required this.onAdicionar});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.sm + 4),
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.surfacePink),
      ),
      child: Row(
        children: [
          // Ícone
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.surfacePink,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: const Icon(Icons.cake_outlined,
                color: AppColors.primaryLight, size: 28),
          ),
          const SizedBox(width: AppSizes.sm + 4),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sugestao.nome,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontSize: AppSizes.fontMd,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sugestao.motivo,
                  style: const TextStyle(
                    fontSize: AppSizes.fontXs,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSizes.xs),
                Text(
                  'R\$ ${sugestao.preco.toStringAsFixed(2).replaceAll('.', ',')}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: AppSizes.fontSm,
                  ),
                ),
              ],
            ),
          ),

          // Botão adicionar
          GestureDetector(
            onTap: onAdicionar,
            child: Container(
              padding: const EdgeInsets.all(AppSizes.sm),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: const Icon(Icons.add, color: AppColors.surface, size: 20),
            ),
          ),
        ],
      ),
    );
  }
} 