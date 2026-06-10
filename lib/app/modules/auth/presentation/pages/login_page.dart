import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/mixins/messages_mixin.dart';
import '../../../../shared/widgets/buttons/custom_primary_button.dart';
import '../../../../shared/widgets/buttons/custom_outlined_button.dart';
import '../../../../shared/widgets/forms/custom_text_field.dart';
import '../controllers/auth_controller.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with SingleTickerProviderStateMixin, MessagesMixin {
  late TabController _tabController;

  final _emailLoginController    = TextEditingController();
  final _senhaLoginController    = TextEditingController();
  final _nomeController          = TextEditingController();
  final _emailCadastroController = TextEditingController();
  final _senhaCadastroController = TextEditingController();

  bool _senhaVisivel = false;
  bool _carregando   = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailLoginController.dispose();
    _senhaLoginController.dispose();
    _nomeController.dispose();
    _emailCadastroController.dispose();
    _senhaCadastroController.dispose();
    super.dispose();
  }

  Future<void> _fazerLogin() async {
    setState(() => _carregando = true);
    final erro = await ref.read(authControllerProvider.notifier).login(
      context,
      _emailLoginController.text.trim(),
      _senhaLoginController.text,
    );
    if (!mounted) return;
    setState(() => _carregando = false);

    if (erro != null) {
      showError(context, erro);
    } else {
      context.go('/home');
    }
  }

  Future<void> _fazerCadastro() async {
    setState(() => _carregando = true);
    final erro = await ref.read(authControllerProvider.notifier).cadastrar(
      context,
      _nomeController.text.trim(),
      _emailCadastroController.text.trim(),
      _senhaCadastroController.text,
    );
    if (!mounted) return;
    setState(() => _carregando = false);

    if (erro != null) {
      showError(context, erro);
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text(
          'Lourenço Confeitaria',
          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Minha Conta',
              style: TextStyle(
                fontSize: AppSizes.fontXxl,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Faça login ou crie sua conta',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSizes.lg),

            // Abas
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfacePink,
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                ),
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Fazer Login'),
                  Tab(text: 'Cadastro'),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.lg),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildLogin(), _buildCadastro()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogin() {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(AppSizes.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(color: AppColors.surfacePink),
        ),
        child: Column(
          children: [
            CustomTextField(
              controller: _emailLoginController,
              label: 'E-mail',
              prefixIcon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: AppSizes.md),
            CustomTextField(
              controller: _senhaLoginController,
              label: 'Senha',
              prefixIcon: Icons.lock_outline,
              obscureText: !_senhaVisivel,
              suffixIcon: IconButton(
                icon: Icon(
                  _senhaVisivel ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.primary,
                ),
                onPressed: () => setState(() => _senhaVisivel = !_senhaVisivel),
              ),
            ),
            const SizedBox(height: AppSizes.lg),
            CustomPrimaryButton(
              text: 'Entrar',
              isLoading: _carregando,
              onPressed: _fazerLogin,
            ),
            const SizedBox(height: AppSizes.sm + 4),
            TextButton(
              onPressed: () {},
              child: const Text(
                'Esqueceu sua senha? Recuperar',
                style: TextStyle(color: AppColors.primary, fontSize: AppSizes.fontSm),
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            CustomOutlinedButton(
              text: 'Continuar sem Login',
              onPressed: () => context.go('/home'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCadastro() {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(AppSizes.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(color: AppColors.surfacePink),
        ),
        child: Column(
          children: [
            CustomTextField(
              controller: _nomeController,
              label: 'Nome completo',
              prefixIcon: Icons.person_outline,
            ),
            const SizedBox(height: AppSizes.md),
            CustomTextField(
              controller: _emailCadastroController,
              label: 'E-mail',
              prefixIcon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: AppSizes.md),
            CustomTextField(
              controller: _senhaCadastroController,
              label: 'Senha',
              prefixIcon: Icons.lock_outline,
              obscureText: true,
            ),
            const SizedBox(height: AppSizes.lg),
            CustomPrimaryButton(
              text: 'Criar Conta',
              isLoading: _carregando,
              onPressed: _fazerCadastro,
            ),
          ],
        ),
      ),
    );
  }
}