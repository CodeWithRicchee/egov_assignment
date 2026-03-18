import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/employee_entities.dart';

abstract class EmployeeRepository {
  Future<Either<Failure, List<DropdownOption>>> getMdmsOptions(String schemaCode);
  Future<Either<Failure, BoundaryNode?>> getBoundaryHierarchy();
  Future<Either<Failure, bool>> checkUsernameExists(String username);
  Future<Either<Failure, bool>> checkMobileExists(String mobile);
  Future<Either<Failure, void>> createEmployee(EmployeeFormData formData);
  Future<Either<Failure, int>> syncPendingEmployees();
}
