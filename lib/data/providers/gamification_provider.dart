import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/date_utils.dart';
import '../models/blood_pressure_model.dart';
import '../models/challenge_model.dart';

class GamificationProvider extends ChangeNotifier {
  late Box<DailyChallenge> _challengeBox;
  late Box<UserAchievement> _achievementBox;
  late Box _settingsBox;
  final _uuid = const Uuid();

  List<DailyChallenge> _challenges = [];
  List<UserAchievement> _achievements = [];

  GamificationProvider() {
    _challengeBox = Hive.box<DailyChallenge>(AppConstants.challengeBox);
    _achievementBox = Hive.box<UserAchievement>(AppConstants.achievementBox);
    _settingsBox = Hive.box(AppConstants.settingsBox);
    _ensureTodayChallenges();
    _loadData();
  }

  List<DailyChallenge> get challenges => List.unmodifiable(_challenges);
  List<UserAchievement> get achievements => List.unmodifiable(_achievements);

  List<DailyChallenge> get todayChallenges {
    final today = AppDateUtils.dateOnly(DateTime.now());
    return _challenges
        .where((c) => AppDateUtils.isSameDay(c.date, today))
        .toList();
  }

  int get todayCompletedCount =>
      todayChallenges.where((c) => c.completed).length;

  int get totalPoints {
    return _settingsBox.get('total_points', defaultValue: 0);
  }

  int get currentLevel => (totalPoints / 100).floor() + 1;

  double get levelProgress => (totalPoints % 100) / 100;

  String get levelTitle {
    if (currentLevel <= 2) return 'Новичок';
    if (currentLevel <= 5) return 'Исследователь здоровья';
    if (currentLevel <= 10) return 'Воин благополучия';
    if (currentLevel <= 20) return 'Чемпион здоровья';
    if (currentLevel <= 35) return 'Мастер велнеса';
    return 'Легенда здоровья';
  }

  int get totalChallengesCompleted {
    return _challenges.where((c) => c.completed).length;
  }

  static const List<Map<String, dynamic>> _challengeTemplates = [
    {'title': 'Герой гидратации', 'desc': 'Выпейте 8 стаканов воды сегодня', 'cat': 'water', 'pts': 15},
    {'title': 'Ранняя пташка', 'desc': 'Запишите свой сон до 10 утра', 'cat': 'sleep', 'pts': 10},
    {'title': 'Мастер лекарств', 'desc': 'Примите все лекарства вовремя', 'cat': 'medicine', 'pts': 20},
    {'title': 'Проверка настроения', 'desc': 'Запишите свое настроение сегодня', 'cat': 'mood', 'pts': 10},
    {'title': 'Супер гидратор', 'desc': 'Выпейте 10 стаканов воды', 'cat': 'water', 'pts': 25},
    {'title': 'Режим дзен', 'desc': 'Оцените настроение как Хорошее или Отличное', 'cat': 'mood', 'pts': 15},
    {'title': 'Чемпион сна', 'desc': 'Поспите не менее 7 часов', 'cat': 'sleep', 'pts': 20},
    {'title': 'Король последовательности', 'desc': 'Выполните все ежедневные задачи', 'cat': 'general', 'pts': 30},
    {'title': 'Водная серия', 'desc': 'Достигайте цели по воде 3 дня подряд', 'cat': 'water', 'pts': 25},
    {'title': 'Автор здоровья', 'desc': 'Сделайте запись в дневнике настроения', 'cat': 'mood', 'pts': 10},
    {'title': 'Больше не сова', 'desc': 'Лягте спать до 23:00 сегодня', 'cat': 'sleep', 'pts': 15},
    {'title': 'Идеальный прием', 'desc': 'Не пропустите ни одной дозы лекарств', 'cat': 'medicine', 'pts': 20},
    {'title': 'Воскресенье заботы', 'desc': 'Запишите все показатели здоровья сегодня', 'cat': 'general', 'pts': 25},
    {'title': 'Аква чемпион', 'desc': 'Выпейте 2 литра воды (8+ стаканов)', 'cat': 'water', 'pts': 20},
    {'title': 'Трекер снов', 'desc': 'Оцените качество сна сегодня', 'cat': 'sleep', 'pts': 10},
    {'title': 'Контроль давления', 'desc': 'Запишите показатели давления сегодня', 'cat': 'health', 'pts': 15},
    {'title': 'Ритм сердца', 'desc': 'Замерьте пульс после отдыха', 'cat': 'health', 'pts': 10},
  ];

  static const List<Map<String, String>> _achievementDefs = [
    {'id': 'first_steps', 'title': 'Первые шаги', 'desc': 'Выполните свою первую задачу', 'icon': '🌱', 'pts': '0'},
    {'id': 'week_warrior', 'title': 'Воин недели', 'desc': 'Выполните 7 задач', 'icon': '⚡', 'pts': '70'},
    {'id': 'hydration_hero', 'title': 'Герой гидратации', 'desc': 'Заработайте 100 очков', 'icon': '💧', 'pts': '100'},
    {'id': 'health_explorer', 'title': 'Исследователь', 'desc': 'Достигните 3 уровня', 'icon': '🗺️', 'pts': '200'},
    {'id': 'wellness_warrior', 'title': 'Воин здоровья', 'desc': 'Заработайте 500 очков', 'icon': '🛡️', 'pts': '500'},
    {'id': 'champion', 'title': 'Чемпион здоровья', 'desc': 'Заработайте 1000 очков', 'icon': '🏆', 'pts': '1000'},
    {'id': 'legend', 'title': 'Легенда здоровья', 'desc': 'Заработайте 2000 очков', 'icon': '👑', 'pts': '2000'},
    {'id': 'streak_3', 'title': 'В огне', 'desc': '3-дневная серия задач', 'icon': '🔥', 'pts': '50'},
    {'id': 'streak_7', 'title': 'Неудержимый', 'desc': '7-дневная серия задач', 'icon': '🚀', 'pts': '150'},
    {'id': 'streak_30', 'title': 'Мастер месяца', 'desc': '30-дневная серия задач', 'icon': '💎', 'pts': '500'},
    {'id': 'bp_tracker', 'title': 'Кардио-контроль', 'desc': 'Сделайте 5 записей давления', 'icon': '❤️', 'pts': '50'},
  ];

  void _loadData() {
    _challenges = _challengeBox.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    _achievements = _achievementBox.values.toList();
    notifyListeners();
  }

  Future<void> _ensureTodayChallenges() async {
    final today = AppDateUtils.dateOnly(DateTime.now());
    final hasTodayChallenges = _challengeBox.values
        .any((c) => AppDateUtils.isSameDay(c.date, today));

    if (!hasTodayChallenges) {
      // Выбирает 3 рандомных задания на день
      final dayOfYear = today.difference(DateTime(today.year, 1, 1)).inDays;
      final templates = List<Map<String, dynamic>>.from(_challengeTemplates);
      final selected = <Map<String, dynamic>>[];

      for (int i = 0; i < 3 && templates.isNotEmpty; i++) {
        final index = (dayOfYear + i * 7) % templates.length;
        selected.add(templates.removeAt(index % templates.length));
      }

      for (final t in selected) {
        await _challengeBox.add(DailyChallenge(
          id: _uuid.v4(),
          date: today,
          title: t['title'] as String,
          description: t['desc'] as String,
          category: t['cat'] as String,
          points: t['pts'] as int,
        ));
      }
    }
  }

  Future<void> completeChallenge(String challengeId) async {
    final index = _challenges.indexWhere((c) => c.id == challengeId);
    if (index == -1 || _challenges[index].completed) return;

    _challenges[index].completed = true;
    _challenges[index].completedAt = DateTime.now();
    await _challenges[index].save();

    // Добавляем очки
    final pts = totalPoints + _challenges[index].points;
    await _settingsBox.put('total_points', pts);

    // Проверяем новые ачивки
    await _checkAchievements();

    _loadData();
  }

  Future<void> updateProgress(String category, dynamic value) async {
    final today = AppDateUtils.dateOnly(DateTime.now());
    // Ищем невыполненные задания на сегодня по этой категории
    final activeChallenges = todayChallenges.where((c) => !c.completed && (c.category == category || c.category == 'general'));

    for (final challenge in activeChallenges) {
      bool shouldComplete = false;

      switch (category) {
        case 'water':
          // Если value это количество стаканов
          if (value is int) {
            if (challenge.title.contains('8') && value >= 8) shouldComplete = true;
            if (challenge.title.contains('10') && value >= 10) shouldComplete = true;
            if (challenge.title.contains('2 литра') && value >= 8) shouldComplete = true;
            // Любое задание по воде выполняется при любой активности, если оно общее
            if (!challenge.title.contains('8') && !challenge.title.contains('10')) shouldComplete = true;
          }
          break;
        case 'sleep':
          // Для сна проверяем время или оценку
          shouldComplete = true; 
          break;
        case 'mood':
          // Для настроения - просто факт записи
          shouldComplete = true;
          break;
        case 'medicine':
          // Для лекарств - если прислали сигнал об успешном приеме
          shouldComplete = true;
          break;
        case 'health':
          shouldComplete = true;
          break;
      }

      if (shouldComplete) {
        await completeChallenge(challenge.id);
      }
    }
    
    // Проверка задания "Король последовательности" (выполнить всё)
    final generalChallenge = todayChallenges.firstWhere(
      (c) => !c.completed && c.category == 'general', 
      orElse: () => todayChallenges.first // fallback
    );
    
    if (todayCompletedCount >= 2 && !generalChallenge.completed) {
       // Если выполнено 2 других задания, закрываем и общее
       await completeChallenge(generalChallenge.id);
    }
  }

  Future<void> _checkAchievements() async {
    final earnedIds = _achievements.map((a) => a.id).toSet();

    for (final def in _achievementDefs) {
      if (earnedIds.contains(def['id'])) continue;

      final requiredPts = int.parse(def['pts']!);
      bool earned = false;

      if (def['id'] == 'first_steps' && totalChallengesCompleted >= 1) {
        earned = true;
      } else if (def['id'] == 'week_warrior' && totalChallengesCompleted >= 7) {
        earned = true;
      } else if (totalPoints >= requiredPts && requiredPts > 0) {
        earned = true;
      }

      if (earned) {
        await _achievementBox.add(UserAchievement(
          id: def['id']!,
          title: def['title']!,
          description: def['desc']!,
          icon: def['icon']!,
          earnedAt: DateTime.now(),
          pointsRequired: requiredPts,
        ));
      }
    }
  }

  Future<void> checkBloodPressureAchievement(int recordCount) async {
    final earnedIds = _achievements.map((a) => a.id).toSet();
    if (earnedIds.contains('bp_tracker')) return;

    if (recordCount >= 5) {
      final def = _achievementDefs.firstWhere((d) => d['id'] == 'bp_tracker');
      await _achievementBox.add(UserAchievement(
        id: def['id']!,
        title: def['title']!,
        description: def['desc']!,
        icon: def['icon']!,
        earnedAt: DateTime.now(),
        pointsRequired: int.parse(def['pts']!),
      ));
      _loadData();
    }
  }

  List<Map<String, String>> get allAchievementDefs => _achievementDefs;
}
