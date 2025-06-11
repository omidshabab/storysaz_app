// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_element.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MediaElementAdapter extends TypeAdapter<MediaElement> {
  @override
  final int typeId = 3;

  @override
  MediaElement read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MediaElement(
      id: fields[0] as String,
      path: fields[1] as String,
      x: fields[2] as double,
      y: fields[3] as double,
      width: fields[4] as double,
      height: fields[5] as double,
      isVideo: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, MediaElement obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.path)
      ..writeByte(2)
      ..write(obj.x)
      ..writeByte(3)
      ..write(obj.y)
      ..writeByte(4)
      ..write(obj.width)
      ..writeByte(5)
      ..write(obj.height)
      ..writeByte(6)
      ..write(obj.isVideo);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MediaElementAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
