import 'package:flutter/material.dart';

import '../navigation/routes.dart';
import 'profile_menu_button.dart';

class ProfileAppBarActions extends StatelessWidget {
  const ProfileAppBarActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.storefront_outlined),
          tooltip: 'Icon store',
          onPressed: () => Navigator.pushNamed(context, AppRoutes.iconStore),
        ),
        const ProfileMenuButton(),
      ],
    );
  }
}
