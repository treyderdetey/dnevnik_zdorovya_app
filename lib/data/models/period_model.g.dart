// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'period_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PeriodRecordAdapter extends TypeAdapter<PeriodRecord> {
  @override
  final int typeId = 0;

  @override
  PeriodRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PeriodRecord(
      id: fields[0] as String,
      startDate: fields[1] as DateTime,
      endDate: fields[2] as DateTime?,
      cycleLength: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, PeriodRecord obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.startDate)
      ..writeByte(2)
      ..write(obj.endDate)
      ..writeByte(3)
      ..write(obj.cycleLength);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PeriodRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SymptomEntryAdapter extends TypeAdapter<SymptomEntry> {
  @override
  final int typeId = 1;

  @override
  SymptomEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SymptomEntry(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      symptom: fields[2] as String,
      severity: fields[3] as int,
      notes: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SymptomEntry obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.symptom)
      ..writeByte(3)
      ..write(obj.severity)
      ..writeByte(4)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SymptomEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
