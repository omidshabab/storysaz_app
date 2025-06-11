// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'story_element.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StoryElementAdapter extends TypeAdapter<StoryElement> {
  @override
  final int typeId = 0;

  @override
  StoryElement read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StoryElement(
      id: fields[0] as String,
      x: fields[1] as double,
      y: fields[2] as double,
      rotation: fields[3] as double,
      scale: fields[4] as double,
    );
  }

  @override
  void write(BinaryWriter writer, StoryElement obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.x)
      ..writeByte(2)
      ..write(obj.y)
      ..writeByte(3)
      ..write(obj.rotation)
      ..writeByte(4)
      ..write(obj.scale);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StoryElementAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TextElementAdapter extends TypeAdapter<TextElement> {
  @override
  final int typeId = 1;

  @override
  TextElement read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TextElement(
      id: fields[0] as String,
      x: fields[1] as double,
      y: fields[2] as double,
      text: fields[5] as String,
      fontSize: fields[6] as double,
      rotation: fields[3] as double,
      scale: fields[4] as double,
      hasBackground: fields[8] as bool,
      index: fields[9] as int,
    )..colorValue = fields[7] as int;
  }

  @override
  void write(BinaryWriter writer, TextElement obj) {
    writer
      ..writeByte(10)
      ..writeByte(5)
      ..write(obj.text)
      ..writeByte(6)
      ..write(obj.fontSize)
      ..writeByte(7)
      ..write(obj.colorValue)
      ..writeByte(8)
      ..write(obj.hasBackground)
      ..writeByte(9)
      ..write(obj.index)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.x)
      ..writeByte(2)
      ..write(obj.y)
      ..writeByte(3)
      ..write(obj.rotation)
      ..writeByte(4)
      ..write(obj.scale);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextElementAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
