// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

part of 'auth_models.dart';

Map<String, dynamic> _$LoginRequestToJson(LoginRequest instance) => <String, dynamic>{
      'username': instance.username,
      'password': instance.password,
      'tenantId': instance.tenantId,
      'userType': instance.userType,
      'scope': instance.scope,
      'grant_type': instance.grantType,
    };

LoginResponse _$LoginResponseFromJson(Map<String, dynamic> json) => LoginResponse(
      accessToken: json['access_token'] as String,
      tokenType: json['token_type'] as String,
      refreshToken: json['refresh_token'] as String,
      expiresIn: json['expires_in'] as int,
      userRequest: UserInfoModel.fromJson(json['UserRequest'] as Map<String, dynamic>),
    );

UserInfoModel _$UserInfoModelFromJson(Map<String, dynamic> json) => UserInfoModel(
      id: json['id'] as int,
      userName: json['userName'] as String,
      name: json['name'] as String,
      mobileNumber: json['mobileNumber'] as String? ?? '',
      emailId: json['emailId'] as String? ?? '',
      tenantId: json['tenantId'] as String,
      roles: (json['roles'] as List<dynamic>?)?.map((e) => RoleModel.fromJson(e as Map<String, dynamic>)).toList() ?? [],
    );

Map<String, dynamic> _$UserInfoModelToJson(UserInfoModel instance) => <String, dynamic>{
      'id': instance.id,
      'userName': instance.userName,
      'name': instance.name,
      'mobileNumber': instance.mobileNumber,
      'emailId': instance.emailId,
      'tenantId': instance.tenantId,
      'roles': instance.roles.map((e) => e.toJson()).toList(),
    };

RoleModel _$RoleModelFromJson(Map<String, dynamic> json) => RoleModel(
      code: json['code'] as String,
      name: json['name'] as String,
      tenantId: json['tenantId'] as String? ?? 'dev',
    );

Map<String, dynamic> _$RoleModelToJson(RoleModel instance) => <String, dynamic>{
      'code': instance.code,
      'name': instance.name,
      'tenantId': instance.tenantId,
    };
