// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'streak_model.dart';

class StreakModelAdapter extends TypeAdapter<StreakModel> {
  @override
  final int typeId = 6;

  @override
  StreakModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StreakModel(
      id: fields[0] as String,
      type: fields[1] as String,
      currentStreak: fields[2] as int,
      longestStreak: fields[3] as int,
      lastCompletedDate: fields[4] as DateTime,
      streakStartDate: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, StreakModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.currentStreak)
      ..writeByte(3)
      ..write(obj.longestStreak)
      ..writeByte(4)
      ..write(obj.lastCompletedDate)
      ..writeByte(5)
      ..write(obj.streakStartDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StreakModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
