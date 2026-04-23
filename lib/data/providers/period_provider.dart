import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/date_utils.dart';
import '../models/period_model.dart';

class PeriodProvider extends ChangeNotifier {
  late Box<PeriodRecord> _periodBox;
  late Box<SymptomEntry> _symptomBox;
  late Box _settingsBox;
  final _uuid = const Uuid();

  List<PeriodRecord> _records = [];
  List<SymptomEntry> _symptoms = [];
  int _cycleLength = AppConstants.defaultCycleLength;
  int _periodDuration = AppConstants.defaultPeriodDuration;

  PeriodProvider() {
    _periodBox = Hive.box<PeriodRecord>(AppConstants.periodBox);
    _symptomBox = Hive.box<SymptomEntry>(AppConstants.symptomsBox);
    _settingsBox = Hive.box(AppConstants.settingsBox);
    _loadData();
  }

  List<PeriodRecord> get records => List.unmodifiable(_records);
  List<SymptomEntry> get symptoms => List.unmodifiable(_symptoms);
  int get cycleLength => _cycleLength;
  int get periodDuration => _periodDuration;

  PeriodRecord? get latestRecord =>
      _records.isNotEmpty ? _records.first : null;

  DateTime? get nextPeriodDate =>
      latestRecord?.predictedNextPeriod;

  int? get daysUntilNextPeriod {
    if (nextPeriodDate == null) return null;
    return AppDateUtils.daysBetween(DateTime.now(), nextPeriodDate!);
  }

  bool get isOnPeriod {
    if (latestRecord == null) return false;
    if (latestRecord!.isOngoing) return true;
    final today = AppDateUtils.dateOnly(DateTime.now());
    final start = AppDateUtils.dateOnly(latestRecord!.startDate);
    final end = latestRecord!.endDate != null
        ? AppDateUtils.dateOnly(latestRecord!.endDate!)
        : start.add(Duration(days: _periodDuration));
    return !today.isBefore(start) && !today.isAfter(end);
  }

  /// текущий день цикла (1 = первый день менструации).
  int? get currentCycleDay {
    if (latestRecord == null) return null;
    return AppDateUtils.daysBetween(latestRecord!.startDate, DateTime.now()) + 1;
  }

  /// Средняя продолжительность цикла по историческим данным
  double get averageCycleLength {
    if (_records.length < 2) return _cycleLength.toDouble();
    int totalDays = 0;
    int count = 0;
    for (int i = 0; i < _records.length - 1; i++) {
      totalDays += AppDateUtils.daysBetween(
        _records[i + 1].startDate,
        _records[i].startDate,
      ).abs();
      count++;
    }
    return count > 0 ? totalDays / count : _cycleLength.toDouble();
  }

  void _loadData() {
    _records = _periodBox.values.toList()
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
    _symptoms = _symptomBox.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    _cycleLength = _settingsBox.get(
      AppConstants.keyCycleLength,
      defaultValue: AppConstants.defaultCycleLength,
    );
    _periodDuration = _settingsBox.get(
      AppConstants.keyPeriodDuration,
      defaultValue: AppConstants.defaultPeriodDuration,
    );
    notifyListeners();
  }

  Future<void> addPeriodRecord(DateTime startDate) async {
    final record = PeriodRecord(
      id: _uuid.v4(),
      startDate: startDate,
      cycleLength: _cycleLength,
    );
    await _periodBox.add(record);
    _loadData();
  }

  Future<void> endPeriod(String recordId, DateTime endDate) async {
    final index = _records.indexWhere((r) => r.id == recordId);
    if (index != -1) {
      _records[index].endDate = endDate;
      await _records[index].save();
      _loadData();
    }
  }

  Future<void> addSymptom({
    required DateTime date,
    required String symptom,
    required int severity,
    String? notes,
  }) async {
    final entry = SymptomEntry(
      id: _uuid.v4(),
      date: date,
      symptom: symptom,
      severity: severity,
      notes: notes,
    );
    await _symptomBox.add(entry);
    _loadData();
  }

  Future<void> updateCycleLength(int length) async {
    _cycleLength = length;
    await _settingsBox.put(AppConstants.keyCycleLength, length);
    notifyListeners();
  }

  Future<void> updatePeriodDuration(int duration) async {
    _periodDuration = duration;
    await _settingsBox.put(AppConstants.keyPeriodDuration, duration);
    notifyListeners();
  }

  Future<void> deleteRecord(String id) async {
    final index = _records.indexWhere((r) => r.id == id);
    if (index != -1) {
      await _records[index].delete();
      _loadData();
    }
  }

  /// Получить симптомы на конкретную дату
  List<SymptomEntry> getSymptomsForDate(DateTime date) {
    return _symptoms.where((s) => AppDateUtils.isSameDay(s.date, date)).toList();
  }

  /// Проверяет, совпадает ли дата с днем менструации.
  bool isPeriodDay(DateTime date) {
    for (final record in _records) {
      final start = AppDateUtils.dateOnly(record.startDate);
      final end = record.endDate != null
          ? AppDateUtils.dateOnly(record.endDate!)
          : start.add(Duration(days: _periodDuration - 1));
      final checkDate = AppDateUtils.dateOnly(date);
      if (!checkDate.isBefore(start) && !checkDate.isAfter(end)) {
        return true;
      }
    }
    return false;
  }

  /// Проверяет, является ли дата прогнозируемым днем менструального цикла.
  bool isPredictedPeriodDay(DateTime date) {
    if (latestRecord == null) return false;
    final nextStart = latestRecord!.predictedNextPeriod;
    final nextEnd = nextStart.add(Duration(days: _periodDuration - 1));
    final checkDate = AppDateUtils.dateOnly(date);
    return !checkDate.isBefore(AppDateUtils.dateOnly(nextStart)) &&
        !checkDate.isAfter(AppDateUtils.dateOnly(nextEnd));
  }
}
