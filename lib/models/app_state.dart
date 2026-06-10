import 'app_settings.dart';
import 'local_profile.dart';
import 'profile_progress.dart';

class AppState {
  const AppState({
    this.activeProfileId,
    this.profiles = const [],
    this.profileProgress = const {},
    this.settings = const AppSettings(),
  });

  final String? activeProfileId;
  final List<LocalProfile> profiles;
  final Map<String, ProfileProgress> profileProgress;
  final AppSettings settings;

  AppState copyWith({
    String? activeProfileId,
    List<LocalProfile>? profiles,
    Map<String, ProfileProgress>? profileProgress,
    AppSettings? settings,
    bool clearActiveProfile = false,
  }) {
    return AppState(
      activeProfileId:
          clearActiveProfile ? null : (activeProfileId ?? this.activeProfileId),
      profiles: profiles ?? this.profiles,
      profileProgress: profileProgress ?? this.profileProgress,
      settings: settings ?? this.settings,
    );
  }

  Map<String, dynamic> toJson() => {
        'activeProfileId': activeProfileId,
        'profiles': profiles.map((profile) => profile.toJson()).toList(),
        'profileProgress': profileProgress.map(
          (key, value) => MapEntry(key, value.toJson()),
        ),
        'settings': settings.toJson(),
      };

  factory AppState.fromJson(Map<String, dynamic> json) {
    final rawProgress = json['profileProgress'] as Map<String, dynamic>? ?? {};
    return AppState(
      activeProfileId: json['activeProfileId'] as String?,
      profiles: (json['profiles'] as List<dynamic>? ?? [])
          .map((item) => LocalProfile.fromJson(item as Map<String, dynamic>))
          .toList(),
      profileProgress: rawProgress.map(
        (key, value) => MapEntry(
          key,
          ProfileProgress.fromJson(value as Map<String, dynamic>),
        ),
      ),
      settings: AppSettings.fromJson(
        json['settings'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  static AppState empty() => const AppState();
}
