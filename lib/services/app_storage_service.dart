import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_state.dart';

class AppStorageService {
  static const storageKey = 'vocab_app_state_v1';

  Future<AppState> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) {
      return AppState.empty();
    }

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return AppState.fromJson(decoded);
    } catch (_) {
      return AppState.empty();
    }
  }

  Future<void> save(AppState state) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(state.toJson());
    await prefs.setString(storageKey, encoded);
  }
}
