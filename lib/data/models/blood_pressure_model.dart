import 'package:hive/hive.dart';

part 'blood_pressure_model.g.dart';

@HiveType(typeId: 13)
class BloodPressureRecord extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final int systolic;

  @HiveField(3)
  final int diastolic;

  @HiveField(4)
  final int pulse;

  @HiveField(5)
  final String? notes;

  BloodPressureRecord({
    required this.id,
    required this.date,
    required this.systolic,
    required this.diastolic,
    required this.pulse,
    this.notes,
  });

  String get formattedValue => '$systolic/$diastolic';
}
