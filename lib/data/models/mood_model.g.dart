// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mood_model.dart';

class MoodEntryAdapter extends TypeAdapter<MoodEntry> {
  @override
  final int typeId = 5;

  @override
  MoodEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MoodEntry(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      emoji: fields[2] as String,
      moodLabel: fields[3] as String,
      moodScore: fields[4] as int,
      journalText: fields[5] as String?,
      tags: (fields[6] as List).cast<String>(),
      createdAt: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, MoodEntry obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.emoji)
      ..writeByte(3)
      ..write(obj.moodLabel)
      ..writeByte(4)
      ..write(obj.moodScore)
      ..writeByte(5)
      ..write(obj.journalText)
      ..writeByte(6)
      ..write(obj.tags)
      ..writeByte(7)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MoodEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
