// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'water_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WaterIntakeAdapter extends TypeAdapter<WaterIntake> {
  @override
  final int typeId = 4;

  @override
  WaterIntake read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WaterIntake(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      glasses: fields[2] as int,
      timestamp: fields[3] as DateTime,
      ml: fields[4] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, WaterIntake obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.glasses)
      ..writeByte(3)
      ..write(obj.timestamp)
      ..writeByte(4)
      ..write(obj.ml);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WaterIntakeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
