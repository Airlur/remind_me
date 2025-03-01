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
      isLunar: fields[12] as bool,
      category: fields[13] as String?,
      order: fields[14] as int?,
      fontFamily: fields[15] as String?,
      iconName: fields[16] as String?,
      reminderTime: fields[17] as DateTime?,
      includeStartDay: fields[18] == null ? false : fields[18] as bool,
      repeat: fields[19] as Repeat?,
      endTime: fields[20] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Event obj) {
    writer
      ..writeByte(21)
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
      ..write(obj.pinnedAt)
      ..writeByte(12)
      ..write(obj.isLunar)
      ..writeByte(13)
      ..write(obj.category)
      ..writeByte(14)
      ..write(obj.order)
      ..writeByte(15)
      ..write(obj.fontFamily)
      ..writeByte(16)
      ..write(obj.iconName)
      ..writeByte(17)
      ..write(obj.reminderTime)
      ..writeByte(18)
      ..write(obj.includeStartDay)
      ..writeByte(19)
      ..write(obj.repeat)
      ..writeByte(20)
      ..write(obj.endTime);
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

class RepeatAdapter extends TypeAdapter<Repeat> {
  @override
  final int typeId = 3;

  @override
  Repeat read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Repeat.none;
      case 1:
        return Repeat.daily;
      case 2:
        return Repeat.weekly;
      case 3:
        return Repeat.monthly;
      case 4:
        return Repeat.yearly;
      case 5:
        return Repeat.custom;
      default:
        return Repeat.none;
    }
  }

  @override
  void write(BinaryWriter writer, Repeat obj) {
    switch (obj) {
      case Repeat.none:
        writer.writeByte(0);
        break;
      case Repeat.daily:
        writer.writeByte(1);
        break;
      case Repeat.weekly:
        writer.writeByte(2);
        break;
      case Repeat.monthly:
        writer.writeByte(3);
        break;
      case Repeat.yearly:
        writer.writeByte(4);
        break;
      case Repeat.custom:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RepeatAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
