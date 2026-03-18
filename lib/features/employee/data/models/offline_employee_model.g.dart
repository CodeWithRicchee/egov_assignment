// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

part of 'offline_employee_model.dart';

class OfflineEmployeeModelAdapter extends TypeAdapter<OfflineEmployeeModel> {
  @override
  final int typeId = 0;

  @override
  OfflineEmployeeModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OfflineEmployeeModel(
      payloadJson: fields[0] as String,
      savedAt: fields[1] as DateTime,
      retryCount: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, OfflineEmployeeModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.payloadJson)
      ..writeByte(1)
      ..write(obj.savedAt)
      ..writeByte(2)
      ..write(obj.retryCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OfflineEmployeeModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
