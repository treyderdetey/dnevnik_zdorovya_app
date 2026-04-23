import 'package:hive/hive.dart';

part 'sleep_model.g.dart';

@HiveType(typeId: 7)
class SleepRecord extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final DateTime bedTime;

  @HiveField(3)
  final DateTime wakeTime;

  @HiveField(4)
  final int quality; // 1-5

  @HiveField(5)
  final String? notes;

  SleepRecord({
    required this.id,
    required this.date,
    required this.bedTime,
    required this.wakeTime,
    required this.quality,
    this.notes,
  });

  Duration get duration => wakeTime.difference(bedTime);

  double get durationHours => duration.inMinutes / 60.0;

  String get durationFormatted {
    final h = duration.inHours;
    final m = duration.inMinutes % 60;
    return '${h}ч ${m}м';
  }

  String get qualityLabel {
    switch (quality) {
      case 1: return 'Ужасно';
      case 2: return 'Плохо';
      case 3: return 'Удовлетворительно';
      case 4: return 'Хорошо';
      case 5: return 'Отлично';
      default: return 'Неизвестно';
    }
  }
}
