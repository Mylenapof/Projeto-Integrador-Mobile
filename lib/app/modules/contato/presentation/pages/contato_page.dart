import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../shared/widgets/home/custom_app_bar.dart';
import '../../../../shared/widgets/drawer/custom_app_drawer.dart';
import '../../../../shared/widgets/cards/custom_list_card.dart';

class ContatoPage extends StatelessWidget {
  const ContatoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const CustomAppDrawer(),
      appBar: const CustomAppBar(title: 'Lourenço'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Entre em Contato',
              style: TextStyle(
                fontSize: AppSizes.fontXxl,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSizes.lg),

            CustomListCard(
              icon: Icons.phone_outlined,
              titulo: 'Telefone',
              subtitulo: '(11) 98765-4321',
              onTap: () => _launch('tel:+5511987654321'),
            ),
            CustomListCard(
              icon: Icons.mail_outline,
              titulo: 'E-mail',
              subtitulo: 'contato@lourenco.com.br',
              onTap: () => _launch('mailto:contato@lourenco.com.br'),
            ),
            CustomListCard(
              icon: Icons.location_on_outlined,
              titulo: 'Endereço',
              subtitulo: 'Rua das Flores, 123 - São Paulo, SP',
              onTap: () => _launch(
                'https://maps.google.com/?q=Rua+das+Flores+123+São+Paulo'),
            ),
            CustomListCard(
              icon: Icons.camera_alt_outlined,
              titulo: 'Instagram',
              subtitulo: '@lourencoconfeitaria',
              onTap: () => _launch('https://instagram.com/lourencoconfeitaria'),
            ),
            CustomListCard(
              icon: Icons.chat_outlined,
              titulo: 'WhatsApp',
              subtitulo: '(11) 98765-4321',
              onTap: () => _launch('https://wa.me/5511987654321'),
            ),

            const SizedBox(height: AppSizes.xl),
            const Center(
              child: Text(
                '© 2026 Lourenço Confeitaria.\nTodos os direitos reservados.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.textHint),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }
}