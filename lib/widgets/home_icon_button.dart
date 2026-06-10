import 'package:flutter/material.dart';

import '../navigation/routes.dart';

class HomeIconButton extends StatelessWidget {
  const HomeIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.home),
      tooltip: 'Home',
      onPressed: () {
        Navigator.pushReplacementNamed(context, AppRoutes.profileSelection);
      },
    );
  }
}
