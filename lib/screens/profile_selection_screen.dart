import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/vocabulary_sets.dart';
import '../navigation/routes.dart';
import '../state/app_controller.dart';
import '../theme/app_theme.dart';
import '../utils/progress_helpers.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/sponsor_video_player.dart';

class ProfileSelectionScreen extends StatelessWidget {
  const ProfileSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();

    return AppScaffold(
      title: 'Who is practicing?',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.55,
                    ),
                    itemCount: controller.profiles.length,
                    itemBuilder: (context, index) {
                      final profile = controller.profiles[index];
                      final progress =
                          controller.state.profileProgress[profile.id];
                      final setsInProgress = progress == null
                          ? 0
                          : countSetsInProgress(
                              vocabularySets,
                              progress.sets.map(
                                (key, value) =>
                                    MapEntry(key, value.wordProgress),
                              ),
                              requireTyped: controller
                                  .settings.requireTypeItForCompletion,
                            );

                      return Card(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () async {
                            await controller.setActiveProfile(profile.id);
                            if (!context.mounted) return;
                            Navigator.pushReplacementNamed(
                              context,
                              AppRoutes.setSelection,
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  profile.avatarEmoji ?? '📚',
                                  style: const TextStyle(fontSize: 26),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  profile.displayName,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style:
                                      Theme.of(context).textTheme.titleSmall,
                                ),
                                Text(
                                  '$setsInProgress sets in progress',
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style:
                                      Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 42,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.createProfile);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.learnBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 2,
                      ),
                      child: const Text('Add Profile'),
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 42,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.editProfile);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.spellPurple,
                        side: const BorderSide(
                          color: AppColors.spellPurple,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('Edit Profiles'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          const AspectRatio(
            aspectRatio: 16 / 9,
            child: SponsorVideoPlayer(),
          ),
        ],
      ),
    );
  }
}
