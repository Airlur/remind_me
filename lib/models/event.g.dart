// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EventAdapter extends TypeAdapter<Event> {
  @override
  final int typeId = 0;

  @override
  Event read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Event(
      id: fields[0] as String,
      title: fields[1] as String,
      targetDate: fields[2] as DateTime,
      createdAt: fields[3] as DateTime,
      displayUnit: fields[4] as TimeUnit,
      isPinned: fields[5] as bool,
      pinnedAt: fields[11] as DateTime?,
      backgroundType: fields[6] as BackgroundType,
      backgroundColorValue: fields[7] as int?,
      gradientColorValues: (fields[8] as List?)?.cast<int>(),
      localImagePath: fields[9] as String?,
      animationType: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Event obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.targetDate)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.displayUnit)
      ..writeByte(5)
      ..write(obj.isPinned)
      ..writeByte(6)
      ..write(obj.backgroundType)
      ..writeByte(7)
      ..write(obj.backgroundColorValue)
      ..writeByte(8)
      ..write(obj.gradientColorValues)
      ..writeByte(9)
      ..write(obj.localImagePath)
      ..writeByte(10)
      ..write(obj.animationType)
      ..writeByte(11)
      ..write(obj.pinnedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TimeUnitAdapter extends TypeAdapter<TimeUnit> {
  @override
  final int typeId = 1;

  @override
  TimeUnit read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TimeUnit.day;
      case 1:
        return TimeUnit.year;
      case 2:
        return TimeUnit.month;
      case 3:
        return TimeUnit.week;
      default:
        return TimeUnit.day;
    }
  }

  @override
  void write(BinaryWriter writer, TimeUnit obj) {
    switch (obj) {
      case TimeUnit.day:
        writer.writeByte(0);
        break;
      case TimeUnit.year:
        writer.writeByte(1);
        break;
      case TimeUnit.month:
        writer.writeByte(2);
        break;
      case TimeUnit.week:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimeUnitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BackgroundTypeAdapter extends TypeAdapter<BackgroundType> {
  @override
  final int typeId = 2;

  @override
  BackgroundType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BackgroundType.color;
      case 1:
        return BackgroundType.gradient;
      case 2:
        return BackgroundType.image;
      case 3:
        return BackgroundType.animation;
      default:
        return BackgroundType.color;
    }
  }

  @override
  void write(BinaryWriter writer, BackgroundType obj) {
    switch (obj) {
      case BackgroundType.color:
        writer.writeByte(0);
        break;
      case BackgroundType.gradient:
        writer.writeByte(1);
        break;
      case BackgroundType.image:
        writer.writeByte(2);
        break;
      case BackgroundType.animation:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BackgroundTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
