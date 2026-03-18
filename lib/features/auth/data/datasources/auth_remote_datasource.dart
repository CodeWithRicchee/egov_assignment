import 'dart:convert';

import 'package:injectable/injectable.dart';
import '../../../../core/env/app_env.dart';
import '../../../../core/network/network_client.dart';
import '../models/auth_models.dart';

import 'package:dio/dio.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponse> login({
    required String username,
    required String password,
    String? tenantId,
    String? userType,
    String? scope,
    String? grantType,
  });
}

// data/datasources/auth/auth_remote_datasource.dart
@Injectable(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final NetworkClient _client;

  AuthRemoteDataSourceImpl(this._client);

  @override
  Future<LoginResponse> login({
    required String username,
    required String password,
    String? tenantId,
    String? userType,
    String? scope,
    String? grantType,
  }) async {
    final resolvedTenantId = tenantId ?? AppEnv.tenantId;
    final resolvedUserType = userType ?? 'EMPLOYEE';
    final resolvedScope = scope ?? 'read';
    final resolvedGrantType = grantType ?? 'password';

    final data = {
      'username': username,
      'password': password,
      'tenantId': resolvedTenantId,
      'userType': resolvedUserType,
      'scope': resolvedScope,
      'grant_type': resolvedGrantType,
    };
    final body = data.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&');
    final basicAuth = 'Basic ${base64Encode(utf8.encode('${AppEnv.clientId}:${AppEnv.clientSecret}'))}';

    final response = await _client.post(
      'user/oauth/token',
      data: body,
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
        headers: {
          'Authorization': basicAuth,
          'Accept': 'application/json, text/plain, */*', // 👈 Add this
        },
      ),
    );

    return LoginResponse.fromJson(response.data);
  }
}
