import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login({
    required String username,
    required String password,
    String? tenantId,
    String? userType,
    String? scope,
    String? grantType,
  });
  Future<Either<Failure, void>> logout();
  UserEntity? get currentUser;
}
