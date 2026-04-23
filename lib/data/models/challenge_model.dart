import 'package:hive/hive.dart';

part 'challenge_model.g.dart';

@HiveType(typeId: 8)
class DailyChallenge extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final String description;

  @HiveField(4)
  final String category; // water, medicine, sleep, mood, exercise

  @HiveField(5)
  final int points;

  @HiveField(6)
  bool completed;

  @HiveField(7)
  DateTime? completedAt;

  DailyChallenge({
    required this.id,
    required this.date,
    required this.title,
    required this.description,
    required this.category,
    required this.points,
    this.completed = false,
    this.completedAt,
  });
}

@HiveType(typeId: 9)
class UserAchievement extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String icon;

  @HiveField(4)
  final DateTime earnedAt;

  @HiveField(5)
  final int pointsRequired;

  UserAchievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.earnedAt,
    required this.pointsRequired,
  });
}
