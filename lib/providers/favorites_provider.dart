import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/job.dart';

/// Persists favorited jobs as JSON in [SharedPreferences].
class FavoritesProvider extends ChangeNotifier {
  static const String _storageKey = 'favorite_jobs_v1';

  final Map<String, Job> _favorites = {};
  bool _isLoaded = false;

  List<Job> get favorites => _favorites.values.toList().reversed.toList();
  bool get isLoaded => _isLoaded;
  int get count => _favorites.length;

  bool isFavorite(String jobId) => _favorites.containsKey(jobId);

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_storageKey) ?? const [];
      for (final entry in raw) {
        final decoded = jsonDecode(entry);
        if (decoded is Map<String, dynamic>) {
          final job = Job.fromJson(decoded);
          _favorites[job.id] = job;
        }
      }
    } catch (_) {
      _favorites.clear();
    }
    _isLoaded = true;
    notifyListeners();
  }

  /// Returns `true` when the job ended up favorited.
  Future<bool> toggle(Job job) async {
    final added = !_favorites.containsKey(job.id);
    if (added) {
      _favorites[job.id] = job;
    } else {
      _favorites.remove(job.id);
    }
    notifyListeners();
    await _persist();
    return added;
  }

  Future<void> remove(String jobId) async {
    if (_favorites.remove(jobId) == null) return;
    notifyListeners();
    await _persist();
  }

  Future<void> clear() async {
    if (_favorites.isEmpty) return;
    _favorites.clear();
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        _storageKey,
        _favorites.values.map((job) => jsonEncode(job.toJson())).toList(),
      );
    } catch (_) {
      // Persistence failures must not break the in-memory experience.
    }
  }
}
