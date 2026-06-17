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
              icon: Icons.chat_outlined,
              titulo: 'WhatsApp',
              subtitulo: '(62) 98593-2521',
              onTap: () => _launch('https://wa.me/5562985932521'),
            ),
            CustomListCard(
              icon: Icons.location_on_outlined,
              titulo: 'Endereço',
              subtitulo:
                  'Rua 619, nº 80, Qd 544, Lote 19 - Setor São José\n(toque para abrir no Google Maps)',
              onTap: () => _launch(
                  'https://maps.google.com/?q=Rua+619+n80+Qd+544+Lote+19+Setor+São+José'),
            ),
            CustomListCard(
              icon: Icons.camera_alt_outlined,
              titulo: 'Instagram',
              subtitulo: '@andreialourencoconfeitaria',
              onTap: () => _launch(
                  'https://www.instagram.com/andreialourencoconfeitaria?igsh=dmhpMXRxMWtuaWFq'),
            ),
            const SizedBox(height: AppSizes.xl),
            const Center(
              child: Text(
                '© 2026 Andreia Lourenço Confeitaria.\nTodos os direitos reservados.',
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
