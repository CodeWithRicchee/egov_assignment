import 'package:injectable/injectable.dart';
import '../../../../core/env/app_env.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/network_client.dart';
import '../../../../core/utils/local_storage_service.dart';
import '../../domain/entities/employee_entities.dart';

abstract class EmployeeRemoteDataSource {
  Future<List<DropdownOption>> fetchMdmsOptions(String schemaCode);
  Future<BoundaryNode?> fetchBoundaryHierarchy();
  Future<bool> checkUsernameExists(String username);
  Future<bool> checkMobileExists(String mobile);
  Future<void> createEmployee(Map<String, dynamic> payload);
}

@Injectable(as: EmployeeRemoteDataSource)
class EmployeeRemoteDataSourceImpl implements EmployeeRemoteDataSource {
  final NetworkClient _client;
  final LocalStorageService _storage;

  EmployeeRemoteDataSourceImpl(this._client, this._storage);

  Map<String, dynamic> get _requestInfo {
    final userInfo = _storage.getUserInfo();
    final epochMillis = DateTime.now().millisecondsSinceEpoch;
    return {
      'apiId': 'Rainmaker',
      'ver': '1.0',
      'ts': epochMillis,
      'action': '_search',
      'did': '',
      'key': '',
      'msgId': '$epochMillis|en_IN',
      'authToken': _storage.getAuthToken() ?? '',
      'userInfo': userInfo ?? {},
      'plainAccessRequest': {},
    };
  }

  @override
  Future<List<DropdownOption>> fetchMdmsOptions(String schemaCode) async {
    final response = await _client.post(
      AppEnv.mdmsApiPath,
      data: {
        'MdmsCriteria': {
          'tenantId': AppEnv.tenantId,
          'schemaCode': schemaCode,
          'filters': {},
          'limit': 10000,
          'isActive': true,
        },
        'RequestInfo': _requestInfo,
      },
    );

    final data = response.data as Map<String, dynamic>;
    final mdmsRes = data['mdms'];
    if (mdmsRes is! List || mdmsRes.isEmpty) return [];

    final rawItems = <Map<String, dynamic>>[];
    for (final rawEntry in mdmsRes) {
      if (rawEntry is! Map<String, dynamic>) continue;

      final entryData = rawEntry['data'];
      if (entryData is List) {
        for (final entry in entryData) {
          if (entry is Map<String, dynamic>) rawItems.add(entry);
        }
      } else if (entryData is Map<String, dynamic>) {
        final row = <String, dynamic>{...entryData};
        row['code'] = row['code'] ?? rawEntry['uniqueIdentifier'] ?? rawEntry['code'];
        row['name'] = row['name'] ?? row['code'] ?? rawEntry['uniqueIdentifier'] ?? rawEntry['name'];
        row['isActive'] = row['isActive'] ?? rawEntry['isActive'];
        rawItems.add(row);
      } else {
        // Fallback: if mdms item itself is a row
        rawItems.add(rawEntry);
      }
    }

    return rawItems
        .where((item) => item['isActive'] != false)
        .map((item) {
          final code = item['code']?.toString() ?? item['uniqueIdentifier']?.toString() ?? '';
          final name =
              item['name']?.toString() ?? item['description']?.toString() ?? item['code']?.toString() ?? item['uniqueIdentifier']?.toString() ?? '';
          return DropdownOption(
            code: code,
            name: name,
            isActive: item['isActive'] != false,
            extra: item,
          );
        })
        .where((o) => o.code.isNotEmpty)
        .toList();
  }

  @override
  Future<BoundaryNode?> fetchBoundaryHierarchy() async {
    final response = await _client.post(
      AppEnv.boundarySearchPath,
      queryParams: {
        'tenantId': AppEnv.tenantId,
        'hierarchyType': AppEnv.hierarchyType,
        'includeChildren': 'true',
      },
      data: {
        'RequestInfo': _requestInfo,
      },
    );

    final data = response.data as Map<String, dynamic>;
    final relationships = data['TenantBoundary'] as List? ?? [];
    if (relationships.isEmpty) return null;

    final first = relationships.first as Map<String, dynamic>?;
    if (first == null) return null;

    final boundaryList = first['boundary'] as List?;
    if (boundaryList == null || boundaryList.isEmpty) return null;

    final root = boundaryList.first as Map<String, dynamic>?;
    if (root == null) return null;

    return _parseBoundaryNode(root);
  }

  BoundaryNode _parseBoundaryNode(Map<String, dynamic> json) {
    final children = (json['children'] as List? ?? []).whereType<Map<String, dynamic>>().map(_parseBoundaryNode).toList();
    return BoundaryNode(
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? json['code']?.toString() ?? '',
      boundaryType: json['boundaryType']?.toString() ?? '',
      children: children,
    );
  }

  @override
  Future<bool> checkUsernameExists(String username) async {
    final response = await _client.post(
      AppEnv.employeeSearchPath,
      queryParams: {'tenantId': AppEnv.tenantId, 'codes': username},
      data: {'RequestInfo': _requestInfo},
    );
    final data = response.data as Map<String, dynamic>;
    final employees = data['Employees'] as List? ?? [];
    return employees.isNotEmpty;
  }

  @override
  Future<bool> checkMobileExists(String mobile) async {
    final response = await _client.post(
      AppEnv.employeeSearchPath,
      queryParams: {'tenantId': AppEnv.tenantId, 'phone': mobile},
      data: {'RequestInfo': _requestInfo},
    );
    final data = response.data as Map<String, dynamic>;
    final employees = data['Employees'] as List? ?? [];
    return employees.isNotEmpty;
  }

  @override
  Future<void> createEmployee(Map<String, dynamic> payload) async {
    final response = await _client.post(
      '${AppEnv.employeeCreatePath}?tenantId=${AppEnv.tenantId}',
      data: payload,
    );
    final data = response.data as Map<String, dynamic>;
    final employees = data['Employees'] as List? ?? [];
    if (employees.isEmpty) {
      throw ServerException(message: 'Employee creation failed. No response received.');
    }
  }
}
