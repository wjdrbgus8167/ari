// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'track.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TrackAdapter extends TypeAdapter<Track> {
  @override
  final int typeId = 0;

  @override
  Track read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Track(
      id: fields[0] as int,
      trackTitle: fields[1] as String,
      artist: fields[2] as String,
      composer: fields[3] as String,
      lyricist: fields[4] as String,
      albumId: fields[5] as String,
      trackFileUrl: fields[6] as String,
      lyrics: fields[7] as String,
      coverUrl: fields[9] as String?,
      trackLikeCount: fields[8] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Track obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.trackTitle)
      ..writeByte(2)
      ..write(obj.artist)
      ..writeByte(3)
      ..write(obj.composer)
      ..writeByte(4)
      ..write(obj.lyricist)
      ..writeByte(5)
      ..write(obj.albumId)
      ..writeByte(6)
      ..write(obj.trackFileUrl)
      ..writeByte(7)
      ..write(obj.lyrics)
      ..writeByte(8)
      ..write(obj.trackLikeCount)
      ..writeByte(9)
      ..write(obj.coverUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrackAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
