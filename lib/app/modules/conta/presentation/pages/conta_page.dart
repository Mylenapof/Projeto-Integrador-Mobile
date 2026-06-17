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
import '../../../../shared/widgets/forms/custom_text_field.dart';
import '../../../../shared/widgets/dialogs/custom_confirm_dialog.dart';
import '../../../auth/data/user_model.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../fidelidade/presentation/controllers/points_controller.dart';
import '../../../encomenda/presentation/pages/meus_pedidos_page.dart';

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

  void _abrirEdicaoPerfil(UserModel user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _EditarPerfilSheet(user: user),
    );
  }

  void _abrirAlterarSenha() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _AlterarSenhaSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider);
    final pontos = ref.watch(pointsControllerProvider)?.pontos ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const CustomAppDrawer(),
      appBar: const CustomAppBar(title: 'Lourenço'),
      body:
          user == null ? _buildNaoLogado(context) : _buildLogado(user, pontos),
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

  Widget _buildLogado(UserModel user, int pontos) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        children: [
          // Avatar e dados
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
                  user.nome,
                  style: const TextStyle(
                    fontSize: AppSizes.fontXl,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  user.email,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: AppSizes.fontSm,
                  ),
                ),
                if (user.telefone != null && user.telefone!.isNotEmpty)
                  Text(
                    user.telefone!,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: AppSizes.fontSm,
                    ),
                  ),
                if (user.endereco != null && user.endereco!.isNotEmpty) ...[
                  const SizedBox(height: AppSizes.xs),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSizes.md),
                    child: Text(
                      user.endereco!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: AppSizes.fontXs,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: AppSizes.sm + 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.md, vertical: AppSizes.xs + 2),
                  decoration: BoxDecoration(
                    color: AppColors.surfacePink,
                    borderRadius: BorderRadius.circular(AppSizes.radiusFull),
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
                const SizedBox(height: AppSizes.md),
                SizedBox(
                  width: double.infinity,
                  child: CustomOutlinedButton(
                    text: 'Editar Perfil',
                    icon: Icons.edit_outlined,
                    onPressed: () => _abrirEdicaoPerfil(user),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.md),

          CustomListCard(
            icon: Icons.inventory_2_outlined,
            titulo: 'Minhas Encomendas',
            subtitulo: 'Veja o histórico de pedidos',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MeusPedidosPage()),
            ),
          ),
          CustomListCard(
            icon: Icons.star_outline,
            titulo: 'Sweet Points',
            subtitulo: '$pontos pontos acumulados',
            onTap: () => context.go('/fidelidade'),
          ),
          CustomListCard(
            icon: Icons.lock_outline,
            titulo: 'Alterar Senha',
            subtitulo: 'Atualize sua senha de acesso',
            onTap: _abrirAlterarSenha,
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

// ── Sheet de edição de perfil ─────────────────────────────
class _EditarPerfilSheet extends ConsumerStatefulWidget {
  final UserModel user;
  const _EditarPerfilSheet({required this.user});

  @override
  ConsumerState<_EditarPerfilSheet> createState() => _EditarPerfilSheetState();
}

class _EditarPerfilSheetState extends ConsumerState<_EditarPerfilSheet>
    with MessagesMixin {
  late final TextEditingController _nomeController =
      TextEditingController(text: widget.user.nome);
  late final TextEditingController _emailController =
      TextEditingController(text: widget.user.email);
  late final TextEditingController _telefoneController =
      TextEditingController(text: widget.user.telefone ?? '');
  late final TextEditingController _enderecoController =
      TextEditingController(text: widget.user.endereco ?? '');
  bool _salvando = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _enderecoController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (_nomeController.text.trim().isEmpty) {
      showWarning(context, 'Informe seu nome');
      return;
    }
    setState(() => _salvando = true);

    final atualizado = widget.user.copyWith(
      nome: _nomeController.text.trim(),
      email: _emailController.text.trim(),
      telefone: _telefoneController.text.trim(),
      endereco: _enderecoController.text.trim(),
    );

    final erro = await ref
        .read(authControllerProvider.notifier)
        .atualizarPerfil(atualizado);

    if (!mounted) return;
    setState(() => _salvando = false);

    if (erro != null) {
      showError(context, erro);
    } else {
      Navigator.pop(context);
      showSuccess(context, 'Perfil atualizado!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSizes.md,
        right: AppSizes.md,
        top: AppSizes.md,
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
                  'Editar Perfil',
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
              controller: _nomeController,
              label: 'Nome completo',
              prefixIcon: Icons.person_outline,
            ),
            const SizedBox(height: AppSizes.sm + 4),
            CustomTextField(
              controller: _emailController,
              label: 'E-mail',
              prefixIcon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: AppSizes.sm + 4),
            CustomTextField(
              controller: _telefoneController,
              label: 'Telefone',
              hint: '(62) 99999-9999',
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: AppSizes.sm + 4),
            CustomTextField(
              controller: _enderecoController,
              label: 'Endereço (opcional)',
              hint: 'Rua, número, bairro, cidade',
              prefixIcon: Icons.location_on_outlined,
              maxLines: 2,
            ),
            const SizedBox(height: AppSizes.lg),
            CustomPrimaryButton(
              text: 'Salvar Alterações',
              isLoading: _salvando,
              onPressed: _salvar,
            ),
            const SizedBox(height: AppSizes.md),
          ],
        ),
      ),
    );
  }
}

// ── Sheet de alteração de senha ───────────────────────────
class _AlterarSenhaSheet extends ConsumerStatefulWidget {
  const _AlterarSenhaSheet();

  @override
  ConsumerState<_AlterarSenhaSheet> createState() => _AlterarSenhaSheetState();
}

class _AlterarSenhaSheetState extends ConsumerState<_AlterarSenhaSheet>
    with MessagesMixin {
  final _senhaAtualController = TextEditingController();
  final _novaSenhaController = TextEditingController();
  final _confirmarController = TextEditingController();
  bool _salvando = false;
  bool _verSenhaAtual = false;
  bool _verNovaSenha = false;

  @override
  void dispose() {
    _senhaAtualController.dispose();
    _novaSenhaController.dispose();
    _confirmarController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (_senhaAtualController.text.isEmpty) {
      showWarning(context, 'Informe sua senha atual');
      return;
    }
    if (_novaSenhaController.text.length < 6) {
      showWarning(context, 'Nova senha deve ter ao menos 6 caracteres');
      return;
    }
    if (_novaSenhaController.text != _confirmarController.text) {
      showWarning(context, 'As senhas não coincidem');
      return;
    }

    setState(() => _salvando = true);
    final erro = await ref.read(authControllerProvider.notifier).alterarSenha(
          _senhaAtualController.text,
          _novaSenhaController.text,
        );
    if (!mounted) return;
    setState(() => _salvando = false);

    if (erro != null) {
      showError(context, erro);
    } else {
      Navigator.pop(context);
      showSuccess(context, 'Senha alterada com sucesso!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSizes.md,
        right: AppSizes.md,
        top: AppSizes.md,
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
                  'Alterar Senha',
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
              controller: _senhaAtualController,
              label: 'Senha atual',
              prefixIcon: Icons.lock_outline,
              obscureText: !_verSenhaAtual,
              suffixIcon: IconButton(
                icon: Icon(
                  _verSenhaAtual ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.primary,
                ),
                onPressed: () =>
                    setState(() => _verSenhaAtual = !_verSenhaAtual),
              ),
            ),
            const SizedBox(height: AppSizes.sm + 4),
            CustomTextField(
              controller: _novaSenhaController,
              label: 'Nova senha',
              prefixIcon: Icons.lock_outline,
              obscureText: !_verNovaSenha,
              suffixIcon: IconButton(
                icon: Icon(
                  _verNovaSenha ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.primary,
                ),
                onPressed: () => setState(() => _verNovaSenha = !_verNovaSenha),
              ),
            ),
            const SizedBox(height: AppSizes.sm + 4),
            CustomTextField(
              controller: _confirmarController,
              label: 'Confirmar nova senha',
              prefixIcon: Icons.lock_outline,
              obscureText: !_verNovaSenha,
            ),
            const SizedBox(height: AppSizes.lg),
            CustomPrimaryButton(
              text: 'Salvar Nova Senha',
              isLoading: _salvando,
              onPressed: _salvar,
            ),
            const SizedBox(height: AppSizes.md),
          ],
        ),
      ),
    );
  }
}
