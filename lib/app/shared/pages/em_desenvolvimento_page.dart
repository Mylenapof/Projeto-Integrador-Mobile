import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../widgets/home/custom_app_bar.dart';
import '../widgets/drawer/custom_app_drawer.dart';

class EmDesenvolvimentoPage extends StatelessWidget {
  final String titulo;
  final String mensagem;

  const EmDesenvolvimentoPage({
    super.key,
    this.titulo = 'Em Desenvolvimento',
    this.mensagem = 'Esta funcionalidade estará disponível em breve.',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const CustomAppDrawer(),
      appBar: CustomAppBar(title: 'Lourenço'),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.xl),
                decoration: BoxDecoration(
                  color: AppColors.surfacePink,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.construction_outlined,
                  size: 64,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSizes.lg),
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: AppSizes.fontXxl,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.sm),
              Text(
                mensagem,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: AppSizes.fontLg,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}