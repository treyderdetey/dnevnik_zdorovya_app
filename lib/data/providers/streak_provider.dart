import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/date_utils.dart';
import '../models/streak_model.dart';

class StreakProvider extends ChangeNotifier {
  late Box<StreakModel> _streakBox;

  StreakProvider() {
    _streakBox = Hive.box<StreakModel>(AppConstants.streakBox);
  }

  int getStreak(String type) {
    final streak = _getOrCreate(type);
    // Check if streak is still valid (not broken by missed day)
    final today = AppDateUtils.dateOnly(DateTime.now());
    final lastCompleted = AppDateUtils.dateOnly(streak.lastCompletedDate);
    final diff = today.difference(lastCompleted).inDays;

    if (diff > 1) {
      // Streak broken
      streak.currentStreak = 0;
      streak.save();
    }
    return streak.currentStreak;
  }

  int getLongestStreak(String type) {
    return _getOrCreate(type).longestStreak;
  }

  bool get shouldCelebrateWater => _shouldCelebrate('water');
  bool get shouldCelebrateMedicine => _shouldCelebrate('medicine');

  Future<void> recordCompletion(String type) async {
    final streak = _getOrCreate(type);
    final today = AppDateUtils.dateOnly(DateTime.now());
    final lastCompleted = AppDateUtils.dateOnly(streak.lastCompletedDate);

    // Already recorded today
    if (AppDateUtils.isSameDay(today, lastCompleted)) return;

    final diff = today.difference(lastCompleted).inDays;

    if (diff == 1) {
      // Consecutive day
      streak.currentStreak++;
    } else if (diff > 1) {
      // Streak broken, start new
      streak.currentStreak = 1;
      streak.streakStartDate = today;
    } else {
      streak.currentStreak = 1;
    }

    if (streak.currentStreak > streak.longestStreak) {
      streak.longestStreak = streak.currentStreak;
    }

    streak.lastCompletedDate = today;
    await streak.save();
    notifyListeners();
  }

  bool _shouldCelebrate(String type) {
    final streak = _getOrCreate(type);
    const milestones = [3, 7, 14, 21, 30, 50, 75, 100, 150, 200, 365];
    return milestones.contains(streak.currentStreak);
  }

  StreakModel _getOrCreate(String type) {
    final existing = _streakBox.values
        .where((s) => s.type == type)
        .firstOrNull;

    if (existing != null) return existing;

    final newStreak = StreakModel(
      id: type,
      type: type,
      lastCompletedDate: DateTime(2000),
      streakStartDate: DateTime.now(),
    );
    _streakBox.add(newStreak);
    return newStreak;
  }
}
