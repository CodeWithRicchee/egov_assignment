import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppEnv {
  AppEnv._();

  static String get baseUrl => dotenv.env['BASE_URL'] ?? '';
  static String get mdmsApiPath => dotenv.env['MDMS_API_PATH'] ?? '';
  static String get employeeSearchPath => dotenv.env['EMPLOYEE_SEARCH_PATH'] ?? '';
  static String get employeeCreatePath => dotenv.env['EMPLOYEE_CREATE_PATH'] ?? '';
  static String get boundarySearchPath => dotenv.env['BOUNDARY_SEARCH_PATH'] ?? '';
  static String get tenantId => dotenv.env['TENANT_ID'] ?? 'dev';
  static String get hierarchyType => dotenv.env['HIERARCHY_TYPE'] ?? '';
  static String get envName => dotenv.env['ENV_NAME'] ?? '';

  // 🔐 New fields for OAuth client credentials
  static String get clientId => dotenv.env['CLIENT_ID'] ?? '';
  static String get clientSecret => dotenv.env['CLIENT_SECRET']?.replaceAll('"', '') ?? '';

  static int get connectTimeout => int.tryParse(dotenv.env['CONNECT_TIMEOUT'] ?? '120000') ?? 120000;
  static int get receiveTimeout => int.tryParse(dotenv.env['RECEIVE_TIMEOUT'] ?? '120000') ?? 120000;
  static int get sendTimeout => int.tryParse(dotenv.env['SEND_TIMEOUT'] ?? '120000') ?? 120000;
  static int get syncRetryCount => int.tryParse(dotenv.env['SYNC_DOWN_RETRY_COUNT'] ?? '3') ?? 3;
}
