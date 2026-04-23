import 'package:hive/hive.dart';

part 'weight_model.g.dart';

@HiveType(typeId: 10)
class WeightRecord extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final double weight; // kg

  @HiveField(3)
  final double? waist; // cm

  @HiveField(4)
  final double? hip; // cm

  @HiveField(5)
  final String? notes;

  WeightRecord({
    required this.id,
    required this.date,
    required this.weight,
    this.waist,
    this.hip,
    this.notes,
  });

  double? get waistToHipRatio =>
      (waist != null && hip != null && hip! > 0) ? waist! / hip! : null;
}
