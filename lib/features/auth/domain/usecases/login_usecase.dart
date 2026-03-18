import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

@injectable
class LoginUseCase {
  final AuthRepository _repository;
  LoginUseCase(this._repository);

  Future<Either<Failure, UserEntity>> call({
    required String username,
    required String password,
    String? tenantId,
    String? userType,
    String? scope,
    String? grantType,
  }) =>
      _repository.login(
        username: username,
        password: password,
        tenantId: tenantId,
        userType: userType,
        scope: scope,
        grantType: grantType,
      );
}
