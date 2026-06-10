import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/mixins/messages_mixin.dart';
import '../../../../shared/widgets/buttons/custom_primary_button.dart';
import '../../../../shared/widgets/forms/custom_text_field.dart';
import '../controllers/admin_controller.dart';
import 'admin_page.dart';

class AdminLoginPage extends ConsumerStatefulWidget {
  const AdminLoginPage({super.key});

  @override
  ConsumerState<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends ConsumerState<AdminLoginPage>
    with MessagesMixin {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _carregando       = false;
  bool _senhaVisivel     = false;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _senhaController.text.isEmpty) {
      showWarning(context, 'Preencha todos os campos');
      return;
    }

    setState(() => _carregando = true);
    final ok = await ref.read(adminControllerProvider.notifier).login(
      _emailController.text.trim(),
      _senhaController.text,
    );
    if (!mounted) return;
    setState(() => _carregando = false);

    if (!ok) {
      showError(context, 'E-mail ou senha incorretos');
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminPage()),
      );
    }
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
          'Área Administrativa',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
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
                child: const Icon(
                  Icons.admin_panel_settings_outlined,
                  size: 64,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSizes.lg),
              const Text(
                'Login Administrativo',
                style: TextStyle(
                  fontSize: AppSizes.fontXxl,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              const Text(
                'Acesso restrito aos administradores',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSizes.xl),

              Container(
                padding: const EdgeInsets.all(AppSizes.lg),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  border: Border.all(color: AppColors.surfacePink),
                ),
                child: Column(
                  children: [
                    CustomTextField(
                      controller: _emailController,
                      label: 'E-mail',
                      prefixIcon: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: AppSizes.md),
                    CustomTextField(
                      controller: _senhaController,
                      label: 'Senha',
                      prefixIcon: Icons.lock_outline,
                      obscureText: !_senhaVisivel,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _senhaVisivel
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppColors.primary,
                        ),
                        onPressed: () =>
                            setState(() => _senhaVisivel = !_senhaVisivel),
                      ),
                    ),
                    const SizedBox(height: AppSizes.lg),
                    CustomPrimaryButton(
                      text: 'Entrar',
                      icon: Icons.login,
                      isLoading: _carregando,
                      onPressed: _login,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}