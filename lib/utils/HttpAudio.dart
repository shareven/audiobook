import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:audiobook/utils/ResultData.dart';
import 'package:audiobook/utils/utils.dart';

class HttpAudio {
  static Future<ResultData> request(String url,
      {params, xShareKey, method}) async {
    
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      // I am connected to a mobile network.
    } else if (connectivityResult == ConnectivityResult.wifi) {
      // I am connected to a wifi network.
    } else {
      showErrorMsg('网络连接失败|Network connection failed');
      return ResultData("网络连接失败|Network connection failed", 111);
    }

    method ??= 'GET';

    BaseOptions options;
    options = new BaseOptions(method: method);
    
    options.connectTimeout = Duration(milliseconds: 10000); //5s
    options.receiveTimeout = Duration(milliseconds: 3000);

    try {
      Dio dio = new Dio(options);
      Response response = await dio.request(url, data: params);
      print(response.data);
      return ResultData(response.data, response.statusCode ?? 111);
    } on DioException catch (e) {
      var errorResponse;
      print(e.requestOptions.uri);
      print(e.message);
      errorResponse = e.response;
      if (errorResponse == null) {
        errorResponse = e.message;
      }
      showErrorMsg(errorResponse.toString());
      return ResultData(errorResponse, 111);
    }
  }
}
