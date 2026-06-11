import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_branding.dart';
import '../navigation/routes.dart';
import '../state/app_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final controller = context.read<AppController>();
    await controller.load();
    if (!mounted) return;

    final profiles = controller.profiles;
    String route;
    if (profiles.isEmpty) {
      route = AppRoutes.createProfile;
    } else if (profiles.length == 1) {
      await controller.setActiveProfile(profiles.first.id);
      route = AppRoutes.setSelection;
    } else {
      route = AppRoutes.profileSelection;
    }

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book_rounded, size: 72),
            SizedBox(height: 16),
            Text(appDisplayName),
            SizedBox(height: 24),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
