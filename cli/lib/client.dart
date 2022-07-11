import 'package:dio/dio.dart';

enum APIType {
  development,
  staging,
  production;

  String name() {
    switch (this) {
      case APIType.development:
        return "Dev";
      case APIType.staging:
        return "Staging";
      case APIType.production:
        return "Production";
    }
  }

  @override
  String toString() {
    switch (this) {
      case APIType.development:
        return "http://localhost:8000";
      case APIType.staging:
        return "http://localhost:8000";
      case APIType.production:
        return "http://localhost:8000";
    }
  }
}

class APIClient {
  final APIType _type;
  late Dio _dio;

  APIClient(this._type) {
    _dio = Dio(
      BaseOptions(
        baseUrl: _type.toString(),
        connectTimeout: 10,
      ),
    );
    _dio.interceptors.add(_useJSONHeader());
  }

  InterceptorsWrapper _useJSONHeader() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        options.headers.addAll({
          Headers.contentTypeHeader: Headers.jsonContentType,
        });
        print(options.headers);
        return handler.next(options);
      },
    );
  }

  APIClient useAuth() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers.addAll({
            'Authorization': 'Bearer my random token',
          });
          print(options.headers);
          return handler.next(options);
        },
      ),
    );
    return this;
  }

  APIClient useRetry() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (e, handler) async {
          final opts = Options(
            method: e.requestOptions.method,
            headers: e.requestOptions.headers,
          );
          print("[${_type.name()}] [RETRY]");
          await Future.delayed(Duration(seconds: 5));
          final cloneReq = await _dio.request(
            e.requestOptions.path,
            options: opts,
            data: e.requestOptions.data,
            queryParameters: e.requestOptions.queryParameters,
          );
          return handler.resolve(cloneReq);
        },
      ),
    );
    return this;
  }

  APIClient useAlterCertificate() {
    _dio.interceptors.add(InterceptorsWrapper());
    return this;
  }

  Dio build() {
    return _dio;
  }
}
