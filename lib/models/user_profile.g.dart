// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserProfileAdapter extends TypeAdapter<UserProfile> {
  @override
  final int typeId = 3;

  @override
  UserProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProfile(
      name: fields[0] as String,
      initialBankroll: fields[1] as double,
      profile: fields[2] as InvestorProfile,
      stopWinPercentage: fields[3] as double?,
      stopLossPercentage: fields[4] as double?,
      currentLevel: fields[5] as int,
      currentXP: fields[6] as double,
    );
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.initialBankroll)
      ..writeByte(2)
      ..write(obj.profile)
      ..writeByte(3)
      ..write(obj.stopWinPercentage)
      ..writeByte(4)
      ..write(obj.stopLossPercentage)
      ..writeByte(5)
      ..write(obj.currentLevel)
      ..writeByte(6)
      ..write(obj.currentXP);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class InvestorProfileAdapter extends TypeAdapter<InvestorProfile> {
  @override
  final int typeId = 2;

  @override
  InvestorProfile read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return InvestorProfile.turtle;
      case 1:
        return InvestorProfile.frog;
      case 2:
        return InvestorProfile.alligator;
      default:
        return InvestorProfile.turtle;
    }
  }

  @override
  void write(BinaryWriter writer, InvestorProfile obj) {
    switch (obj) {
      case InvestorProfile.turtle:
        writer.writeByte(0);
        break;
      case InvestorProfile.frog:
        writer.writeByte(1);
        break;
      case InvestorProfile.alligator:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvestorProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
