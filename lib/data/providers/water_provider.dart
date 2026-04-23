import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/notification_service.dart';
import '../models/water_model.dart';
import 'gamification_provider.dart';

class WaterProvider extends ChangeNotifier {
  late Box<WaterIntake> _waterBox;
  late Box _settingsBox;
  final _uuid = const Uuid();
  GamificationProvider? _gamificationProvider;

  List<WaterIntake> _intakes = [];
  int _dailyGoal = AppConstants.defaultWaterGoal;
  int _reminderInterval = AppConstants.defaultWaterReminderInterval;
  bool _reminderEnabled = true;

  WaterProvider() {
    _waterBox = Hive.box<WaterIntake>(AppConstants.waterBox);
    _settingsBox = Hive.box(AppConstants.settingsBox);
    _loadData();
    initReminders();
  }

  // Метод для связи с геймификацией
  void updateGamification(GamificationProvider provider) {
    _gamificationProvider = provider;
  }

  List<WaterIntake> get allIntakes => List.unmodifiable(_intakes);
  int get dailyGoal => _dailyGoal;
  int get reminderInterval => _reminderInterval;
  bool get reminderEnabled => _reminderEnabled;

  int get todayMl {
    final today = AppDateUtils.dateOnly(DateTime.now());
    return _intakes
        .where((i) => AppDateUtils.isSameDay(i.date, today))
        .fold(0, (sum, i) => sum + (i.ml ?? (i.glasses * AppConstants.waterGlassMl)));
  }

  int get todayGlasses => (todayMl / AppConstants.waterGlassMl).floor();
  int get goalMl => _dailyGoal * AppConstants.waterGlassMl;
  bool get goalReached => todayMl >= goalMl;

  double get todayProgress {
    if (goalMl == 0) return 0;
    return (todayMl / goalMl).clamp(0.0, 1.0);
  }

  /// Get weekly data (last 7 days) in "glasses" equivalent
  Map<String, int> get weeklyData {
    final result = <String, int>{};
    final now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateKey = AppDateUtils.formatDateShort(date);
      final totalMl = _intakes
          .where((intake) => AppDateUtils.isSameDay(intake.date, date))
          .fold(0, (sum, i) => sum + (i.ml ?? (i.glasses * AppConstants.waterGlassMl)));
      result[dateKey] = (totalMl / AppConstants.waterGlassMl).floor();
    }
    return result;
  }

  void _loadData() {
    _intakes = _waterBox.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    _dailyGoal = _settingsBox.get(
      AppConstants.keyWaterGoal,
      defaultValue: AppConstants.defaultWaterGoal,
    );
    _reminderInterval = _settingsBox.get(
      AppConstants.keyWaterReminderInterval,
      defaultValue: AppConstants.defaultWaterReminderInterval,
    );
    _reminderEnabled = _settingsBox.get(
      AppConstants.keyWaterReminderEnabled,
      defaultValue: true,
    );
    notifyListeners();
  }

  Future<void> addWater({int glasses = 1, int? ml}) async {
    final now = DateTime.now();
    
    final intake = WaterIntake(
      id: _uuid.v4(),
      date: AppDateUtils.dateOnly(now),
      glasses: ml != null ? (ml / AppConstants.waterGlassMl).ceil() : glasses,
      ml: ml,
      timestamp: now,
    );
    await _waterBox.add(intake);
    _loadData();
    
    // АВТОМАТИЧЕСКИ обновляем прогресс в заданиях
    _gamificationProvider?.updateProgress('water', todayGlasses);
  }

  Future<void> removeLastIntake() async {
    final today = AppDateUtils.dateOnly(DateTime.now());
    final todayIntakes = _waterBox.values
        .where((i) => AppDateUtils.isSameDay(i.date, today))
        .toList();
    if (todayIntakes.isNotEmpty) {
      todayIntakes.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      await todayIntakes.first.delete();
      _loadData();
      _gamificationProvider?.updateProgress('water', todayGlasses);
    }
  }

  Future<void> updateDailyGoal(int goal) async {
    _dailyGoal = goal;
    await _settingsBox.put(AppConstants.keyWaterGoal, goal);
    notifyListeners();
  }

  Future<void> updateReminderInterval(int hours) async {
    _reminderInterval = hours;
    await _settingsBox.put(AppConstants.keyWaterReminderInterval, hours);
    if (_reminderEnabled) {
      await _setupWaterReminder();
    }
    notifyListeners();
  }

  Future<void> toggleReminder(bool enabled) async {
    _reminderEnabled = enabled;
    await _settingsBox.put(AppConstants.keyWaterReminderEnabled, enabled);
    if (enabled) {
      await _setupWaterReminder();
    } else {
      await NotificationService.instance.cancelNotification(9999);
    }
    notifyListeners();
  }

  Future<void> _setupWaterReminder() async {
    await NotificationService.instance.cancelNotification(9999);
    if (_reminderEnabled) {
      await NotificationService.instance.scheduleRepeatingNotification(
        id: 9999,
        title: 'Пора выпить воды 💧',
        body: 'Не забудьте выпить стакан чистой воды для поддержания здоровья!',
        interval: RepeatInterval.hourly,
        channelId: AppConstants.waterChannelId,
        channelName: AppConstants.waterChannelName,
      );
      debugPrint('УВЕДОМЛЕНИЕ О ВОДЕ ЗАПЛАНИРОВАНО: каждый час');
    }
  }

  Future<void> initReminders() async {
    if (_reminderEnabled) {
      await _setupWaterReminder();
    }
  }

  Future<void> testNotification() async {
    await NotificationService.instance.showInstantNotification(
      id: 9999,
      title: 'Пора выпить воды 💧',
      body: 'Не забудьте выпить стакан чистой воды для поддержания здоровья!',
      channelId: AppConstants.waterChannelId,
      channelName: AppConstants.waterChannelName,
    );
  }
}
