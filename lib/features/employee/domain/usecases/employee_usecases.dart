import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/employee_entities.dart';
import '../repositories/employee_repository.dart';

@injectable
class GetMdmsOptionsUseCase {
  final EmployeeRepository _repo;
  GetMdmsOptionsUseCase(this._repo);
  Future<Either<Failure, List<DropdownOption>>> call(String schemaCode) => _repo.getMdmsOptions(schemaCode);
}

@injectable
class GetBoundaryHierarchyUseCase {
  final EmployeeRepository _repo;
  GetBoundaryHierarchyUseCase(this._repo);
  Future<Either<Failure, BoundaryNode?>> call() => _repo.getBoundaryHierarchy();
}

@injectable
class CheckUsernameExistsUseCase {
  final EmployeeRepository _repo;
  CheckUsernameExistsUseCase(this._repo);
  Future<Either<Failure, bool>> call(String username) => _repo.checkUsernameExists(username);
}

@injectable
class CheckMobileExistsUseCase {
  final EmployeeRepository _repo;
  CheckMobileExistsUseCase(this._repo);
  Future<Either<Failure, bool>> call(String mobile) => _repo.checkMobileExists(mobile);
}

@injectable
class CreateEmployeeUseCase {
  final EmployeeRepository _repo;
  CreateEmployeeUseCase(this._repo);
  Future<Either<Failure, void>> call(EmployeeFormData formData) => _repo.createEmployee(formData);
}

@injectable
class SyncPendingEmployeesUseCase {
  final EmployeeRepository _repo;
  SyncPendingEmployeesUseCase(this._repo);
  Future<Either<Failure, int>> call() => _repo.syncPendingEmployees();
}
