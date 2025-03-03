// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_repeat_rule.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomRepeatRuleAdapter extends TypeAdapter<CustomRepeatRule> {
  @override
  final int typeId = 6;

  @override
  CustomRepeatRule read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomRepeatRule(
      interval: fields[0] as int,
      unit: fields[1] as RepeatUnit,
      weekdays: (fields[2] as List).cast<int>(),
      monthDays: (fields[3] as List).cast<int>(),
      endDate: fields[4] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, CustomRepeatRule obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.interval)
      ..writeByte(1)
      ..write(obj.unit)
      ..writeByte(2)
      ..write(obj.weekdays)
      ..writeByte(3)
      ..write(obj.monthDays)
      ..writeByte(4)
      ..write(obj.endDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomRepeatRuleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RepeatUnitAdapter extends TypeAdapter<RepeatUnit> {
  @override
  final int typeId = 5;

  @override
  RepeatUnit read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RepeatUnit.day;
      case 1:
        return RepeatUnit.week;
      case 2:
        return RepeatUnit.month;
      case 3:
        return RepeatUnit.year;
      default:
        return RepeatUnit.day;
    }
  }

  @override
  void write(BinaryWriter writer, RepeatUnit obj) {
    switch (obj) {
      case RepeatUnit.day:
        writer.writeByte(0);
        break;
      case RepeatUnit.week:
        writer.writeByte(1);
        break;
      case RepeatUnit.month:
        writer.writeByte(2);
        break;
      case RepeatUnit.year:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RepeatUnitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
