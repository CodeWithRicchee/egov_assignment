import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final int id;
  final String userName;
  final String name;
  final String mobileNumber;
  final String emailId;
  final String tenantId;
  final String authToken;
  final List<RoleEntity> roles;

  const UserEntity({
    required this.id,
    required this.userName,
    required this.name,
    required this.mobileNumber,
    required this.emailId,
    required this.tenantId,
    required this.authToken,
    required this.roles,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userName': userName,
        'name': name,
        'mobileNumber': mobileNumber,
        'emailId': emailId,
        'tenantId': tenantId,
        'roles': roles.map((r) => r.toJson()).toList(),
      };

  @override
  List<Object?> get props => [id, userName, tenantId];
}

class RoleEntity extends Equatable {
  final String code;
  final String name;
  final String tenantId;

  const RoleEntity({
    required this.code,
    required this.name,
    required this.tenantId,
  });

  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
        'tenantId': tenantId,
      };

  @override
  List<Object?> get props => [code, tenantId];
}
