import 'package:hive/hive.dart';

part 'medicine_model.g.dart';

@HiveType(typeId: 2)
class MedicineModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? dosage;

  @HiveField(3)
  final List<String> times; // ["08:00", "20:00"]

  @HiveField(4)
  final String? notes;

  @HiveField(5)
  final bool isActive;

  @HiveField(6)
  final DateTime createdAt;

  MedicineModel({
    required this.id,
    required this.name,
    this.dosage,
    required this.times,
    this.notes,
    this.isActive = true,
    required this.createdAt,
  });

  MedicineModel copyWith({
    String? name,
    String? dosage,
    List<String>? times,
    String? notes,
    bool? isActive,
  }) {
    return MedicineModel(
      id: id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      times: times ?? this.times,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
    );
  }
}

@HiveType(typeId: 3)
class MedicineDose extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String medicineId;

  @HiveField(2)
  final DateTime scheduledTime;

  @HiveField(3)
  final bool taken;

  @HiveField(4)
  final DateTime? takenAt;

  MedicineDose({
    required this.id,
    required this.medicineId,
    required this.scheduledTime,
    this.taken = false,
    this.takenAt,
  });
}
