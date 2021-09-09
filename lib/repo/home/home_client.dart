import 'package:dio/dio.dart';
import 'package:medical/app_setting/app_setting.dart';
import 'package:medical/modal/error/error_model.dart';
import 'package:medical/modal/home/home_model.dart';
import 'package:medical/widget/helper/http_helper.dart';

class HomeClient extends FetchClient {
  Future<HomeModel> fetchHomes() async {
    try {
      final Response response = await super.fetchData(url: '/App/Home');
      if (response.statusCode == 200) {
        await AppSettings.saveHome(response.data['data']);
        return HomeModel.fromJson(response.data['data']);
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error
          ? e
          : 'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi';
    }
  }
}
