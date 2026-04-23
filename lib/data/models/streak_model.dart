import 'package:hive/hive.dart';

part 'streak_model.g.dart';

@HiveType(typeId: 6)
class StreakModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String type; // "water" or "medicine"

  @HiveField(2)
  int currentStreak;

  @HiveField(3)
  int longestStreak;

  @HiveField(4)
  DateTime lastCompletedDate;

  @HiveField(5)
  DateTime streakStartDate;

  StreakModel({
    required this.id,
    required this.type,
    this.currentStreak = 0,
    this.longestStreak = 0,
    required this.lastCompletedDate,
    required this.streakStartDate,
  });
}
