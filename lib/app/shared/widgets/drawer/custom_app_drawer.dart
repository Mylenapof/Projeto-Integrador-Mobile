import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_sizes.dart';

class CustomAppDrawer extends StatelessWidget {
  const CustomAppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).uri.toString();

    return Drawer(
      backgroundColor: AppColors.surface,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.md,
              52,
              AppSizes.md,
              AppSizes.md,
            ),
            color: AppColors.surface,
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: AppSizes.sm + 4),
                const Text(
                  'Lourenço',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.primary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Itens
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
              children: [
                _DrawerItem(
                  label: 'Início',
                  icon: Icons.home_outlined,
                  route: '/home',
                  current: currentRoute,
                ),
                _DrawerItem(
                  label: 'Cardápio',
                  icon: Icons.restaurant_menu_outlined,
                  route: '/cardapio',
                  current: currentRoute,
                ),
                _DrawerItem(
                  label: 'Encomendas',
                  icon: Icons.inventory_2_outlined,
                  route: '/encomendas',
                  current: currentRoute,
                ),
                _DrawerItem(
                  label: 'Fidelidade',
                  icon: Icons.star_outline,
                  route: '/fidelidade',
                  current: currentRoute,
                ),
                _DrawerItem(
                  label: 'Contato',
                  icon: Icons.phone_outlined,
                  route: '/contato',
                  current: currentRoute,
                ),
                _DrawerItem(
                  label: 'Minha Conta',
                  icon: Icons.person_outline,
                  route: '/conta',
                  current: currentRoute,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final String route;
  final String current;

  const _DrawerItem({
    required this.label,
    required this.icon,
    required this.route,
    required this.current,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = current == route;
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSizes.sm + 4,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive ? AppColors.surface : AppColors.textSecondary,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isActive ? AppColors.surface : AppColors.textPrimary,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        onTap: () {
          Navigator.pop(context);
          context.go(route);
        },
      ),
    );
  }
}
