// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../../global.dart';
import 'cache.dart';
import 'connectivity_request_retrier.dart';
import 'error_interceptor.dart';
import 'net_cache.dart';
import 'retry_interceptor.dart';

class Http {
  ///超时时间
  static const int CONNECT_TIMEOUT = 5000;
  static const int RECEIVE_TIMEOUT = 5000;

  static final Http _instance = Http._internal();

  factory Http() => _instance;

  Dio? dio;

  Http._internal() {
    // BaseOptions、Options、RequestOptions 都可以配置参数，优先级别依次递增，且可以根据优先级别覆盖参数
    BaseOptions options = BaseOptions(
      connectTimeout: Duration(milliseconds: CONNECT_TIMEOUT),
      // 响应流上前后两次接受到数据的间隔，单位为毫秒。
      receiveTimeout: Duration(milliseconds: RECEIVE_TIMEOUT),
    );

    dio = Dio(options);
    (dio!.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };
    // 日志输出
    dio!.interceptors.add(PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90));

    // 添加拦截器
    dio!.interceptors.add(ErrorInterceptor());
    // 加内存缓存
    dio!.interceptors.add(NetCacheInterceptor());
    dio!.interceptors.add(
      RetryOnConnectionChangeInterceptor(
        requestRetrier: DioConnectivityRequestRetrier(
          dio: dio!,
          connectivity: Connectivity(),
        ),
      ),
    );

    dio!.interceptors.add(LogInterceptor());

    // 在调试模式下需要抓包调试，所以我们使用代理，并禁用HTTPS证书校验
    // if (PROXY_ENABLE) {
    //   IOHttpClientAdapter adapter = IOHttpClientAdapter();
    //   adapter.onHttpClientCreate = (client) {
    //     client.findProxy = (uri) {
    //       // 将请求代理至 localhost:8888。
    //       // 请注意，代理会在你正在运行应用的设备上生效，而不是在宿主平台生效。
    //       return 'PROXY localhost:8082';
    //     };
    //     return client;
    //   };
    //   dio!.httpClientAdapter = adapter;
    // }
  }

  ///初始化公共属性
  ///
  /// [interceptors] 基础拦截器
  void init({List<Interceptor>? interceptors}) {
    dio!.options = dio!.options.copyWith(
        baseUrl: Global.host,
        // contentType: 'application/json; charset=utf-8 ',
        headers: {});
    if (interceptors != null && interceptors.isNotEmpty) {
      dio!.interceptors.addAll(interceptors);
    }
  }

  /// 设置headers
  void setHeaders(Map<String, dynamic> map) {
    dio!.options.headers.addAll(map);
  }

  /// 读取本地配置
  Map<String, dynamic> getAuthorizationHeader() {
    Map<String, String> headers;
    headers = {
      "accept": "application/json"
    }; //"Authorization": 'Bearer $accessToken'
    return headers;
  }

  /// restful get 操作
  Future get(
    String path, {
    Map<String, dynamic>? params,
    Options? options,
    bool refresh = false,
    bool noCache = !CACHE_ENABLE,
    String? cacheKey,
    bool cacheDisk = false,
  }) async {
    Options requestOptions = options ?? Options();
    requestOptions = requestOptions.copyWith(extra: {
      "refresh": refresh,
      "noCache": noCache,
      "cacheKey": cacheKey,
      "cacheDisk": cacheDisk,
    });
    Map<String, dynamic> authorization = getAuthorizationHeader();
    if (authorization.isNotEmpty) {
      requestOptions = requestOptions.copyWith(headers: authorization);
    }
    Response response;
    response =
        await dio!.get(path, queryParameters: params, options: requestOptions);
    return response.data;
  }

  /// restful post 操作
  Future post(
    String path, {
    Map<String, dynamic>? params,
    data,
    Options? options,
  }) async {
    Options requestOptions = options ?? Options();
    Map<String, dynamic> authorization = getAuthorizationHeader();
    if (authorization.isNotEmpty) {
      requestOptions = requestOptions.copyWith(headers: authorization);
    }
    // requestOptions = requestOptions.copyWith(
    //   sendTimeout: Duration(seconds: 3),
    //   receiveTimeout: Duration(seconds: 3),
    //   contentType: "application/json-patch+json",
    //   method: "POST",
    //   responseDecoder: (responseBytes, options, responseBody) {
    //     print('helllos');
    //   },
    // );

    var response = await dio?.post(
      path,
      data: data,
      queryParameters: params,
      options: requestOptions,
      onSendProgress: (count, total) {
        print("$count / $total");
      },
    );
    return response?.data;
  }

  /// restful put 操作
  Future put(
    String path, {
    data,
    Map<String, dynamic>? params,
    Options? options,
  }) async {
    Options requestOptions = options ?? Options();

    Map<String, dynamic> authorization = getAuthorizationHeader();
    if (authorization.isNotEmpty) {
      requestOptions = requestOptions.copyWith(headers: authorization);
    }
    var response = await dio!.put(path,
        data: data, queryParameters: params, options: requestOptions);
    return response.data;
  }

  /// restful patch 操作
  Future patch(
    String path, {
    data,
    Map<String, dynamic>? params,
    Options? options,
  }) async {
    Options requestOptions = options ?? Options();
    Map<String, dynamic> authorization = getAuthorizationHeader();
    if (authorization.isNotEmpty) {
      requestOptions = requestOptions.copyWith(headers: authorization);
    }
    var response = await dio!.patch(path,
        data: data, queryParameters: params, options: requestOptions);
    return response.data;
  }

  /// restful delete 操作
  Future delete(
    String path, {
    data,
    Map<String, dynamic>? params,
    Options? options,
  }) async {
    Options requestOptions = options ?? Options();

    Map<String, dynamic> authorization = getAuthorizationHeader();
    if (authorization.isNotEmpty) {
      requestOptions = requestOptions.copyWith(headers: authorization);
    }
    var response = await dio!.delete(path,
        data: data, queryParameters: params, options: requestOptions);
    return response.data;
  }

  /// restful post form 表单提交操作
  Future postForm(
    String path, {
    Map<String, dynamic>? params,
    Options? options,
  }) async {
    Options requestOptions = options ?? Options();
    Map<String, dynamic> authorization = getAuthorizationHeader();
    if (authorization.isNotEmpty) {
      requestOptions = requestOptions.copyWith(headers: authorization);
    }
    var response = await dio!.post(path,
        data: FormData.fromMap(params ?? {}), options: requestOptions);
    return response.data;
  }
}
