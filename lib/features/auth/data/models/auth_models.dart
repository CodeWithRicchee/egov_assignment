import 'package:json_annotation/json_annotation.dart';

part 'auth_models.g.dart';

@JsonSerializable()
class LoginRequest {
  final String username;
  final String password;
  final String tenantId;
  final String userType;
  final String scope;
  @JsonKey(name: 'grant_type')
  final String grantType;

  const LoginRequest({
    required this.username,
    required this.password,
    required this.tenantId,
    this.userType = 'EMPLOYEE',
    this.scope = 'read',
    this.grantType = 'password',
  });

  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
  Map<String, String> toFormData() => {
        'username': username,
        'password': password,
        'tenantId': tenantId,
        'userType': userType,
        'scope': scope,
        'grant_type': grantType,
      };
}

@JsonSerializable()
class LoginResponse {
  @JsonKey(name: 'access_token')
  final String accessToken;
  @JsonKey(name: 'token_type')
  final String tokenType;
  @JsonKey(name: 'refresh_token')
  final String refreshToken;
  @JsonKey(name: 'expires_in')
  final int expiresIn;
  final UserInfoModel userRequest;

  const LoginResponse({
    required this.accessToken,
    required this.tokenType,
    required this.refreshToken,
    required this.expiresIn,
    required this.userRequest,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => _$LoginResponseFromJson(json);
}

@JsonSerializable()
class UserInfoModel {
  final int id;
  final String userName;
  final String name;
  final String mobileNumber;
  final String emailId;
  final String tenantId;
  final List<RoleModel> roles;

  const UserInfoModel({
    required this.id,
    required this.userName,
    required this.name,
    required this.mobileNumber,
    required this.emailId,
    required this.tenantId,
    required this.roles,
  });

  factory UserInfoModel.fromJson(Map<String, dynamic> json) => _$UserInfoModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserInfoModelToJson(this);
}

@JsonSerializable()
class RoleModel {
  final String code;
  final String name;
  final String tenantId;

  const RoleModel({
    required this.code,
    required this.name,
    required this.tenantId,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) => _$RoleModelFromJson(json);
  Map<String, dynamic> toJson() => _$RoleModelToJson(this);
}
