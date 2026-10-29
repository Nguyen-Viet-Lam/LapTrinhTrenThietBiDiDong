import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_exception.dart';

class GroupEvent {
  final String type;
  final Map<String, dynamic> data;

  const GroupEvent({required this.type, required this.data});

  @override
  String toString() => 'GroupEvent(type: $type, data: $data)';
}

class ApiClient {
  ApiClient({
    Dio? dio,
    SharedPreferences? preferences,
    this.onUnauthorized,
  }) : _dio = dio ?? Dio(),
       _preferences = preferences {
    _initDio();
  }

  static const String tokenKey = 'lifequest_jwt_token';
  static const Duration defaultTimeout = Duration(seconds: 15);

  final Dio _dio;
  final SharedPreferences? _preferences;
  VoidCallback? onUnauthorized;
  String? _token;

  String? get token => _token;

  static String get defaultBaseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000/api';
    }
    return 'http://localhost:3000/api';
  }

  void _initDio() {
    _dio.options.baseUrl = defaultBaseUrl;
    _dio.options.connectTimeout = defaultTimeout;
    _dio.options.receiveTimeout = defaultTimeout;
    _dio.options.sendTimeout = defaultTimeout;
    _dio.options.headers['Content-Type'] = 'application/json';

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_token != null && _token!.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $_token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            await clearToken();
            onUnauthorized?.call();
          }
          final apiException = _mapDioException(error);
          return handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              response: error.response,
              type: error.type,
              error: apiException,
            ),
          );
        },
      ),
    );
  }

  ApiException _mapDioException(DioException error) {
    if (error.error is ApiException) {
      return error.error as ApiException;
    }
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;
    if (data is Map && data['error'] != null) {
      return ApiException(statusCode, data['error'].toString());
    }

    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => ApiException(
        statusCode,
        'Hết thời gian kết nối (15 giây). Vui lòng thử lại.',
      ),
      DioExceptionType.connectionError => ApiException(
        statusCode,
        'Không thể kết nối đến máy chủ. Vui lòng kiểm tra mạng hoặc đảm bảo backend đang chạy.',
      ),
      DioExceptionType.cancel => ApiException(statusCode, 'Yêu cầu đã bị hủy.'),
      _ => ApiException(
        statusCode,
        statusCode != null
            ? 'Yêu cầu thất bại với mã lỗi $statusCode.'
            : 'Đã xảy ra lỗi không xác định. Vui lòng thử lại.',
      ),
    };
  }

  Future<void> loadToken() async {
    _token = _preferences?.getString(tokenKey);
  }

  Future<void> setToken(String token) async {
    _token = token;
    await _preferences?.setString(tokenKey, token);
  }

  Future<void> clearToken() async {
    _token = null;
    await _preferences?.remove(tokenKey);
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw e.error is ApiException ? e.error as ApiException : _mapDioException(e);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw e.error is ApiException ? e.error as ApiException : _mapDioException(e);
    }
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw e.error is ApiException ? e.error as ApiException : _mapDioException(e);
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw e.error is ApiException ? e.error as ApiException : _mapDioException(e);
    }
  }

  /// Subscribe to group events via Server-Sent Events (SSE).
  /// Reconnects automatically if disconnected unless stream is cancelled.
  Stream<GroupEvent> subscribeGroupEvents(String groupId) {
    late StreamController<GroupEvent> controller;
    CancelToken? cancelToken;
    bool isActive = true;

    Future<void> connect() async {
      while (isActive && !controller.isClosed) {
        cancelToken = CancelToken();
        try {
          final res = await _dio.get<ResponseBody>(
            '/groups/$groupId/events',
            queryParameters: {'token': _token ?? ''},
            options: Options(
              responseType: ResponseType.stream,
              headers: {
                'Accept': 'text/event-stream',
                'Cache-Control': 'no-cache',
              },
            ),
            cancelToken: cancelToken,
          );

          String currentEvent = 'message';
          final buffer = StringBuffer();

          await for (final line in res.data!.stream
              .cast<List<int>>()
              .transform(utf8.decoder)
              .transform(const LineSplitter())) {
            if (!isActive || controller.isClosed) break;
            if (line.isEmpty) {
              if (buffer.isNotEmpty) {
                final rawData = buffer.toString().trim();
                buffer.clear();
                Map<String, dynamic> data = {};
                try {
                  data = jsonDecode(rawData) as Map<String, dynamic>;
                } catch (_) {}
                if (!controller.isClosed) {
                  controller.add(GroupEvent(type: currentEvent, data: data));
                }
                currentEvent = 'message';
              }
            } else if (line.startsWith('event: ')) {
              currentEvent = line.substring(7).trim();
            } else if (line.startsWith('data: ')) {
              buffer.writeln(line.substring(6));
            } else if (line.startsWith(':')) {
              // Comment / ping, ignore
            }
          }
        } catch (e) {
          if (!isActive || controller.isClosed) break;
          // Wait 2 seconds before reconnecting
          await Future<void>.delayed(const Duration(seconds: 2));
        }
      }
    }

    controller = StreamController<GroupEvent>(
      onListen: () {
        isActive = true;
        connect();
      },
      onCancel: () {
        isActive = false;
        cancelToken?.cancel();
      },
    );

    return controller.stream;
  }
}
