import 'package:dio/dio.dart';
import 'api_exception.dart';

class DioClient {
  late final Dio _dio;

  DioClient() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        responseType: ResponseType.json,
      ),
    );
    _dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: false,
        responseBody: true,
        error: true,
      ),
    );
  }

  Future<dynamic> get(
    String url, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(url, queryParameters: queryParameters);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw ApiException('Unexpected error occurred: $e');
    }
  }

  Future<dynamic> post(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.post(url, data: data, queryParameters: queryParameters);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw ApiException('Unexpected error occurred: $e');
    }
  }

  Future<dynamic> put(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.put(url, data: data, queryParameters: queryParameters);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw ApiException('Unexpected error occurred: $e');
    }
  }

  Future<dynamic> delete(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.delete(url, data: data, queryParameters: queryParameters);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw ApiException('Unexpected error occurred: $e');
    }
  }

  ApiException _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return ApiException('Connection Timeout. Please check your internet.');
      case DioExceptionType.badResponse:
        return ApiException('Server error: ${error.response?.statusCode}');
      case DioExceptionType.connectionError:
        return ApiException('No internet connection.');
      default:
        return ApiException('Unknown network error.');
    }
  }
}
