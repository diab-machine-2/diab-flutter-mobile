import 'package:dio/dio.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:medical/src/modal/home/home_model.dart';
import 'package:medical/src/widget/helper/http_helper.dart';
import 'package:easy_localization/easy_localization.dart';

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
          : R.string.error_can_not_connect_to_server.tr();
    }
  }
}
