import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/env/app_env.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../../core/utils/local_storage_service.dart';
import '../../domain/entities/employee_entities.dart';
import '../../domain/repositories/employee_repository.dart';
import '../datasources/employee_remote_datasource.dart';
import '../models/offline_employee_model.dart';

@Injectable(as: EmployeeRepository)
class EmployeeRepositoryImpl implements EmployeeRepository {
  final EmployeeRemoteDataSource _remote;
  final LocalStorageService _storage;
  final ConnectivityService _connectivity;

  EmployeeRepositoryImpl(this._remote, this._storage, this._connectivity);

  @override
  Future<Either<Failure, List<DropdownOption>>> getMdmsOptions(String schemaCode) async {
    if (!_connectivity.isOnline) {
      final cached = _storage.getMdmsOptions(schemaCode);
      if (cached != null) {
        return Right(cached.map((item) => DropdownOption(code: item['code']?.toString() ?? '', name: item['name']?.toString() ?? '')).toList());
      }
      return Left(NetworkFailure('No internet connection. MDMS data unavailable offline.'));
    }

    try {
      final options = await _remote.fetchMdmsOptions(schemaCode);
      await _storage.saveMdmsOptions(schemaCode, options.map((o) => {'code': o.code, 'name': o.name, 'isActive': o.isActive}).toList());
      return Right(options);
    } on NetworkException catch (e) {
      final cached = _storage.getMdmsOptions(schemaCode);
      if (cached != null) {
        return Right(cached.map((item) => DropdownOption(code: item['code']?.toString() ?? '', name: item['name']?.toString() ?? '')).toList());
      }
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  BoundaryNode _boundaryNodeFromJson(Map<String, dynamic> json) {
    final children = (json['children'] as List? ?? []).whereType<Map<String, dynamic>>().map(_boundaryNodeFromJson).toList();
    return BoundaryNode(
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? json['code']?.toString() ?? '',
      boundaryType: json['boundaryType']?.toString() ?? '',
      children: children,
    );
  }

  Map<String, dynamic> _boundaryNodeToJson(BoundaryNode node) {
    return {
      'code': node.code,
      'name': node.name,
      'boundaryType': node.boundaryType,
      'children': node.children.map(_boundaryNodeToJson).toList(),
    };
  }

  @override
  Future<Either<Failure, BoundaryNode?>> getBoundaryHierarchy() async {
    if (!_connectivity.isOnline) {
      final cached = _storage.getBoundaryRoot();
      if (cached != null) {
        return Right(_boundaryNodeFromJson(cached));
      }
      return Left(NetworkFailure('No internet connection. Boundary data unavailable offline.'));
    }

    try {
      final node = await _remote.fetchBoundaryHierarchy();
      if (node != null) {
        await _storage.saveBoundaryRoot(_boundaryNodeToJson(node));
      }
      return Right(node);
    } on NetworkException catch (e) {
      final cached = _storage.getBoundaryRoot();
      if (cached != null) {
        return Right(_boundaryNodeFromJson(cached));
      }
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> checkUsernameExists(String username) async {
    try {
      final exists = await _remote.checkUsernameExists(username);
      return Right(exists);
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> checkMobileExists(String mobile) async {
    try {
      final exists = await _remote.checkMobileExists(mobile);
      return Right(exists);
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createEmployee(EmployeeFormData data) async {
    final payload = _buildPayload(data);

    if (!_connectivity.isOnline) {
      await _storage.savePendingEmployee(OfflineEmployeeModel.fromPayload(payload));
      return const Left(NetworkFailure('__offline__'));
    }

    try {
      await _remote.createEmployee(payload);
      return const Right(null);
    } on NetworkException catch (_) {
      await _storage.savePendingEmployee(OfflineEmployeeModel.fromPayload(payload));
      return const Left(NetworkFailure('__offline__'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> syncPendingEmployees() async {
    if (!_connectivity.isOnline) {
      return const Left(NetworkFailure('No internet connection'));
    }

    final pending = _storage.getPendingEmployees();
    if (pending.isEmpty) return const Right(0);

    final failures = <String>[];
    int syncedCount = 0;
    for (int i = pending.length - 1; i >= 0; i--) {
      final item = pending[i];
      if (item.retryCount >= AppEnv.syncRetryCount) {
        await _storage.deletePendingEmployee(i);
        continue;
      }

      try {
        await _remote.createEmployee(item.payload);
        await _storage.deletePendingEmployee(i);
        syncedCount++;
      } catch (e) {
        item.retryCount++;
        await item.save();
        if (item.retryCount >= AppEnv.syncRetryCount) {
          failures.add('Failed after ${AppEnv.syncRetryCount} retries');
          await _storage.deletePendingEmployee(i);
        }
      }
    }

    if (failures.isNotEmpty) {
      return Left(ServerFailure('${failures.length} record(s) failed to sync'));
    }
    return Right(syncedCount);
  }

  Map<String, dynamic> _buildPayload(EmployeeFormData data) {
    final userInfo = _storage.getUserInfo() ?? {};
    final dobEpoch = data.dateOfBirth?.millisecondsSinceEpoch;
    final apptEpoch = data.dateOfAppointment?.millisecondsSinceEpoch;
    final boundary = data.deepestBoundary;

    final rolesList = data.selectedRoles
        .map((r) => {
              'code': r.code,
              'name': r.name,
              'tenantId': AppEnv.tenantId,
            })
        .toList();

    return {
      'Employees': [
        {
          'tenantId': AppEnv.tenantId,
          'employeeStatus': 'EMPLOYED',
          'code': data.username,
          'dateOfAppointment': apptEpoch,
          'employeeType': data.employmentType,
          'assignments': [
            {
              'fromDate': apptEpoch,
              'isCurrentAssignment': true,
              'department': data.department,
              'designation': data.designation,
              'tenantId': AppEnv.tenantId,
            }
          ],
          'jurisdictions': [
            if (boundary != null)
              {
                'hierarchy': AppEnv.hierarchyType,
                'boundaryType': boundary.boundaryType,
                'boundary': boundary.code,
                'tenantId': AppEnv.tenantId,
                'roles': rolesList,
              }
          ],
          'user': {
            'mobileNumber': data.mobileNumber,
            'name': data.name,
            'correspondenceAddress': data.correspondenceAddress,
            'emailId': data.email,
            'gender': data.gender,
            'dob': dobEpoch,
            'roles': rolesList,
            'tenantId': AppEnv.tenantId,
            'userName': data.username,
            'password': data.password,
            'type': 'EMPLOYEE',
          },
          'serviceHistory': [],
          'education': [],
          'tests': [],
        }
      ],
      'key': 'CREATE',
      'action': 'CREATE',
      'RequestInfo': {
        'apiId': 'Rainmaker',
        'authToken': _storage.getAuthToken() ?? '',
        'userInfo': userInfo,
        'msgId': '${DateTime.now().millisecondsSinceEpoch}|en_IN',
        'plainAccessRequest': {},
      },
    };
  }
}
