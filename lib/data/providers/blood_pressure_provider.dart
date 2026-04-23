import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/date_utils.dart';
import '../models/blood_pressure_model.dart';

class BloodPressureProvider extends ChangeNotifier {
  late Box<BloodPressureRecord> _bpBox;
  final _uuid = const Uuid();

  List<BloodPressureRecord> _records = [];

  BloodPressureProvider() {
    _bpBox = Hive.box<BloodPressureRecord>(AppConstants.bloodPressureBox);
    _loadData();
  }

  List<BloodPressureRecord> get records => List.unmodifiable(_records);

  BloodPressureRecord? get latest => _records.isNotEmpty ? _records.first : null;

  void _loadData() {
    _records = _bpBox.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  Future<void> addRecord({
    required int systolic,
    required int diastolic,
    required int pulse,
    String? notes,
  }) async {
    final now = DateTime.now();
    
    await _bpBox.add(BloodPressureRecord(
      id: _uuid.v4(),
      date: now,
      systolic: systolic,
      diastolic: diastolic,
      pulse: pulse,
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

  Map<String, List<BloodPressureRecord>> get weeklyData {
    final result = <String, List<BloodPressureRecord>>{};
    final now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final key = AppDateUtils.formatDateShort(date);
      final dayRecords = _records
          .where((r) => AppDateUtils.isSameDay(r.date, date))
          .toList();
      result[key] = dayRecords;
    }
    return result;
  }
}
