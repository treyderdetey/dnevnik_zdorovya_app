// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sleep_model.dart';

class SleepRecordAdapter extends TypeAdapter<SleepRecord> {
  @override
  final int typeId = 7;

  @override
  SleepRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SleepRecord(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      bedTime: fields[2] as DateTime,
      wakeTime: fields[3] as DateTime,
      quality: fields[4] as int,
      notes: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SleepRecord obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.bedTime)
      ..writeByte(3)
      ..write(obj.wakeTime)
      ..writeByte(4)
      ..write(obj.quality)
      ..writeByte(5)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SleepRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
