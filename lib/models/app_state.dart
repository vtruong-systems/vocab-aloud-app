import 'app_settings.dart';
import 'local_profile.dart';
import 'profile_progress.dart';

class AppState {
  const AppState({
    this.activeProfileId,
    this.profiles = const [],
    this.profileProgress = const {},
    this.settings = const AppSettings(),
    this.ownedPremiumIconIds = const [],
  });

  final String? activeProfileId;
  final List<LocalProfile> profiles;
  final Map<String, ProfileProgress> profileProgress;
  final AppSettings settings;
  final List<String> ownedPremiumIconIds;

  AppState copyWith({
    String? activeProfileId,
    List<LocalProfile>? profiles,
    Map<String, ProfileProgress>? profileProgress,
    AppSettings? settings,
    List<String>? ownedPremiumIconIds,
    bool clearActiveProfile = false,
  }) {
    return AppState(
      activeProfileId:
          clearActiveProfile ? null : (activeProfileId ?? this.activeProfileId),
      profiles: profiles ?? this.profiles,
      profileProgress: profileProgress ?? this.profileProgress,
      settings: settings ?? this.settings,
      ownedPremiumIconIds: ownedPremiumIconIds ?? this.ownedPremiumIconIds,
    );
  }

  Map<String, dynamic> toJson() => {
        'activeProfileId': activeProfileId,
        'profiles': profiles.map((profile) => profile.toJson()).toList(),
        'profileProgress': profileProgress.map(
          (key, value) => MapEntry(key, value.toJson()),
        ),
        'settings': settings.toJson(),
        'ownedPremiumIconIds': ownedPremiumIconIds,
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
      ownedPremiumIconIds: (json['ownedPremiumIconIds'] as List<dynamic>? ?? [])
          .map((item) => item as String)
          .toList(),
    );
  }

  static AppState empty() => const AppState();
}
