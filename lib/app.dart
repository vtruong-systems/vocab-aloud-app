import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'navigation/routes.dart';
import 'screens/create_profile_screen.dart';
import 'screens/edit_profile_screen.dart';
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
import 'services/app_storage_service.dart';
import 'services/text_to_speech_service.dart';
import 'state/app_controller.dart';
import 'theme/app_theme.dart';

class VocabApp extends StatelessWidget {
  const VocabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => AppStorageService()),
        Provider(create: (_) => TextToSpeechService()),
        ChangeNotifierProvider(
          create: (context) => AppController(
            storage: context.read<AppStorageService>(),
            tts: context.read<TextToSpeechService>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Vocabulary Practice',
        theme: buildAppTheme(),
        initialRoute: AppRoutes.splash,
        routes: {
          AppRoutes.splash: (_) => const SplashScreen(),
          AppRoutes.createProfile: (_) => const CreateProfileScreen(),
          AppRoutes.profileSelection: (_) => const ProfileSelectionScreen(),
          AppRoutes.editProfile: (_) => const EditProfileScreen(),
          AppRoutes.setSelection: (_) => const SetSelectionScreen(),
          AppRoutes.setDashboard: (_) => const SetDashboardScreen(),
          AppRoutes.learnWords: (_) => const LearnWordsScreen(),
          AppRoutes.quiz: (_) => const QuizScreen(),
          AppRoutes.spellIt: (_) => const SpellItScreen(),
          AppRoutes.typeIt: (_) => const TypeItScreen(),
          AppRoutes.wordList: (_) => const WordListScreen(),
          AppRoutes.progress: (_) => const ProgressScreen(),
          AppRoutes.settings: (_) => const SettingsScreen(),
        },
      ),
    );
  }
}
