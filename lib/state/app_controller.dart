import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

export '../data/profile_icon_catalog.dart' show presetEmojis;

import '../data/profile_icon_catalog.dart';
import '../data/vocabulary_sets.dart';
import '../models/activity_entry.dart';
import '../models/app_settings.dart';
import '../models/app_state.dart';
import '../models/local_profile.dart';
import '../models/profile_progress.dart';
import '../models/vocabulary_set.dart';
import '../models/word_progress.dart';
import '../services/purchase_service.dart';
import '../services/app_storage_service.dart';
import '../services/text_to_speech_service.dart';
import '../utils/progress_helpers.dart';

const maxProfiles = 10;
const maxActivityLogEntries = 200;

class AppController extends ChangeNotifier {
  AppController({
    required AppStorageService storage,
    required TextToSpeechService tts,
    required PurchaseService purchaseService,
  })  : _storage = storage,
        _tts = tts,
        _purchaseService = purchaseService;

  final AppStorageService _storage;
  final TextToSpeechService _tts;
  final PurchaseService _purchaseService;
  final _uuid = const Uuid();

  AppState _state = AppState.empty();
  bool _loaded = false;

  bool get isLoaded => _loaded;
  AppState get state => _state;
  List<LocalProfile> get profiles => _state.profiles;
  LocalProfile? get activeProfile {
    final id = _state.activeProfileId;
    if (id == null) return null;
    return _state.profiles.where((profile) => profile.id == id).firstOrNull;
  }

  AppSettings get settings => _state.settings;
  TextToSpeechService get tts => _tts;
  List<String> get ownedPremiumIconIds => _state.ownedPremiumIconIds;

  ProfileProgress? get _activeProgress {
    final profileId = _state.activeProfileId;
    if (profileId == null) return null;
    return _state.profileProgress[profileId] ?? const ProfileProgress();
  }

  Future<void> load() async {
    _state = await _storage.load();
    await _tts.initialize();
    await _tts.applySpeechSpeed(_state.settings.speechSpeed);
    _loaded = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    await _storage.save(_state);
    notifyListeners();
  }

  VocabularySet? getSetById(String? setId) {
    if (setId == null) return null;
    for (final set in vocabularySets) {
      if (set.id == setId) return set;
    }
    return null;
  }

  VocabularySet? get selectedSet {
    return getSetById(_activeProgress?.selectedSetId);
  }

  Map<String, WordProgress> getSelectedSetProgress() {
    final setId = _activeProgress?.selectedSetId;
    if (setId == null) return {};
    return _activeProgress?.sets[setId]?.wordProgress ?? {};
  }

  SetStats? getSelectedSetStats() {
    final set = selectedSet;
    if (set == null) return null;
    return computeSetStats(
      set,
      getSelectedSetProgress(),
      requireTyped: settings.requireTypeItForCompletion,
    );
  }

  List<ActivityEntry> get activityLog {
    final progress = _activeProgress;
    if (progress == null) return const [];
    return List<ActivityEntry>.from(progress.activityLog);
  }

  Future<void> logActivity({
    required ActivityType type,
    required String setId,
    required String setTitle,
    int? correctCount,
    int? totalCount,
  }) async {
    final profileId = _state.activeProfileId;
    if (profileId == null) return;

    final current = _state.profileProgress[profileId] ?? const ProfileProgress();
    final entry = ActivityEntry(
      id: 'activity-${_uuid.v4()}',
      completedAt: DateTime.now().toUtc(),
      type: type,
      setId: setId,
      setTitle: setTitle,
      correctCount: correctCount,
      totalCount: totalCount,
    );

    final updatedLog = [entry, ...current.activityLog];
    if (updatedLog.length > maxActivityLogEntries) {
      updatedLog.removeRange(maxActivityLogEntries, updatedLog.length);
    }

    _state = _state.copyWith(
      profileProgress: {
        ..._state.profileProgress,
        profileId: current.copyWith(activityLog: updatedLog),
      },
    );
    await _persist();
  }

  Future<void> createProfile({
    required String displayName,
    String? avatarEmoji,
  }) async {
    if (_state.profiles.length >= maxProfiles) return;
    final profile = LocalProfile(
      id: 'profile-${_uuid.v4()}',
      displayName: displayName.trim(),
      createdAt: DateTime.now().toUtc(),
      avatarEmoji: avatarEmoji ?? presetEmojis.first,
    );
    _state = _state.copyWith(
      profiles: [..._state.profiles, profile],
      activeProfileId: profile.id,
      profileProgress: {
        ..._state.profileProgress,
        profile.id: const ProfileProgress(),
      },
    );
    await _persist();
  }

  Future<void> renameProfile(String profileId, String displayName) async {
    _state = _state.copyWith(
      profiles: _state.profiles
          .map(
            (profile) => profile.id == profileId
                ? profile.copyWith(displayName: displayName.trim())
                : profile,
          )
          .toList(),
    );
    await _persist();
  }

  Future<void> updateProfileEmoji(String profileId, String emoji) async {
    _state = _state.copyWith(
      profiles: _state.profiles
          .map(
            (profile) => profile.id == profileId
                ? profile.copyWith(
                    avatarEmoji: emoji,
                    clearAvatarPremiumId: true,
                  )
                : profile,
          )
          .toList(),
    );
    await _persist();
  }

  bool isIconOwned(ProfileIconEntry entry) {
    if (entry.free) return true;
    return _state.ownedPremiumIconIds.contains(entry.id);
  }

  bool isIconEquipped(ProfileIconEntry entry) {
    final profile = activeProfile;
    if (profile == null) return false;

    switch (entry.kind) {
      case ProfileIconKind.premium:
        return profile.avatarPremiumId == entry.id;
      case ProfileIconKind.emoji:
        return profile.avatarPremiumId == null &&
            (profile.avatarEmoji ?? presetEmojis.first) == entry.emoji;
    }
  }

  Future<void> equipProfileIcon(ProfileIconEntry entry) async {
    final profileId = _state.activeProfileId;
    if (profileId == null) return;

    _state = _state.copyWith(
      profiles: _state.profiles
          .map(
            (profile) {
              if (profile.id != profileId) return profile;
              switch (entry.kind) {
                case ProfileIconKind.premium:
                  return profile.copyWith(avatarPremiumId: entry.id);
                case ProfileIconKind.emoji:
                  return profile.copyWith(
                    avatarEmoji: entry.emoji ?? presetEmojis.first,
                    clearAvatarPremiumId: true,
                  );
              }
            },
          )
          .toList(),
    );
    await _persist();
  }

  Future<bool> purchasePremiumIcon(String iconId) async {
    if (_state.ownedPremiumIconIds.contains(iconId)) return true;

    final entry = ProfileIconCatalog.findById(iconId);
    if (entry == null || entry.kind != ProfileIconKind.premium) return false;

    final success = await _purchaseService.purchaseProduct(entry.productId);
    if (!success) return false;

    _state = _state.copyWith(
      ownedPremiumIconIds: [..._state.ownedPremiumIconIds, iconId],
    );
    await _persist();
    return true;
  }

  Future<void> deleteProfile(String profileId) async {
    final updatedProfiles =
        _state.profiles.where((profile) => profile.id != profileId).toList();
    final updatedProgress = Map<String, ProfileProgress>.from(
      _state.profileProgress,
    )..remove(profileId);

    String? activeId = _state.activeProfileId;
    if (activeId == profileId) {
      activeId = updatedProfiles.isNotEmpty ? updatedProfiles.first.id : null;
    }

    _state = _state.copyWith(
      profiles: updatedProfiles,
      profileProgress: updatedProgress,
      activeProfileId: activeId,
      clearActiveProfile: activeId == null,
    );
    await _persist();
  }

  Future<void> setActiveProfile(String profileId) async {
    _state = _state.copyWith(activeProfileId: profileId);
    await _persist();
  }

  Future<void> selectSet(String setId) async {
    final profileId = _state.activeProfileId;
    if (profileId == null) return;

    final current = _state.profileProgress[profileId] ?? const ProfileProgress();
    final updatedSets = Map<String, SetProgress>.from(current.sets);
    updatedSets.putIfAbsent(setId, () => const SetProgress());

    _state = _state.copyWith(
      profileProgress: {
        ..._state.profileProgress,
        profileId: current.copyWith(
          selectedSetId: setId,
          sets: updatedSets,
        ),
      },
    );
    await _persist();
  }

  Future<void> setLastMode(String setId, String mode) async {
    final profileId = _state.activeProfileId;
    if (profileId == null) return;
    final current = _state.profileProgress[profileId] ?? const ProfileProgress();
    _state = _state.copyWith(
      profileProgress: {
        ..._state.profileProgress,
        profileId: current.copyWith(
          lastModeBySet: {...current.lastModeBySet, setId: mode},
        ),
      },
    );
    await _persist();
  }

  Future<void> updateSettings(AppSettings settings) async {
    _state = _state.copyWith(settings: settings);
    await _tts.applySpeechSpeed(settings.speechSpeed);
    await _persist();
  }

  Future<void> markReviewed(String setId, String wordId) async {
    await _updateWordProgress(setId, wordId, (progress) {
      if (progress.reviewed) return progress;
      return progress.copyWith(
        reviewed: true,
        lastPracticedAt: DateTime.now().toUtc(),
      );
    });
  }

  Future<void> markQuizAttempt(
    String setId,
    String wordId, {
    required bool correct,
  }) async {
    await _updateWordProgress(setId, wordId, (progress) {
      return progress.copyWith(
        quizAttempts: progress.quizAttempts + 1,
        quizCorrectCount: progress.quizCorrectCount + (correct ? 1 : 0),
        quizCorrect: correct || progress.quizCorrect,
        lastPracticedAt: DateTime.now().toUtc(),
      );
    });
  }

  Future<void> markSpellingAttempt(
    String setId,
    String wordId, {
    required bool correct,
  }) async {
    await _updateWordProgress(setId, wordId, (progress) {
      return progress.copyWith(
        spellingAttempts: progress.spellingAttempts + 1,
        spellingCompleted: correct || progress.spellingCompleted,
        lastPracticedAt: DateTime.now().toUtc(),
      );
    });
  }

  Future<void> markTypedAttempt(
    String setId,
    String wordId, {
    required bool correct,
  }) async {
    await _updateWordProgress(setId, wordId, (progress) {
      return progress.copyWith(
        typedAttempts: progress.typedAttempts + 1,
        typedCompleted: correct || progress.typedCompleted,
        lastPracticedAt: DateTime.now().toUtc(),
      );
    });
  }

  Future<void> resetSet(String setId) async {
    final profileId = _state.activeProfileId;
    if (profileId == null) return;
    final current = _state.profileProgress[profileId] ?? const ProfileProgress();
    final updatedSets = Map<String, SetProgress>.from(current.sets);
    updatedSets[setId] = const SetProgress();
    _state = _state.copyWith(
      profileProgress: {
        ..._state.profileProgress,
        profileId: current.copyWith(sets: updatedSets),
      },
    );
    await _persist();
  }

  Future<void> resetAllForActiveProfile() async {
    final profileId = _state.activeProfileId;
    if (profileId == null) return;
    final current = _state.profileProgress[profileId] ?? const ProfileProgress();
    _state = _state.copyWith(
      profileProgress: {
        ..._state.profileProgress,
        profileId: current.copyWith(sets: {}),
      },
    );
    await _persist();
  }

  Future<void> _updateWordProgress(
    String setId,
    String wordId,
    WordProgress Function(WordProgress progress) update,
  ) async {
    final profileId = _state.activeProfileId;
    if (profileId == null) return;

    final current = _state.profileProgress[profileId] ?? const ProfileProgress();
    final setProgress = current.sets[setId] ?? const SetProgress();
    final wordProgress = Map<String, WordProgress>.from(setProgress.wordProgress);
    final existing = wordProgress[wordId] ?? WordProgress.empty(wordId);
    wordProgress[wordId] = update(existing);

    final updatedSets = Map<String, SetProgress>.from(current.sets)
      ..[setId] = SetProgress(wordProgress: wordProgress);

    _state = _state.copyWith(
      profileProgress: {
        ..._state.profileProgress,
        profileId: current.copyWith(sets: updatedSets),
      },
    );
    await _persist();
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (!iterator.moveNext()) return null;
    return iterator.current;
  }
}
