import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mahakal/data/datasource/remote/dio/logging_interceptor.dart';
import 'package:mahakal/utill/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DioClient {
  final String baseUrl;
  final LoggingInterceptor loggingInterceptor;
  final SharedPreferences sharedPreferences;

  Dio? dio;
  String? token;
  String? countryCode;

  DioClient(
    this.baseUrl,
    Dio? dioC, {
    required this.loggingInterceptor,
    required this.sharedPreferences,
  }) {
    token = sharedPreferences.getString(AppConstants.userLoginToken);
    countryCode = sharedPreferences.getString(AppConstants.countryCode) ??
        AppConstants.languages[0].countryCode;
    if (kDebugMode) {
      print("NNNN $token");
    }
    final initDio = dioC ?? Dio();
    dio = initDio;
    initDio
      ..options.baseUrl = baseUrl
      ..options.connectTimeout = const Duration(seconds: 15)
      ..options.receiveTimeout = const Duration(seconds: 30)
      ..httpClientAdapter
      ..options.headers = {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        AppConstants.langKey:
            countryCode == 'US' ? 'en' : countryCode!.toLowerCase(),
      }
      ..options.responseType = ResponseType.plain
      ..options.responseDecoder = (List<int> responseBytes, RequestOptions options, ResponseBody responseBody) {
        return utf8.decode(responseBytes, allowMalformed: true);
      };
    initDio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print("➡️ REQUEST: [${options.method}] ${options.uri}");
          _simpleLog("Headers: ${options.headers}");
          if (options.data != null) {
            _simpleLog("Body: ${options.data}");
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          print(
              "✅ RESPONSE [${response.statusCode}] => ${response.requestOptions.uri}");
          response.data = _coerceResponseData(response);
          if (kDebugMode && response.data.toString().length < 5000) {
            _simpleLog("Response Data: ${response.data}");
          } else if (kDebugMode) {
            _simpleLog("Response Data: [Large response, logging skipped]");
          }
          handler.next(response);
        },
        onError: (DioException e, handler) {
          print(
              "❌ ERROR [${e.response?.statusCode}] => ${e.requestOptions.uri}");
          _simpleLog("Error: ${e.message}");
          if (e.response?.data != null) {
            _simpleLog("Error Data: ${e.response?.data}");
          }
          handler.next(e);
        },
      ),
    );
  }

  String _safeDecode(List<int> bytes) =>
      const Utf8Decoder(allowMalformed: true).convert(bytes);

  dynamic _coerceResponseData(Response response) {
    try {
      if (response.requestOptions.responseType == ResponseType.bytes ||
          response.requestOptions.responseType == ResponseType.stream) {
        return response.data;
      }

      if (response.data is Map || response.data is List) return response.data;

      String raw;
      if (response.data is String) {
        raw = response.data as String;
      } else if (response.data is List<int>) {
        raw = _safeDecode(response.data as List<int>);
      } else if (response.data is List<dynamic>) {
        raw = _safeDecode((response.data as List<dynamic>).cast<int>());
      } else if (response.data != null) {
        raw = response.data.toString();
      } else {
        return response.data;
      }

      try {
        return json.decode(raw);
      } catch (_) {
        if (raw.contains('\uFFFD')) {
          final cleaned = raw.replaceAll('\uFFFD', '');
          try {
            return json.decode(cleaned);
          } catch (_) {
            return cleaned;
          }
        }
        return raw;
      }
    } catch (_) {
      return response.data;
    }
  }

  void _simpleLog(dynamic data) {
    final lines = data.toString().split('\n');
    final limited = lines.take(50).join('\n');
    print(limited);
    if (lines.length > 300) {
      print("... [Log truncated to 100 lines]");
    }
  }

  void updateHeader(String? token, String? countryCode) {
    token = token ?? this.token;
    countryCode = countryCode == null
        ? this.countryCode == 'US'
            ? 'en'
            : this.countryCode!.toLowerCase()
        : countryCode == 'US'
            ? 'en'
            : countryCode.toLowerCase();
    this.token = token;
    this.countryCode = countryCode;
    dio!.options.headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
      AppConstants.langKey:
          countryCode == 'US' ? 'en' : countryCode.toLowerCase(),
    };
  }

  Future<Response> get(
    String uri, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      var response = await dio!.get(
        uri,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on SocketException catch (e) {
      throw SocketException(e.toString());
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> post(
    String uri, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      var response = await dio!.post(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> put(
    String uri, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      var response = await dio!.put(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> delete(
    String uri, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      var response = await dio!.delete(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      rethrow;
    }
  }
}
