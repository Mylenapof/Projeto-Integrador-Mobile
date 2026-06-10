import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app/core/theme/app_colors.dart';
import 'app/core/theme/app_sizes.dart';

// Pages
import 'app/modules/splash/presentation/pages/splash_page.dart';
import 'app/modules/auth/presentation/pages/login_page.dart';
import 'app/modules/home/presentation/pages/home_page.dart';
import 'app/modules/cardapio/presentation/pages/cardapio_page.dart';
import 'app/modules/carrinho/presentation/pages/carrinho_page.dart';
import 'app/modules/encomenda/presentation/pages/encomendas_page.dart';
import 'app/modules/fidelidade/presentation/pages/fidelidade_page.dart';
import 'app/modules/contato/presentation/pages/contato_page.dart';
import 'app/modules/conta/presentation/pages/conta_page.dart';
import 'app/modules/busca_ia/presentation/pages/busca_ia_page.dart';

class LourencoApp extends StatelessWidget {
  const LourencoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Lourenço Confeitaria',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      routerConfig: _router,
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.primaryLight,
        surface: AppColors.surface,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonPrimary,
          foregroundColor: AppColors.buttonText,
          minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          ),
          textStyle: const TextStyle(
            fontSize: AppSizes.fontLg,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
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
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: AppSizes.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          side: const BorderSide(color: AppColors.surfacePink, width: 0.5),
        ),
      ),
      fontFamily: 'Roboto',
    );
  }
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/',           builder: (_, __) => const SplashPage()),
    GoRoute(path: '/login',      builder: (_, __) => const LoginPage()),
    GoRoute(path: '/home',       builder: (_, __) => const HomePage()),
    GoRoute(path: '/cardapio',   builder: (_, __) => const CardapioPage()),
    GoRoute(path: '/carrinho',   builder: (_, __) => const CarrinhoPage()),
    GoRoute(path: '/encomendas', builder: (_, __) => const EncomendasPage()),
    GoRoute(path: '/fidelidade', builder: (_, __) => const FidelidadePage()),
    GoRoute(path: '/contato',    builder: (_, __) => const ContatoPage()),
    GoRoute(path: '/conta',      builder: (_, __) => const ContaPage()),
    GoRoute(path: '/busca-ia',   builder: (_, __) => const BuscaIAPage()),
  ],
  errorBuilder: (context, state) => Scaffold(
    backgroundColor: AppColors.background,
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.primary),
          const SizedBox(height: AppSizes.md),
          const Text(
            'Página não encontrada',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          ElevatedButton(
            onPressed: () => context.go('/home'),
            child: const Text('Voltar ao início'),
          ),
        ],
      ),
    ),
  ),
);