import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/modal/base/images.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:medical/src/modal/medicine/search_medicine_result_model.dart';
import 'package:medical/src/utils/app_log.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/helper/http_helper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:io' show Platform;

import '../../widget/home/fliter_enum.dart';

class MedicineClient extends FetchClient {
  Future<SearchMedicineResultModel?> searchMedicine({required String searchText}) async {
    final Response response = await super.fetchData(
        url: '/App/Medications/GetListMedicine',
        params: {'Name': searchText});

    if (response.statusCode == 200) {
      return SearchMedicineResultModel.fromJson(response.data);
    } else {
      final error = Error.fromJson(response);
      throw error;
    }
  }
}