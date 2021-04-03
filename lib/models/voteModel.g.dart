// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voteModel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VoteModelAdapter extends TypeAdapter<VoteModel> {
  @override
  final int typeId = 1;

  @override
  VoteModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VoteModel(
      TagID: fields[0] as String,
      Id_kandidat: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, VoteModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.TagID)
      ..writeByte(1)
      ..write(obj.Id_kandidat);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VoteModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
