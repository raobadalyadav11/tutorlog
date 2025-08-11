// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tutor.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TutorAdapter extends TypeAdapter<Tutor> {
  @override
  final int typeId = 4;

  @override
  Tutor read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Tutor(
      id: fields[0] as String,
      name: fields[1] as String,
      phone: fields[2] as String,
      subscriptionStatus: fields[3] as String,
      createdAt: fields[4] as DateTime,
      subscriptionEndDate: fields[5] as DateTime?,
      isActive: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Tutor obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.phone)
      ..writeByte(3)
      ..write(obj.subscriptionStatus)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.subscriptionEndDate)
      ..writeByte(6)
      ..write(obj.isActive);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TutorAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}