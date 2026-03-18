import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';
import '../../features/employee/data/models/offline_employee_model.dart';

const String kPendingEmployeesBox = 'pending_employees';
const String kAuthBox = 'auth_box';
const String kAuthTokenKey = 'auth_token';
const String kUserInfoKey = 'user_info';
const String kMdmsCachePrefix = 'mdms_';
const String kBoundaryCacheKey = 'boundary_root';

@singleton
class LocalStorageService {
  late Box<OfflineEmployeeModel> _pendingEmployeesBox;
  late Box<dynamic> _authBox;

  @PostConstruct(preResolve: true)
  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(OfflineEmployeeModelAdapter());
    _pendingEmployeesBox = await Hive.openBox<OfflineEmployeeModel>(kPendingEmployeesBox);
    _authBox = await Hive.openBox(kAuthBox);
  }

  // Auth
  Future<void> saveAuthToken(String token) => _authBox.put(kAuthTokenKey, token);
  String? getAuthToken() => _authBox.get(kAuthTokenKey);
  Future<void> saveUserInfo(Map<String, dynamic> userInfo) => _authBox.put(kUserInfoKey, userInfo);
  Map<String, dynamic>? getUserInfo() {
    final data = _authBox.get(kUserInfoKey);
    return data != null ? Map<String, dynamic>.from(data) : null;
  }

  Future<void> saveMdmsOptions(String schemaCode, List<Map<String, dynamic>> options) =>
      _authBox.put('${kMdmsCachePrefix}$schemaCode', jsonEncode(options));

  List<Map<String, dynamic>>? getMdmsOptions(String schemaCode) {
    final data = _authBox.get('${kMdmsCachePrefix}$schemaCode');
    if (data == null) return null;
    try {
      final decoded = jsonDecode(data.toString());
      if (decoded is List) {
        return decoded.whereType<Map<String, dynamic>>().map((e) => Map<String, dynamic>.from(e)).toList();
      }
    } catch (_) {}
    return null;
  }

  Future<void> saveBoundaryRoot(Map<String, dynamic> boundaryRoot) => _authBox.put(kBoundaryCacheKey, jsonEncode(boundaryRoot));

  Map<String, dynamic>? getBoundaryRoot() {
    final data = _authBox.get(kBoundaryCacheKey);
    if (data == null) return null;
    try {
      final decoded = jsonDecode(data.toString());
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {}
    return null;
  }

  Future<void> clearAuth() async {
    await _authBox.delete(kAuthTokenKey);
    await _authBox.delete(kUserInfoKey);
  }

  // Offline Employees
  Future<void> savePendingEmployee(OfflineEmployeeModel employee) async {
    await _pendingEmployeesBox.add(employee);
  }

  List<OfflineEmployeeModel> getPendingEmployees() {
    return _pendingEmployeesBox.values.toList();
  }

  Future<void> deletePendingEmployee(int index) async {
    await _pendingEmployeesBox.deleteAt(index);
  }

  Future<void> clearAllPending() async {
    await _pendingEmployeesBox.clear();
  }

  int get pendingCount => _pendingEmployeesBox.length;
}
