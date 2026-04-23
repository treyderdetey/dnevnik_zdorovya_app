import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/date_utils.dart';
import '../models/habit_model.dart';

class HabitProvider extends ChangeNotifier {
  late Box<HabitModel> _habitBox;
  late Box<HabitCompletion> _completionBox;
  final _uuid = const Uuid();

  List<HabitModel> _habits = [];
  List<HabitCompletion> _completions = [];

  HabitProvider() {
    _habitBox = Hive.box<HabitModel>(AppConstants.habitBox);
    _completionBox = Hive.box<HabitCompletion>(AppConstants.habitCompletionBox);
    _loadData();
  }

  List<HabitModel> get habits => _habits.where((h) => h.isActive).toList();
  List<HabitModel> get allHabits => List.unmodifiable(_habits);

  int get todayCompletedCount {
    final today = AppDateUtils.dateOnly(DateTime.now());
    final todayCompletions = _completions
        .where((c) => AppDateUtils.isSameDay(c.date, today))
        .map((c) => c.habitId)
        .toSet();
    return habits.where((h) => todayCompletions.contains(h.id)).length;
  }

  double get todayProgress {
    if (habits.isEmpty) return 0;
    return todayCompletedCount / habits.length;
  }

  bool isCompletedToday(String habitId) {
    final today = AppDateUtils.dateOnly(DateTime.now());
    return _completions.any(
      (c) => c.habitId == habitId && AppDateUtils.isSameDay(c.date, today),
    );
  }

  int getStreak(String habitId) {
    int streak = 0;
    var checkDate = AppDateUtils.dateOnly(DateTime.now());
    for (int i = 0; i < 365; i++) {
      final done = _completions.any(
        (c) => c.habitId == habitId && AppDateUtils.isSameDay(c.date, checkDate),
      );
      if (done) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  int getTotalCompletions(String habitId) {
    return _completions.where((c) => c.habitId == habitId).length;
  }

  /// Получите данные о завершении заданий за последние 7 дней по привычке.
  Map<String, bool> getWeeklyData(String habitId) {
    final result = <String, bool>{};
    final now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final key = AppDateUtils.formatDateShort(date);
      result[key] = _completions.any(
        (c) => c.habitId == habitId && AppDateUtils.isSameDay(c.date, date),
      );
    }
    return result;
  }

  void _loadData() {
    _habits = _habitBox.values.toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    _completions = _completionBox.values.toList();
    notifyListeners();
  }

  Future<void> addHabit({
    required String name,
    required String icon,
    required String color,
  }) async {
    await _habitBox.add(HabitModel(
      id: _uuid.v4(),
      name: name,
      icon: icon,
      color: color,
      createdAt: DateTime.now(),
    ));
    _loadData();
  }

  Future<void> toggleCompletion(String habitId) async {
    final today = AppDateUtils.dateOnly(DateTime.now());
    final existing = _completions.where(
      (c) => c.habitId == habitId && AppDateUtils.isSameDay(c.date, today),
    ).toList();

    if (existing.isNotEmpty) {
      for (final c in existing) {
        await c.delete();
      }
    } else {
      await _completionBox.add(HabitCompletion(
        id: _uuid.v4(),
        habitId: habitId,
        date: today,
      ));
    }
    _loadData();
  }

  Future<void> deleteHabit(String id) async {
    final habit = _habits.where((h) => h.id == id).firstOrNull;
    if (habit != null) {
      await habit.delete();
      // Delete completions
      final completions = _completions.where((c) => c.habitId == id).toList();
      for (final c in completions) {
        await c.delete();
      }
      _loadData();
    }
  }
}
