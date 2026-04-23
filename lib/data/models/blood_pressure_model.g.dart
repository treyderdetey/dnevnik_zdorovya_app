// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blood_pressure_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BloodPressureRecordAdapter extends TypeAdapter<BloodPressureRecord> {
  @override
  final int typeId = 13;

  @override
  BloodPressureRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BloodPressureRecord(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      systolic: fields[2] as int,
      diastolic: fields[3] as int,
      pulse: fields[4] as int,
      notes: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, BloodPressureRecord obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.systolic)
      ..writeByte(3)
      ..write(obj.diastolic)
      ..writeByte(4)
      ..write(obj.pulse)
      ..writeByte(5)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BloodPressureRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
