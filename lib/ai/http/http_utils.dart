import 'package:dio/dio.dart';

import 'cache.dart';
import 'http.dart';

class HttpUtils {
  static void init(
      {String? baseUrl,
      int? connectTimeout,
      int? receiveTimeout,
      List<Interceptor>? interceptors}) {
    Http().init(interceptors: interceptors ?? []);
  }

  static void setHeaders(Map<String, dynamic> map) {
    Http().setHeaders(map);
  }

  static Future get(
    String path, {
    Map<String, dynamic>? params,
    Options? options,
    bool refresh = false,
    bool noCache = !CACHE_ENABLE,
    bool cacheDisk = false,
  }) async {
    return await Http().get(
      path,
      params: params,
      options: options,
      refresh: refresh,
      noCache: noCache,
    );
  }

  static Future post(
    String path, {
    data,
    Map<String, dynamic>? params,
    Options? options,
  }) async {
    return await Http().post(
      path,
      data: data,
      params: params,
      options: options,
    );
  }

  static Future put(
    String path, {
    data,
    Map<String, dynamic>? params,
    Options? options,
  }) async {
    return await Http().put(
      path,
      data: data,
      params: params,
      options: options,
    );
  }

  static Future patch(
    String path, {
    data,
    Map<String, dynamic>? params,
    Options? options,
  }) async {
    return await Http().patch(
      path,
      data: data,
      params: params,
      options: options,
    );
  }

  static Future delete(
    String path, {
    data,
    Map<String, dynamic>? params,
    Options? options,
  }) async {
    return await Http().delete(
      path,
      data: data,
      params: params,
      options: options,
    );
  }

  static Future postForm(
    String path, {
    Map<String, dynamic>? params,
    Options? options,
  }) async {
    return await Http().postForm(
      path,
      params: params,
      options: options,
    );
  }
}
