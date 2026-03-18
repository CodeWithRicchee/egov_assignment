import 'dart:convert';
import 'package:hive/hive.dart';

part 'offline_employee_model.g.dart';

@HiveType(typeId: 0)
class OfflineEmployeeModel extends HiveObject {
  @HiveField(0)
  final String payloadJson;

  @HiveField(1)
  final DateTime savedAt;

  @HiveField(2)
  int retryCount;

  OfflineEmployeeModel({
    required this.payloadJson,
    required this.savedAt,
    this.retryCount = 0,
  });

  Map<String, dynamic> get payload => jsonDecode(payloadJson) as Map<String, dynamic>;

  factory OfflineEmployeeModel.fromPayload(Map<String, dynamic> payload) => OfflineEmployeeModel(
        payloadJson: jsonEncode(payload),
        savedAt: DateTime.now(),
      );
}
