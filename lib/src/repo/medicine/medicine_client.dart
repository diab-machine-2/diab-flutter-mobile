import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/modal/base/images.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:medical/src/modal/medicine/prescription_model.dart';
import 'package:medical/src/modal/medicine/search_medicine_result_model.dart';
import 'package:medical/src/utils/app_log.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/helper/http_helper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:io' show File, Platform;

import '../../modal/medicine/medicine_item_model.dart';
import '../../modal/medicine/medicine_schedule_model.dart';
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

  Future<SearchMedicineResultModel?> addNewMedicine({required String medicineName}) async {
    final Response response = await super.fetchData(
        url: '/App/Medications/GetListMedicine',
        params: {'Name': medicineName});

    if (response.statusCode == 200) {
      return SearchMedicineResultModel.fromJson(response.data);
    } else {
      final error = Error.fromJson(response);
      throw error;
    }
  }

  Future<List<MedicineItemModel>?> uploadPrescriptionPhoto({required File file}) async {
    try {
      final response = await super.postHttp(
          path: '/App/Image/UploadAI/Medications',
          files: [file.path],
          params: {'filePath': file.path}
      );

      if (response.statusCode == 200) {
        final data = await response.stream.bytesToString();
        final jsonData = jsonDecode(data);
        final list = MedicineItemModelMapper.fromJsonList(jsonData);
        return list;
      } else {
        throw response.reasonPhrase!;
      }
    } catch (ex) {
      throw R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<bool> createNewPrescription({required PrescriptionModel prescription, required Map<String, String>? paths}) async {
    final Map<String, String> params = {
      'Data': jsonEncode(prescription.toJson()),
    };

    try {
      final response = await super.postHttp4(
        path: '/App/prescriptions',
        params: params,
        fileMap: paths,
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw response.reasonPhrase!;
      }
    } catch (ex) {
      throw R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<bool> updatePrescription({
    required PrescriptionModel prescription,
    required Map<String, String>? paths}) async {
    final Map<String, String> params = {
      'Data': jsonEncode(prescription.toJson(includedMedicationId: false)),
      'ImagesPrescriptionIds': jsonEncode(prescription.imagesPrescription)
    };

    try {
      final response = await super.patchHttp(
        path: '/App/prescriptions/${prescription.id!}',
        params: params,
        fileMap: paths,
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw response.reasonPhrase!;
      }
    } catch (ex) {
      throw R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<bool> stopPrescription({required String id}) async {
    final Map<String, dynamic> params = {
      'status': 1,
      'id': id,
    };

    try {
      final response = await super.putData(
          url: '/App/prescriptions/status',
          params: params
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (ex) {
      throw R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<List<PrescriptionModel>> fetchPrescriptions() async {
    try {
      final response = await super.fetchData(
        url: '/App/prescriptions/CurrentState',
      );

      if (response.statusCode == 200) {
        if (response.data.length == 0) return <PrescriptionModel>[];
        return PrescriptionModel.fromJsonList(response.data);
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (ex) {
      throw R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<PrescriptionModel> fetchPrescription({required String id}) async {
    try {
      final response = await super.fetchData(
          url: '/App/prescriptions/CurrentState',
          params: {'id': id}
      );

      if (response.statusCode == 200) {
        return PrescriptionModel.fromJson(response.data);
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (ex) {
      throw R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<MedicineScheduleModel> fetchMedicineScheduleByDate({required int timestamp}) async {
    try {
      final response = await super.fetchData(
          url: '/App/Target',
          params: {'day': timestamp.toString()}
      );

      if (response.statusCode == 200) {
        return MedicineScheduleModel.fromJson(response.data['data']);
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (ex) {
      throw R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<bool> useMedicine({required String id}) async {
    try {
      final response = await super.putData(
        url: '/App/Target/Medication/$id',
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw response.statusMessage!;
      }
    } catch (ex) {
      throw R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<bool> usedAllMedicinesToday({required int status}) async {
    try {
      final currentDateTime = DateTime.now();
      final today = DateTime(currentDateTime.year, currentDateTime.month, currentDateTime.day, 7);

      final response = await super.putData(
          url: '/App/Target/Medication/CurrentRemind',
          params: {
            'currentDate': (today.millisecondsSinceEpoch / 1000).round(),
            'status': status,
          }
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw response.statusMessage!;
      }
    } catch (ex) {
      throw R.string.error_can_not_connect_to_server.tr();
    }
  }
}