import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/notification_service.dart';
import '../models/sleep_model.dart';
import 'gamification_provider.dart';

class SleepProvider extends ChangeNotifier {
  late Box<SleepRecord> _sleepBox;
  late Box _settingsBox;
  final _uuid = const Uuid();
  GamificationProvider? _gamificationProvider;

  List<SleepRecord> _records = [];
  TimeOfDay _bedtimeReminder = const TimeOfDay(hour: 22, minute: 0);
  bool _reminderEnabled = false;

  SleepProvider() {
    _sleepBox = Hive.box<SleepRecord>(AppConstants.sleepBox);
    _settingsBox = Hive.box(AppConstants.settingsBox);
    _loadData();
  }

  void updateGamification(GamificationProvider provider) {
    _gamificationProvider = provider;
  }

  List<SleepRecord> get records => List.unmodifiable(_records);
  TimeOfDay get bedtimeReminder => _bedtimeReminder;
  bool get reminderEnabled => _reminderEnabled;

  SleepRecord? get lastNight {
    if (_records.isEmpty) return null;
    return _records.first;
  }

  double get averageDuration {
    if (_records.isEmpty) return 0;
    final recent = _records.take(7).toList();
    return recent.fold(0.0, (sum, r) => sum + r.durationHours) / recent.length;
  }

  double get averageQuality {
    if (_records.isEmpty) return 0;
    final recent = _records.take(7).toList();
    return recent.fold(0.0, (sum, r) => sum + r.quality) / recent.length;
  }

  /// Weekly sleep data for charts
  Map<String, double> get weeklySleepData {
    final result = <String, double>{};
    final now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateKey = AppDateUtils.formatDateShort(date);
      final record = _records.where(
        (r) => AppDateUtils.isSameDay(r.date, date),
      ).firstOrNull;
      result[dateKey] = record?.durationHours ?? 0;
    }
    return result;
  }

  /// Sleep quality distribution
  Map<String, int> get qualityDistribution {
    final dist = <String, int>{
      'Terrible': 0, 'Poor': 0, 'Fair': 0, 'Good': 0, 'Excellent': 0,
    };
    for (final r in _records.take(30)) {
      dist[r.qualityLabel] = (dist[r.qualityLabel] ?? 0) + 1;
    }
    return dist;
  }

  int get sleepStreak {
    if (_records.isEmpty) return 0;
    int streak = 0;
    var checkDate = AppDateUtils.dateOnly(DateTime.now());
    for (int i = 0; i < 365; i++) {
      final hasRecord = _records.any(
        (r) => AppDateUtils.isSameDay(r.date, checkDate),
      );
      if (hasRecord) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  void _loadData() {
    _records = _sleepBox.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final bedHour = _settingsBox.get('bedtime_hour', defaultValue: 22);
    final bedMin = _settingsBox.get('bedtime_minute', defaultValue: 0);
    _bedtimeReminder = TimeOfDay(hour: bedHour, minute: bedMin);
    _reminderEnabled = _settingsBox.get('bedtime_reminder', defaultValue: false);

    notifyListeners();
  }

  Future<void> addSleepRecord({
    required DateTime bedTime,
    required DateTime wakeTime,
    required int quality,
    String? notes,
  }) async {
    // Remove existing record for today
    final today = AppDateUtils.dateOnly(DateTime.now());
    final existing = _sleepBox.values
        .where((r) => AppDateUtils.isSameDay(r.date, today))
        .toList();
    for (final r in existing) {
      await r.delete();
    }

    final record = SleepRecord(
      id: _uuid.v4(),
      date: today,
      bedTime: bedTime,
      wakeTime: wakeTime,
      quality: quality,
      notes: notes,
    );
    await _sleepBox.add(record);
    _loadData();
    
    // Обновляем прогресс в достижениях
    _gamificationProvider?.updateProgress('sleep', record.durationHours.toInt());
  }

  Future<void> deleteRecord(String id) async {
    final record = _records.where((r) => r.id == id).firstOrNull;
    if (record != null) {
      await record.delete();
      _loadData();
    }
  }

  Future<void> setBedtimeReminder(TimeOfDay time) async {
    _bedtimeReminder = time;
    await _settingsBox.put('bedtime_hour', time.hour);
    await _settingsBox.put('bedtime_minute', time.minute);
    if (_reminderEnabled) {
      await _scheduleBedtimeReminder();
    }
    notifyListeners();
  }

  Future<void> toggleReminder(bool enabled) async {
    _reminderEnabled = enabled;
    await _settingsBox.put('bedtime_reminder', enabled);
    if (enabled) {
      await _scheduleBedtimeReminder();
    } else {
      await NotificationService.instance.cancelNotification(8888);
    }
    notifyListeners();
  }

  Future<void> _scheduleBedtimeReminder() async {
    await NotificationService.instance.scheduleDailyNotification(
      id: 8888,
      title: 'Пора ложиться спать 🌙',
      body: 'Самое время отдохнуть и набраться сил для завтрашнего дня!',
      hour: _bedtimeReminder.hour,
      minute: _bedtimeReminder.minute,
      channelId: 'sleep_reminders',
      channelName: 'Напоминания о сне',
    );
  }
}
