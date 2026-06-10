import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/mixins/messages_mixin.dart';
import '../../../../shared/widgets/home/custom_app_bar.dart';
import '../../../../shared/widgets/drawer/custom_app_drawer.dart';
import '../../../../shared/widgets/buttons/custom_primary_button.dart';
import '../../../../shared/widgets/buttons/custom_outlined_button.dart';
import '../../../../shared/widgets/cards/custom_list_card.dart';
import '../../../../shared/widgets/dialogs/custom_confirm_dialog.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../fidelidade/presentation/controllers/points_controller.dart';
import '../../../admin/presentation/pages/admin_login_page.dart';

class ContaPage extends ConsumerStatefulWidget {
  const ContaPage({super.key});

  @override
  ConsumerState<ContaPage> createState() => _ContaPageState();
}

class _ContaPageState extends ConsumerState<ContaPage> with MessagesMixin {

  Future<void> _logout() async {
    await CustomConfirmDialog.show(
      context,
      titulo: 'Sair da conta',
      mensagem: 'Deseja realmente sair?',
      textoBotaoConfirmar: 'Sair',
      icon: Icons.logout,
      iconColor: AppColors.error,
      onConfirmar: () async {
        await ref.read(authControllerProvider.notifier).logout();
        if (mounted) context.go('/login');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user   = ref.watch(authControllerProvider);
    final pontos = ref.watch(pointsControllerProvider)?.pontos ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const CustomAppDrawer(),
      appBar: const CustomAppBar(title: 'Lourenço'),
      body: user == null
          ? _buildNaoLogado(context)
          : _buildLogado(user.nome, user.email, pontos),
    );
  }

  Widget _buildNaoLogado(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.xl),
              decoration: const BoxDecoration(
                color: AppColors.surfacePink,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_outline,
                  size: 64, color: AppColors.primary),
            ),
            const SizedBox(height: AppSizes.lg),
            const Text(
              'Faça login para acessar sua conta',
              style: TextStyle(
                fontSize: AppSizes.fontLg,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.lg),
            CustomPrimaryButton(
              text: 'Fazer Login',
              onPressed: () => context.go('/login'),
            ),
            const SizedBox(height: AppSizes.sm + 4),
            CustomOutlinedButton(
              text: 'Criar Conta',
              onPressed: () => context.go('/login'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogado(String nome, String email, int pontos) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        children: [
          // Avatar e nome
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
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: AppColors.surfacePink,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_outline,
                      size: 40, color: AppColors.primary),
                ),
                const SizedBox(height: AppSizes.sm + 4),
                Text(
                  nome,
                  style: const TextStyle(
                    fontSize: AppSizes.fontXl,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  email,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: AppSizes.fontSm,
                  ),
                ),
                const SizedBox(height: AppSizes.sm + 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.md, vertical: AppSizes.xs + 2),
                  decoration: BoxDecoration(
                    color: AppColors.surfacePink,
                    borderRadius:
                        BorderRadius.circular(AppSizes.radiusFull),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star,
                          color: AppColors.primary, size: 16),
                      const SizedBox(width: AppSizes.xs),
                      Text(
                        '$pontos Sweet Points',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: AppSizes.fontSm,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.md),

          // Opções
          CustomListCard(
            icon: Icons.inventory_2_outlined,
            titulo: 'Minhas Encomendas',
            subtitulo: 'Veja o histórico de pedidos',
            onTap: () => context.go('/encomendas'),
          ),
          CustomListCard(
            icon: Icons.star_outline,
            titulo: 'Sweet Points',
            subtitulo: '$pontos pontos acumulados',
            onTap: () => context.go('/fidelidade'),
          ),
          CustomListCard(
            icon: Icons.phone_outlined,
            titulo: 'Contato',
            subtitulo: 'Fale conosco',
            onTap: () => context.go('/contato'),
          ),
          CustomListCard(
            icon: Icons.admin_panel_settings_outlined,
            titulo: 'Área Admin',
            subtitulo: 'Acesso restrito',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminLoginPage()),
            ),
          ),

          const SizedBox(height: AppSizes.md),
          CustomOutlinedButton(
            text: 'Sair da Conta',
            icon: Icons.logout,
            onPressed: _logout,
          ),
        ],
      ),
    );
  }
}