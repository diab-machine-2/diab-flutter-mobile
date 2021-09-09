import 'package:dio/dio.dart';
import 'package:medical/modal/upload/media_result.dart';
import 'package:medical/widget/helper/http_helper.dart';
import 'package:medical/modal/error/error_model.dart';

class UploadClient extends FetchClient {
  /// upload image
  Future<List<MediaResultModel>> uploadImage(List<String> urls) async {
    var formData = FormData();
    for (var file in urls) {
      formData.files.addAll([
        MapEntry("files", await MultipartFile.fromFile(file)),
      ]);
    }
  }
}
