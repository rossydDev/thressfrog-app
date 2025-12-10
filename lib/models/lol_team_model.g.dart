// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lol_team_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LoLPlayerAdapter extends TypeAdapter<LoLPlayer> {
  @override
  final int typeId = 6;

  @override
  LoLPlayer read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LoLPlayer(
      id: fields[0] as int,
      nickname: fields[1] as String,
      firstName: fields[2] as String?,
      lastName: fields[3] as String?,
      role: fields[4] as String?,
      photoUrl: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, LoLPlayer obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nickname)
      ..writeByte(2)
      ..write(obj.firstName)
      ..writeByte(3)
      ..write(obj.lastName)
      ..writeByte(4)
      ..write(obj.role)
      ..writeByte(5)
      ..write(obj.photoUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoLPlayerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LoLTeamAdapter extends TypeAdapter<LoLTeam> {
  @override
  final int typeId = 7;

  @override
  LoLTeam read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LoLTeam(
      id: fields[0] as int,
      name: fields[1] as String,
      acronym: fields[2] as String,
      logoUrl: fields[3] as String,
      players: (fields[4] as List).cast<LoLPlayer>(),
      lastUpdated: fields[5] as DateTime,
      leagueName: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, LoLTeam obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.acronym)
      ..writeByte(3)
      ..write(obj.logoUrl)
      ..writeByte(4)
      ..write(obj.players)
      ..writeByte(5)
      ..write(obj.lastUpdated)
      ..writeByte(6)
      ..write(obj.leagueName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoLTeamAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
