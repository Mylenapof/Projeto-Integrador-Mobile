import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/mixins/messages_mixin.dart';
import '../../../../shared/widgets/home/custom_app_bar.dart';
import '../../../../shared/widgets/drawer/custom_app_drawer.dart';
import '../../../../shared/widgets/buttons/custom_primary_button.dart';
import '../../../admin/data/recompensa_model.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../fidelidade/presentation/controllers/points_controller.dart';

class FidelidadePage extends ConsumerStatefulWidget {
  const FidelidadePage({super.key});

  @override
  ConsumerState<FidelidadePage> createState() => _FidelidadePageState();
}

class _FidelidadePageState extends ConsumerState<FidelidadePage>
    with MessagesMixin {

  Future<void> _resgatar(RecompensaModel r) async {
    final erro = await ref
        .read(pointsControllerProvider.notifier)
        .resgatar(r.pontos);
    if (!mounted) return;
    if (erro != null) {
      showError(context, erro);
    } else {
      showSuccess(context, '${r.descricao} resgatado! Use no carrinho.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user            = ref.watch(authControllerProvider);
    final pontos          = ref.watch(pointsControllerProvider)?.pontos ?? 0;
    final recompensasAV   = ref.watch(recompensasProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const CustomAppDrawer(),
      appBar: const CustomAppBar(title: 'Lourenço'),
      body: user == null
          ? _buildNaoLogado()
          : recompensasAV.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary)),
              error: (e, _) => Center(child: Text('Erro: $e')),
              data: (recompensas) => _buildConteudo(pontos, recompensas),
            ),
    );
  }

  Widget _buildNaoLogado() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.star_outline, size: 64, color: AppColors.primaryLight),
          const SizedBox(height: AppSizes.md),
          const Text(
            'Faça login para ver seus pontos',
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

  Widget _buildConteudo(int pontos, List<RecompensaModel> recompensas) {
    final proxima = recompensas.isEmpty
        ? null
        : recompensas.cast<RecompensaModel?>().firstWhere(
            (r) => r!.pontos > pontos,
            orElse: () => recompensas.last,
          );
    final meta   = proxima?.pontos ?? 100;
    final faltam = (meta - pontos).clamp(0, meta);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sweet Points',
            style: TextStyle(
              fontSize: AppSizes.fontXxl,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Ganhe pontos a cada pedido e troque por recompensas especiais',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: AppSizes.fontSm,
            ),
          ),
          const SizedBox(height: AppSizes.lg),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSizes.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              border: Border.all(color: AppColors.surfacePink),
            ),
            child: Column(
              children: [
                const Row(children: [
                  Icon(Icons.star, color: AppColors.primary, size: 22),
                  SizedBox(width: AppSizes.sm),
                  Text('Seus Pontos',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: AppSizes.fontLg,
                      )),
                ]),
                const SizedBox(height: AppSizes.md),
                Text(
                  '$pontos',
                  style: const TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const Text(
                  'pontos acumulados',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: AppSizes.fontSm,
                  ),
                ),
                if (proxima != null) ...[
                  const SizedBox(height: AppSizes.md),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: AppSizes.fontSm,
                      ),
                      children: [
                        const TextSpan(text: 'Faltam '),
                        TextSpan(
                          text: '$faltam pontos',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextSpan(text: ' para: ${proxima.descricao}'),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm + 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: meta > 0
                          ? (pontos / meta).clamp(0.0, 1.0)
                          : 0,
                      minHeight: 10,
                      backgroundColor: AppColors.surfacePink,
                      valueColor:
                          const AlwaysStoppedAnimation(AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    '$pontos / $meta pontos',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSizes.lg),

          const Text(
            'Recompensas Disponíveis',
            style: TextStyle(
              fontSize: AppSizes.fontLg,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.sm + 4),

          recompensas.isEmpty
              ? const Center(
                  child: Text('Nenhuma recompensa disponível',
                      style: TextStyle(color: AppColors.textSecondary)),
                )
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppSizes.sm + 4,
                    mainAxisSpacing: AppSizes.sm + 4,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: recompensas.length,
                  itemBuilder: (context, i) {
                    final r          = recompensas[i];
                    final disponivel = pontos >= r.pontos;
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: disponivel
                            ? AppColors.surfacePink
                            : AppColors.surface,
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusMd),
                        border: Border.all(
                          color: disponivel
                              ? AppColors.primaryLight
                              : AppColors.surfacePink,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.star,
                              color: disponivel
                                  ? AppColors.primary
                                  : AppColors.textHint,
                              size: 28),
                          const SizedBox(height: AppSizes.xs),
                          Text(
                            '${r.pontos} pontos',
                            style: TextStyle(
                              fontSize: AppSizes.fontXs,
                              fontWeight: FontWeight.w600,
                              color: disponivel
                                  ? AppColors.primary
                                  : AppColors.textHint,
                            ),
                          ),
                          const SizedBox(height: AppSizes.xs),
                          Text(
                            r.descricao,
                            style: TextStyle(
                              fontSize: AppSizes.fontSm,
                              fontWeight: FontWeight.w700,
                              color: disponivel
                                  ? AppColors.textPrimary
                                  : AppColors.textHint,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${r.desconto.toStringAsFixed(0)}% de desconto',
                            style: TextStyle(
                              fontSize: AppSizes.fontXs,
                              color: disponivel
                                  ? AppColors.primary
                                  : AppColors.textHint,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (disponivel) ...[
                            const SizedBox(height: AppSizes.sm),
                            GestureDetector(
                              onTap: () => _resgatar(r),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius:
                                      BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'Resgatar',
                                  style: TextStyle(
                                    color: AppColors.surface,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}