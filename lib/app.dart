import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'constants/app_branding.dart';
import 'navigation/routes.dart';
import 'screens/activity_screen.dart';
import 'screens/credits_screen.dart';
import 'screens/create_profile_screen.dart';
import 'screens/custom_lessons_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/icon_store_screen.dart';
import 'screens/learn_words_screen.dart';
import 'screens/profile_selection_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/set_dashboard_screen.dart';
import 'screens/set_selection_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/spell_it_screen.dart';
import 'screens/type_it_screen.dart';
import 'screens/word_list_screen.dart';
import 'services/create_purchase_service.dart';
import 'services/purchase_service.dart';
import 'services/app_storage_service.dart';
import 'services/text_to_speech_service.dart';
import 'state/app_controller.dart';
import 'theme/app_theme.dart';

class VocabApp extends StatefulWidget {
  const VocabApp({super.key});

  @override
  State<VocabApp> createState() => _VocabAppState();
}

class _VocabAppState extends State<VocabApp> {
  late final Future<PurchaseService> _purchaseServiceFuture;
  PurchaseService? _purchaseService;

  @override
  void initState() {
    super.initState();
    _purchaseServiceFuture = createPurchaseService();
    _purchaseServiceFuture.then((service) => _purchaseService = service);
  }

  @override
  void dispose() {
    _purchaseService?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PurchaseService>(
      future: _purchaseServiceFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return MaterialApp(
            theme: buildAppTheme(),
            home: const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final purchaseService =
            snapshot.data ?? const StubPurchaseService();

        return MultiProvider(
          providers: [
            Provider(create: (_) => AppStorageService()),
            Provider(create: (_) => TextToSpeechService()),
            Provider<PurchaseService>.value(value: purchaseService),
            ChangeNotifierProvider(
              create: (context) => AppController(
                storage: context.read<AppStorageService>(),
                tts: context.read<TextToSpeechService>(),
                purchaseService: context.read<PurchaseService>(),
              ),
            ),
          ],
          child: MaterialApp(
            title: appDisplayName,
            theme: buildAppTheme(),
            initialRoute: AppRoutes.splash,
            routes: {
              AppRoutes.splash: (_) => const SplashScreen(),
              AppRoutes.createProfile: (_) => const CreateProfileScreen(),
              AppRoutes.profileSelection: (_) =>
                  const ProfileSelectionScreen(),
              AppRoutes.editProfile: (_) => const EditProfileScreen(),
              AppRoutes.iconStore: (_) => const IconStoreScreen(),
              AppRoutes.setSelection: (_) => const SetSelectionScreen(),
              AppRoutes.setDashboard: (_) => const SetDashboardScreen(),
              AppRoutes.learnWords: (_) => const LearnWordsScreen(),
              AppRoutes.quiz: (_) => const QuizScreen(),
              AppRoutes.spellIt: (_) => const SpellItScreen(),
              AppRoutes.typeIt: (_) => const TypeItScreen(),
              AppRoutes.wordList: (_) => const WordListScreen(),
              AppRoutes.progress: (_) => const ProgressScreen(),
              AppRoutes.activity: (_) => const ActivityScreen(),
              AppRoutes.customLessons: (_) => const CustomLessonsScreen(),
              AppRoutes.settings: (_) => const SettingsScreen(),
              AppRoutes.credits: (_) => const CreditsScreen(),
            },
          ),
        );
      },
    );
  }
}
