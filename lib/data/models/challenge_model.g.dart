// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challenge_model.dart';

class DailyChallengeAdapter extends TypeAdapter<DailyChallenge> {
  @override
  final int typeId = 8;

  @override
  DailyChallenge read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyChallenge(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      title: fields[2] as String,
      description: fields[3] as String,
      category: fields[4] as String,
      points: fields[5] as int,
      completed: fields[6] as bool,
      completedAt: fields[7] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, DailyChallenge obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.category)
      ..writeByte(5)
      ..write(obj.points)
      ..writeByte(6)
      ..write(obj.completed)
      ..writeByte(7)
      ..write(obj.completedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyChallengeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserAchievementAdapter extends TypeAdapter<UserAchievement> {
  @override
  final int typeId = 9;

  @override
  UserAchievement read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserAchievement(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      icon: fields[3] as String,
      earnedAt: fields[4] as DateTime,
      pointsRequired: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, UserAchievement obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.icon)
      ..writeByte(4)
      ..write(obj.earnedAt)
      ..writeByte(5)
      ..write(obj.pointsRequired);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAchievementAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
