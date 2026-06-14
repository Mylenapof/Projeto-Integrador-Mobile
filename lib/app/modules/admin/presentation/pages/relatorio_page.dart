import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../data/venda_repository.dart';

class RelatorioPage extends StatefulWidget {
  const RelatorioPage({super.key});

  @override
  State<RelatorioPage> createState() => _RelatorioPageState();
}

class _RelatorioPageState extends State<RelatorioPage> {
  Map<String, dynamic>? _dados;
  bool _carregando = true;

  static const _categoriaNomes = {
    1: 'Cupcakes', 2: 'Bolos',  3: 'Macarons',
    4: 'Tortas',   5: 'Salgados', 6: 'Donuts',
    7: 'Docinhos', 8: 'Especiais',
  };

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() => _carregando = true);
    _dados = await VendaRepository().getResumo();
    if (mounted) setState(() => _carregando = false);
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
          'Relatório de Vendas',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            onPressed: _carregar,
          ),
        ],
      ),
      body: _carregando
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : _dados == null
              ? const Center(child: Text('Erro ao carregar dados'))
              : RefreshIndicator(
                  onRefresh: _carregar,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppSizes.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildResumoCards(),
                        const SizedBox(height: AppSizes.lg),
                        _buildMaisVendidos(),
                        const SizedBox(height: AppSizes.lg),
                        _buildPorCategoria(),
                        const SizedBox(height: AppSizes.lg),
                        _buildUltimosDias(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildResumoCards() {
    final totalPedidos = _dados!['total_pedidos'] as int;
    final valorTotal   = _dados!['valor_total']   as double;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Resumo Geral',
            style: TextStyle(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            )),
        const SizedBox(height: AppSizes.sm + 4),
        Row(
          children: [
            Expanded(
              child: _CardResumo(
                icon: Icons.shopping_bag_outlined,
                titulo: 'Total de Pedidos',
                valor: '$totalPedidos',
                cor: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSizes.sm + 4),
            Expanded(
              child: _CardResumo(
                icon: Icons.attach_money,
                titulo: 'Valor Total',
                valor: 'R\$ ${valorTotal.toStringAsFixed(2).replaceAll('.', ',')}',
                cor: AppColors.success,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMaisVendidos() {
    final lista = _dados!['mais_vendidos'] as List;
    if (lista.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Produtos Mais Vendidos',
            style: TextStyle(
              fontSize: AppSizes.fontLg,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            )),
        const SizedBox(height: AppSizes.sm + 4),
        ...lista.asMap().entries.map((e) {
          final i    = e.key;
          final item = e.value;
          final qtd  = item['qtd'] as int;
          final nome = item['nome'] as String;
          return Container(
            margin: const EdgeInsets.only(bottom: AppSizes.sm),
            padding: const EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(color: AppColors.surfacePink),
            ),
            child: Row(
              children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: i == 0 ? AppColors.primary : AppColors.surfacePink,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(
                        color: i == 0 ? AppColors.surface : AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: AppSizes.fontSm,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.sm + 4),
                Expanded(
                  child: Text(nome,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      )),
                ),
                Text(
                  '$qtd vendidos',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: AppSizes.fontSm,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPorCategoria() {
    final lista = _dados!['por_categoria'] as List;
    if (lista.isEmpty) return const SizedBox.shrink();

    final maxQtd = lista.fold<int>(
        0, (max, e) => (e['qtd'] as int) > max ? e['qtd'] as int : max);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Vendas por Categoria',
            style: TextStyle(
              fontSize: AppSizes.fontLg,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            )),
        const SizedBox(height: AppSizes.sm + 4),
        Container(
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            border: Border.all(color: AppColors.surfacePink),
          ),
          child: Column(
            children: lista.map((item) {
              final catId = item['category_id'] as int;
              final qtd   = item['qtd'] as int;
              final nome  = _categoriaNomes[catId] ?? 'Categoria $catId';
              final pct   = maxQtd > 0 ? qtd / maxQtd : 0.0;

              return Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.sm + 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(nome,
                            style: const TextStyle(
                              fontSize: AppSizes.fontSm,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            )),
                        Text('$qtd un.',
                            style: const TextStyle(
                              fontSize: AppSizes.fontSm,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            )),
                      ],
                    ),
                    const SizedBox(height: AppSizes.xs),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 8,
                        backgroundColor: AppColors.surfacePink,
                        valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildUltimosDias() {
    final lista = _dados!['por_dia'] as List;
    if (lista.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSizes.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(color: AppColors.surfacePink),
        ),
        child: const Center(
          child: Text(
            'Nenhuma venda registrada ainda.\nFinalize um pedido no carrinho para ver os dados aqui.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Últimos 7 Dias',
            style: TextStyle(
              fontSize: AppSizes.fontLg,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            )),
        const SizedBox(height: AppSizes.sm + 4),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            border: Border.all(color: AppColors.surfacePink),
          ),
          child: Column(
            children: lista.asMap().entries.map((e) {
              final item    = e.value;
              final dia     = item['dia'] as String;
              final pedidos = item['pedidos'] as int;
              final valor   = item['valor'] as double? ?? 0.0;
              final isLast  = e.key == lista.length - 1;

              return Container(
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  border: isLast
                      ? null
                      : const Border(
                          bottom: BorderSide(color: AppColors.surfacePink)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 16, color: AppColors.primary),
                    const SizedBox(width: AppSizes.sm),
                    Text(dia,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: AppSizes.fontSm,
                        )),
                    const Spacer(),
                    Text(
                      '$pedidos pedido${pedidos != 1 ? 's' : ''}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: AppSizes.fontSm,
                      ),
                    ),
                    const SizedBox(width: AppSizes.md),
                    Text(
                      'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: AppSizes.fontSm,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _CardResumo extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String valor;
  final Color cor;

  const _CardResumo({
    required this.icon,
    required this.titulo,
    required this.valor,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.surfacePink),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.sm),
            decoration: BoxDecoration(
              color: AppColors.surfacePink,
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: Icon(icon, color: cor, size: 20),
          ),
          const SizedBox(height: AppSizes.sm + 4),
          Text(titulo,
              style: const TextStyle(
                fontSize: AppSizes.fontXs,
                color: AppColors.textSecondary,
              )),
          const SizedBox(height: AppSizes.xs),
          Text(valor,
              style: TextStyle(
                fontSize: AppSizes.fontLg,
                fontWeight: FontWeight.w700,
                color: cor,
              )),
        ],
      ),
    );
  }
}