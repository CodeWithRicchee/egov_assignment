import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../env/app_env.dart';
import '../error/exceptions.dart';

@singleton
class NetworkClient {
  late final Dio _dio;
  final Logger _logger = Logger();

  NetworkClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppEnv.baseUrl,
        connectTimeout: Duration(milliseconds: AppEnv.connectTimeout),
        receiveTimeout: Duration(milliseconds: AppEnv.receiveTimeout),
        sendTimeout: Duration(milliseconds: AppEnv.sendTimeout),
        contentType: 'application/json',
      ),
    );
    _dio.interceptors.add(_LoggingInterceptor(_logger));
    _dio.interceptors.add(_AuthInterceptor());
  }

  Dio get dio => _dio;

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParams,
    Options? options,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParams,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParams, dynamic data}) async {
    try {
      return await _dio.get(path, queryParameters: queryParams, data: data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException(message: 'Connection timed out. Please check your internet connection.');
      case DioExceptionType.connectionError:
        return NetworkException(message: 'No internet connection.');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401) {
          return AuthException(message: 'Unauthorized. Please login again.');
        }
        final errorMsg = _extractErrorMessage(e.response?.data) ?? 'Server error occurred';
        return ServerException(message: errorMsg, statusCode: statusCode);
      default:
        return ServerException(message: e.message ?? 'An unexpected error occurred');
    }
  }

  String? _extractErrorMessage(dynamic data) {
    if (data is Map) {
      return data['Errors']?.first?['message'] ?? data['error']?['message'] ?? data['message']?.toString();
    }
    return null;
  }
}

class _LoggingInterceptor extends Interceptor {
  final Logger logger;
  _LoggingInterceptor(this.logger);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    logger.d('→ ${options.method} ${options.uri}');
    logger.d('Headers: ${options.headers}');
    if (options.data != null) {
      logger.d('Body: ${options.data}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    logger.d('← ${response.statusCode} ${response.requestOptions.uri}');
    logger.d('Response: ${response.data}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    logger.e('✗ ${err.requestOptions.uri}: ${err.message}');
    if (err.response != null) {
      logger.e('Status code: ${err.response!.statusCode}');
      logger.e('Response body: ${err.response!.data}');
    }
    handler.next(err);
  }
}

class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // AuthToken is embedded in each request body/header per API design
    handler.next(options);
  }
}
