import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/date_utils.dart';
import '../models/mood_model.dart';
import 'gamification_provider.dart';

class MoodProvider extends ChangeNotifier {
  late Box<MoodEntry> _moodBox;
  final _uuid = const Uuid();
  GamificationProvider? _gamificationProvider;

  List<MoodEntry> _entries = [];

  MoodProvider() {
    _moodBox = Hive.box<MoodEntry>(AppConstants.moodBox);
    _loadData();
  }

  void updateGamification(GamificationProvider provider) {
    _gamificationProvider = provider;
  }

  List<MoodEntry> get entries => List.unmodifiable(_entries);

  MoodEntry? get todayMood {
    final today = AppDateUtils.dateOnly(DateTime.now());
    return _entries
        .where((e) => AppDateUtils.isSameDay(e.date, today))
        .firstOrNull;
  }

  List<MoodEntry> get weeklyMoods {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return _entries.where((e) => e.date.isAfter(weekAgo)).toList();
  }

  double get averageMoodScore {
    if (_entries.isEmpty) return 0;
    final recent = _entries.take(30).toList();
    return recent.fold(0, (sum, e) => sum + e.moodScore) / recent.length;
  }

  int get moodStreak {
    if (_entries.isEmpty) return 0;
    int streak = 0;
    var checkDate = AppDateUtils.dateOnly(DateTime.now());

    for (int i = 0; i < 365; i++) {
      final hasEntry = _entries.any(
        (e) => AppDateUtils.isSameDay(e.date, checkDate),
      );
      if (hasEntry) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  Map<String, int> get moodDistribution {
    final dist = <String, int>{};
    for (final entry in _entries.take(30)) {
      dist[entry.emoji] = (dist[entry.emoji] ?? 0) + 1;
    }
    return dist;
  }

  /// Ежемесячные данные о настроении для графиков: день -> moodScore
  Map<int, int> get monthlyMoodData {
    final now = DateTime.now();
    final result = <int, int>{};
    for (final entry in _entries) {
      if (entry.date.month == now.month && entry.date.year == now.year) {
        result[entry.date.day] = entry.moodScore;
      }
    }
    return result;
  }

  void _loadData() {
    _entries = _moodBox.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  Future<void> addMoodEntry({
    required String emoji,
    required String moodLabel,
    required int moodScore,
    String? journalText,
    List<String> tags = const [],
  }) async {
    // Remove existing entry for today if any
    final today = AppDateUtils.dateOnly(DateTime.now());
    final existing = _moodBox.values
        .where((e) => AppDateUtils.isSameDay(e.date, today))
        .toList();
    for (final e in existing) {
      await e.delete();
    }

    final entry = MoodEntry(
      id: _uuid.v4(),
      date: today,
      emoji: emoji,
      moodLabel: moodLabel,
      moodScore: moodScore,
      journalText: journalText,
      tags: tags,
      createdAt: DateTime.now(),
    );
    await _moodBox.add(entry);
    _loadData();
    
    // Обновляем прогресс в достижениях (1 запись в день)
    _gamificationProvider?.updateProgress('mood', 1);
  }

  Future<void> deleteEntry(String id) async {
    final entry = _entries.where((e) => e.id == id).firstOrNull;
    if (entry != null) {
      await entry.delete();
      _loadData();
    }
  }
}
