import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/date_utils.dart';
import '../models/weight_model.dart';

class WeightProvider extends ChangeNotifier {
  late Box<WeightRecord> _weightBox;
  final _uuid = const Uuid();

  List<WeightRecord> _records = [];

  WeightProvider() {
    _weightBox = Hive.box<WeightRecord>(AppConstants.weightBox);
    _loadData();
  }

  List<WeightRecord> get records => List.unmodifiable(_records);

  WeightRecord? get latest => _records.isNotEmpty ? _records.first : null;

  double? get currentWeight => latest?.weight;

  double get weightChange {
    if (_records.length < 2) return 0;
    return _records.first.weight - _records[1].weight;
  }

  double get totalChange {
    if (_records.length < 2) return 0;
    return _records.first.weight - _records.last.weight;
  }

  /// Weekly weight data for chart
  Map<String, double> get weeklyData {
    final result = <String, double>{};
    final now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final key = AppDateUtils.formatDateShort(date);
      final record = _records
          .where((r) => AppDateUtils.isSameDay(r.date, date))
          .firstOrNull;
      if (record != null) result[key] = record.weight;
    }
    return result;
  }

  /// Monthly weight data for chart
  List<Map<String, dynamic>> get monthlyData {
    final now = DateTime.now();
    return _records
        .where((r) => r.date.month == now.month && r.date.year == now.year)
        .map((r) => {'day': r.date.day, 'weight': r.weight})
        .toList()
      ..sort((a, b) => (a['day'] as int).compareTo(b['day'] as int));
  }

  void _loadData() {
    _records = _weightBox.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  Future<void> addRecord({
    required double weight,
    double? waist,
    double? hip,
    String? notes,
  }) async {
    // Replace existing for today
    final today = AppDateUtils.dateOnly(DateTime.now());
    final existing = _weightBox.values
        .where((r) => AppDateUtils.isSameDay(r.date, today))
        .toList();
    for (final r in existing) {
      await r.delete();
    }

    await _weightBox.add(WeightRecord(
      id: _uuid.v4(),
      date: today,
      weight: weight,
      waist: waist,
      hip: hip,
      notes: notes,
    ));
    _loadData();
  }

  Future<void> deleteRecord(String id) async {
    final record = _records.where((r) => r.id == id).firstOrNull;
    if (record != null) {
      await record.delete();
      _loadData();
    }
  }
}
