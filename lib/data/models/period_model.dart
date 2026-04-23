import 'package:hive/hive.dart';

part 'period_model.g.dart';

@HiveType(typeId: 0)
class PeriodRecord extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime startDate;

  @HiveField(2)
  DateTime? endDate;

  @HiveField(3)
  final int cycleLength;

  PeriodRecord({
    required this.id,
    required this.startDate,
    this.endDate,
    this.cycleLength = 28,
  });

  DateTime get predictedNextPeriod =>
      startDate.add(Duration(days: cycleLength));

  int get periodDuration =>
      endDate != null ? endDate!.difference(startDate).inDays + 1 : 0;

  bool get isOngoing => endDate == null;
}

@HiveType(typeId: 1)
class SymptomEntry extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final String symptom; // pain, mood, cramps, bloating, headache

  @HiveField(3)
  final int severity; // 1-5

  @HiveField(4)
  final String? notes;

  SymptomEntry({
    required this.id,
    required this.date,
    required this.symptom,
    required this.severity,
    this.notes,
  });
}
