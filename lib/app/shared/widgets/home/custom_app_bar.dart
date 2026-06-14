import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../buttons/custom_icon_button.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showMenu;
  final bool showCart;
  final int cartCount;
  final VoidCallback? onCartTap;
  final List<Widget>? actions;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showMenu = true,
    this.showCart = false,
    this.cartCount = 0,
    this.onCartTap,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      leading: showMenu
          ? Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu, color: AppColors.primary),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            )
          : IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.primary),
              onPressed: () => Navigator.pop(context),
            ),
      title: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/images/logo.png',
              width: 30,
              height: 30,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ],
      ),
      actions: [
        if (showCart)
          CustomIconButton(
            icon: Icons.shopping_bag_outlined,
            badgeCount: cartCount,
            onPressed: onCartTap,
          ),
        ...?actions,
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
