import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/error/failures.dart';
import 'package:medical/src/model/app_api.dart';
import 'package:medical/src/model/response/default_model_response.dart';
import 'package:medical/src/widget/helper/http_helper.dart';

import 'models/voucherList_response.dart';

late AppApi appClient;

class VoucherRepository extends FetchClient {
  Future<Either<Failure, VoucherListResponse>> getListVoucher() async {
    final Response response = await super.fetchData(
      url: '/App/Voucher/Mobile',
      params: {
        "size": "100",
        "page": "1",
      },
    );
    try {
      if (response.statusCode == 200) {
        return Right(VoucherListResponse.fromJson(response.data));
      }
      return Left(
          Failure(message: R.string.error_can_not_connect_to_server.tr()));
    } catch (e) {
      return Left(
        Failure(message: R.string.error_can_not_connect_to_server.tr()),
      );
    }
  }

  Future<Either<Failure, VoucherModel>> getVoucherDetail(
      String voucherId) async {
    final Response response = await super.fetchData(
      url: '/App/Voucher/Mobile/$voucherId',
    );
    try {
      if (response.statusCode == 200) {
        return Right(VoucherModel.fromJson(response.data));
      }
      return Left(
          Failure(message: R.string.error_can_not_connect_to_server.tr()));
    } catch (e) {
      return Left(
        Failure(message: R.string.error_can_not_connect_to_server.tr()),
      );
    }
  }

  Future<Either<Failure, bool>> checkVoucherAvailable() async {
    final Response response = await super.fetchData(
      url: 'App/Voucher/Mobile/TrackingVoucherAvailable',
    );
    try {
      if (response.statusCode == 200) {
        DefaultModelResponse responseData =
            DefaultModelResponse.fromJson(response.data);
        return Right(responseData.data['isAvailable']);
      }
      return Left(
          Failure(message: R.string.error_can_not_connect_to_server.tr()));
    } catch (e) {
      return Left(
        Failure(message: R.string.error_can_not_connect_to_server.tr()),
      );
    }
  }

  Future<Either<Failure, bool>> useVoucher(String voucherId) async {
    final Response response = await super.putData2(
      url: '/App/Voucher/Mobile/ChangeStatus/$voucherId',
    );
    try {
      DefaultModelResponse responseData =
          DefaultModelResponse.fromJson(response.data);
      if (response.statusCode == 200) {
        return Right(responseData.meta.success);
      }
      return Left(
          Failure(message: R.string.error_can_not_connect_to_server.tr()));
    } catch (e) {
      return Left(
        Failure(message: R.string.error_can_not_connect_to_server.tr()),
      );
    }
  }

  static final VoucherRepository _instance = VoucherRepository._internal();
  factory VoucherRepository() {
    return _instance;
  }
  VoucherRepository._internal();
}
