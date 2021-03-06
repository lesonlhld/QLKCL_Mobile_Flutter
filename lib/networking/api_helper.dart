// ignore_for_file: deprecated_member_use

import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:qlkcl/components/bot_toast.dart';
import 'package:qlkcl/networking/response.dart' as custom_response;
import 'package:qlkcl/utils/api.dart';
import 'dart:convert';
import 'package:qlkcl/helper/authentication.dart';

// cre: https://stackoverflow.com/questions/56740793/using-interceptor-in-dio-for-flutter-to-refresh-token

// cre: https://gist.github.com/RyanDsilva/ee205c02f98df9f830dcd9034e9a5e9b

class ApiHelper {
  static BaseOptions opts = BaseOptions(
    baseUrl: Api.baseUrl,
    connectTimeout: 15000,
    receiveTimeout: 12000,
  );

  static Dio createDio() {
    return Dio(opts);
  }

  static Dio addInterceptors(Dio dio) {
    // adding interceptor
    dio.interceptors.clear();
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // var accessToken = await getAccessToken();
        // var refreshToken = await getRefreshToken();
        // bool _token = isTokenExpired(accessToken!);
        // bool _refresh = isTokenExpired(refreshToken!);
        requestInterceptor(options);
        return handler.next(options); //modify your request
      },
      onResponse: (response, handler) {
        //on success it is getting called here
        return handler.next(response);
      },
      onError: (DioError e, handler) async {
        if (e.response != null) {
          if (e.response!.statusCode == 401) {
            // catch the 401 here
            // If user is unauthorized
            // Lock error, response, request here
            dio.interceptors.requestLock.lock();
            dio.interceptors.responseLock.lock();
            final RequestOptions requestOptions = e.requestOptions;

            /// Silently refresh token here
            final accessToken = await refreshToken();
            if (accessToken != null) {
              // Unlock error, response, request here
              final opts = Options(method: requestOptions.method);
              dio.options.headers["Authorization"] = "Bearer $accessToken";
              dio.options.headers["Accept"] = "*/*";
              dio.interceptors.requestLock.unlock();
              dio.interceptors.responseLock.unlock();
              final response = await dio.request(requestOptions.path,
                  options: opts,
                  cancelToken: requestOptions.cancelToken,
                  onReceiveProgress: requestOptions.onReceiveProgress,
                  data: requestOptions.data,
                  queryParameters: requestOptions.queryParameters);

              // If you want to resolve the request with some custom data,
              // you can resolve a 'Response' object eg: 'handler.resolve(response)'
              handler.resolve(response);
            } else {
              //If dont unlock, every request and response after refresh request failding may never be executed to
              dio.interceptors.requestLock.unlock();
              dio.interceptors.responseLock.unlock();
              handler.reject(e);
            }
          } else {
            // Do something with response error
            handler.next(e);
          }
        } else {
          BotToast.closeAllLoading();
          showNotification("L???i k???t n???i m???ng!",
              status: custom_response.Status.error);
        }
      },
    ));
    return dio;
  }

  static dynamic requestInterceptor(RequestOptions options) async {
    // Get your JWT accessToken
    final String? accessToken = await getAccessToken();
    if (accessToken != null && accessToken != '') {
      options.headers.addAll({"Authorization": "Bearer $accessToken"});
    }
    return options;
  }

  static Future<String?> refreshToken() async {
    Response response;
    final dio = Dio();
    final Uri apiUrl = Uri.parse("${Api.baseUrl}/api/token/refresh");
    final refreshToken = await getRefreshToken();
    try {
      response = await dio.postUri(
        apiUrl,
        data: {'refresh': refreshToken},
      );
      if (response.statusCode == 200) {
        final refreshTokenResponse = jsonDecode(response.toString());
        final accessToken = refreshTokenResponse['access'];
        await setAccessToken(accessToken);
        final refreshToken = refreshTokenResponse['refresh'];
        await setRefreshToken(refreshToken);
        return accessToken;
      } else {
        print(response.toString());
        showTextToast(
            'Phi??n l??m vi???c ???? h???t h???n, vui l??ng ????ng xu???t v?? ????ng nh???p l???i.');
        // await logout();
        return null;
      }
    } catch (e) {
      print(e.toString());
      showTextToast(
          'Phi??n l??m vi???c ???? h???t h???n, vui l??ng ????ng xu???t v?? ????ng nh???p l???i.');
      // await logout();
      return null;
    }
  }

  static final dio = createDio();
  static final baseAPI = addInterceptors(dio);

  Future<dynamic> getHTTP(String url) async {
    try {
      final Response response = await baseAPI.get(url);
      return response.data;
    } on DioError catch (e) {
      // Handle error
      handleException(e);
    }
  }

  Future<dynamic> postHTTP(String url, data) async {
    try {
      if (data is PlatformFile) {
        final FormData formData = FormData.fromMap({
          "file": MultipartFile.fromBytes(List<int>.from(data.bytes!),
              filename: data.name),
        });
        final Response response = await baseAPI.post(url, data: formData);
        return response.data;
      } else {
        final Response response = await baseAPI.post(url,
            data: data != null ? FormData.fromMap(data) : null);
        return response.data;
      }
    } on DioError catch (e) {
      // Handle error
      handleException(e);
    }
  }

  Future<dynamic> putHTTP(String url, data) async {
    try {
      final Response response = await baseAPI.put(url,
          data: data != null ? FormData.fromMap(data) : null);
      return response.data;
    } on DioError catch (e) {
      // Handle error
      handleException(e);
    }
  }

  Future<dynamic> deleteHTTP(String url) async {
    try {
      final Response response = await baseAPI.delete(url);
      return response.data;
    } on DioError catch (e) {
      // Handle error
      handleException(e);
    }
  }

  void handleException(e) {
    // The request was made and the server responded with a status code
    // that falls out of the range of 2xx and is also not 304.
    if (e.response != null) {
      print('Dio error!');
      print('STATUS: ${e.response?.statusCode}');
      print('DATA: ${e.response?.data}');
      print('HEADERS: ${e.response?.headers}');
    } else {
      // Error due to setting up or sending the request
      print('Error sending request!');
      print(e.message);
    }
  }
}
