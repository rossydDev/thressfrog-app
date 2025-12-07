// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bet_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BetAdapter extends TypeAdapter<Bet> {
  @override
  final int typeId = 0;

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
      gameNumber: fields[8] as int?,
      side: fields[9] as LoLSide?,
      pickedTeamId: fields[10] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, Bet obj) {
    writer
      ..writeByte(11)
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
      ..write(obj.gameNumber)
      ..writeByte(9)
      ..write(obj.side)
      ..writeByte(10)
      ..write(obj.pickedTeamId);
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

class BetResultAdapter extends TypeAdapter<BetResult> {
  @override
  final int typeId = 1;

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
      case 4:
        return BetResult.halfWin;
      case 5:
        return BetResult.halfLoss;
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
      case BetResult.halfWin:
        writer.writeByte(4);
        break;
      case BetResult.halfLoss:
        writer.writeByte(5);
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
