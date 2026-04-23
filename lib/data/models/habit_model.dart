import 'package:hive/hive.dart';

part 'habit_model.g.dart';

@HiveType(typeId: 11)
class HabitModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String icon; // emoji

  @HiveField(3)
  final String color; // hex color string

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final bool isActive;

  HabitModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.createdAt,
    this.isActive = true,
  });
}

@HiveType(typeId: 12)
class HabitCompletion extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String habitId;

  @HiveField(2)
  final DateTime date;

  HabitCompletion({
    required this.id,
    required this.habitId,
    required this.date,
  });
}
