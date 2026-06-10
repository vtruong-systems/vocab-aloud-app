import 'package:flutter/material.dart';

import '../navigation/routes.dart';

class CreditsFooterLink extends StatelessWidget {
  const CreditsFooterLink({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.credits),
        child: const Text('Credits'),
      ),
    );
  }
}
