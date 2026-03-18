import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../../core/utils/local_storage_service.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/auth_models.dart';

@Injectable(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final LocalStorageService _localStorage;
  final ConnectivityService _connectivity;
  UserEntity? _currentUser;

  AuthRepositoryImpl(this._remoteDataSource, this._localStorage, this._connectivity);

  @override
  UserEntity? get currentUser => _currentUser;

  @override
  Future<Either<Failure, UserEntity>> login({
    required String username,
    required String password,
    String? tenantId,
    String? userType,
    String? scope,
    String? grantType,
  }) async {
    if (!_connectivity.isOnline) {
      return const Left(NetworkFailure('No internet connection. Please connect to login.'));
    }
    try {
      final response = await _remoteDataSource.login(
        username: username,
        password: password,
        tenantId: tenantId,
        userType: userType,
        scope: scope,
        grantType: grantType,
      );
      final entity = _mapToEntity(response);
      _currentUser = entity;
      await _localStorage.saveAuthToken(response.accessToken);
      await _localStorage.saveUserInfo(response.userRequest.toJson());
      return Right(entity);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _localStorage.clearAuth();
      _currentUser = null;
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  UserEntity _mapToEntity(LoginResponse response) {
    return UserEntity(
      id: response.userRequest.id,
      userName: response.userRequest.userName,
      name: response.userRequest.name,
      mobileNumber: response.userRequest.mobileNumber,
      emailId: response.userRequest.emailId,
      tenantId: response.userRequest.tenantId,
      authToken: response.accessToken,
      roles: response.userRequest.roles.map((r) => RoleEntity(code: r.code, name: r.name, tenantId: r.tenantId)).toList(),
    );
  }
}
