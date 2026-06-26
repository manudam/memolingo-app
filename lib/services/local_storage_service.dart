import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_user.dart';

class LocalStorageService {
  static const _userKey = 'memolingo_user_v1';

  Future<AppUser> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_userKey);
    if (raw == null || raw.isEmpty) {
      return AppUser();
    }

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return AppUser.fromMap(decoded);
    } catch (_) {
      return AppUser();
    }
  }

  Future<void> saveUser(AppUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toMap()));
  }
}
