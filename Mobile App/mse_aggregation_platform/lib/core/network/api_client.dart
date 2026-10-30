import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';
import '../constants/api_constants.dart';
import '../errors/error_handler.dart';
import '../errors/app_exception.dart';

/// Singleton Dio client with persistent cookie-jar for session management.
class ApiClient {
  ApiClient._();
  static final ApiClient _instance = ApiClient._();
  factory ApiClient() => _instance;

  late final Dio _dio;
  late final PersistCookieJar _cookieJar;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    final appDocDir = await getApplicationDocumentsDirectory();
    _cookieJar = PersistCookieJar(
      storage: FileStorage('${appDocDir.path}/.cookies/'),
    );
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );
    _dio.interceptors.add(CookieManager(_cookieJar));
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => debugPrint(obj.toString()),
    ));
    _initialized = true;
  }

  void debugPrint(String msg) {
    // ignore in production
    // ignore: avoid_print
    print('[ApiClient] $msg');
  }

  Future<Response> get(String path, {Map<String, dynamic>? params}) async {
    try {
      return await _dio.get(path, queryParameters: params);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<Response> post(String path, {dynamic data}) async {
    try {
      return await _dio.post(path, data: data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<Response> patch(String path, {dynamic data}) async {
    try {
      return await _dio.patch(path, data: data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<Response> put(String path, {dynamic data}) async {
    try {
      return await _dio.put(path, data: data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// Clears the persisted session cookies (used on logout)
  Future<void> clearCookies() async {
    await _cookieJar.deleteAll();
  }

  /// Check whether a response indicates an error and throw appropriate exception
  static void checkResponse(Response response) {
    if (response.statusCode == 401) throw const UnauthorizedException();
    if (response.statusCode == 403) {
      final msg = (response.data is Map) ? response.data['error'] ?? response.data['message'] : null;
      throw ForbiddenException(message: msg?.toString() ?? 'Access denied');
    }
    if (response.statusCode == 409) {
      final msg  = (response.data is Map) ? response.data['error'] ?? response.data['message'] : 'Conflict';
      final code = (response.data is Map) ? response.data['code'] : null;
      throw ConflictException(message: msg.toString(), code: code?.toString());
    }
    if (response.statusCode == 422) {
      final msg  = (response.data is Map) ? response.data['error'] ?? response.data['message'] : 'Validation error';
      final code = (response.data is Map) ? response.data['code'] : null;
      throw ValidationException(message: msg.toString(), code: code?.toString());
    }
    if ((response.statusCode ?? 500) >= 400) {
      final msg = (response.data is Map) ? response.data['error'] ?? response.data['message'] : null;
      throw AppException(message: msg?.toString() ?? 'An error occurred', statusCode: response.statusCode);
    }
  }
}
