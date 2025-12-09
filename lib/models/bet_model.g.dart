// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bet_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BetAdapter extends TypeAdapter<Bet> {
  @override
  final int typeId = 1;

  @override
  Bet read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Bet(
      id: fields[0] as String,
      matchTitle: fields[1] as String,
      date: fields[2] as DateTime,
      stake: fields[3] as double,
      odd: fields[4] as double,
      result: fields[5] as BetResult,
      notes: fields[6] as String,
      pandaMatchId: fields[7] as int?,
      pickedTeamId: fields[8] as int?,
      gameNumber: fields[9] as int?,
      side: fields[10] as LoLSide?,
      myTeamDraft: (fields[11] as List?)?.cast<String>(),
      enemyTeamDraft: (fields[17] as List?)?.cast<String>(),
      towers: fields[12] as int?,
      dragons: fields[13] as int?,
      totalMatchKills: fields[14] as int?,
      baronNashors: fields[15] as int?,
      matchDuration: fields[16] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, Bet obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.matchTitle)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.stake)
      ..writeByte(4)
      ..write(obj.odd)
      ..writeByte(5)
      ..write(obj.result)
      ..writeByte(6)
      ..write(obj.notes)
      ..writeByte(7)
      ..write(obj.pandaMatchId)
      ..writeByte(8)
      ..write(obj.pickedTeamId)
      ..writeByte(9)
      ..write(obj.gameNumber)
      ..writeByte(10)
      ..write(obj.side)
      ..writeByte(11)
      ..write(obj.myTeamDraft)
      ..writeByte(17)
      ..write(obj.enemyTeamDraft)
      ..writeByte(12)
      ..write(obj.towers)
      ..writeByte(13)
      ..write(obj.dragons)
      ..writeByte(14)
      ..write(obj.totalMatchKills)
      ..writeByte(15)
      ..write(obj.baronNashors)
      ..writeByte(16)
      ..write(obj.matchDuration);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BetResultAdapter extends TypeAdapter<BetResult> {
  @override
  final int typeId = 2;

  @override
  BetResult read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BetResult.pending;
      case 1:
        return BetResult.win;
      case 2:
        return BetResult.loss;
      case 3:
        return BetResult.voided;
      default:
        return BetResult.pending;
    }
  }

  @override
  void write(BinaryWriter writer, BetResult obj) {
    switch (obj) {
      case BetResult.pending:
        writer.writeByte(0);
        break;
      case BetResult.win:
        writer.writeByte(1);
        break;
      case BetResult.loss:
        writer.writeByte(2);
        break;
      case BetResult.voided:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BetResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LoLSideAdapter extends TypeAdapter<LoLSide> {
  @override
  final int typeId = 4;

  @override
  LoLSide read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return LoLSide.blue;
      case 1:
        return LoLSide.red;
      default:
        return LoLSide.blue;
    }
  }

  @override
  void write(BinaryWriter writer, LoLSide obj) {
    switch (obj) {
      case LoLSide.blue:
        writer.writeByte(0);
        break;
      case LoLSide.red:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoLSideAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
