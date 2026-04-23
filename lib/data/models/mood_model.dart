import 'package:hive/hive.dart';

part 'mood_model.g.dart';

@HiveType(typeId: 5)
class MoodEntry extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final String emoji;

  @HiveField(3)
  final String moodLabel;

  @HiveField(4)
  final int moodScore; // 1-5

  @HiveField(5)
  final String? journalText;

  @HiveField(6)
  final List<String> tags;

  @HiveField(7)
  final DateTime createdAt;

  MoodEntry({
    required this.id,
    required this.date,
    required this.emoji,
    required this.moodLabel,
    required this.moodScore,
    this.journalText,
    required this.tags,
    required this.createdAt,
  });
}
