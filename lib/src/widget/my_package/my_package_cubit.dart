import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/list_transaction_response.dart';
import 'package:medical/src/model/response/user_info_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/logger.dart';

import 'my_package.dart';

class MyPackageCubit extends Cubit<MyPackageState> {
  final AppRepository appRepository;
  List<TransactionData> listActiveTransaction = [];
  List<TransactionData> listExpiredTransaction = [];
  int _currentPage = 1;
  bool hasMorePage = true;

  String? ownCode;

  MyPackageCubit(this.appRepository) : super(MyPackageInitial());

  void getOwnPackageCode() async {
    ApiResult<UserInfoResponse> apiResult = await appRepository.getCurrentUserInfo();
    apiResult.when(success: (UserInfoResponse response) {
      // ownCode = response.data?.packageCode;
    }, failure: (NetworkExceptions error) {
      logger.e(NetworkExceptions.getErrorMessage(error));
    });
  }

  void getListTransaction(
      {bool isRefresh = false, bool isLoadMore = false}) async {
    emit((!isRefresh && !isLoadMore) ? MyPackageLoading() : MyPackageInitial());
    if (isRefresh) _currentPage = 1;
    if (isLoadMore) {
      _currentPage++;
    }
    if (isLoadMore == false) {
      List<ApiResult<ListTransactionResponse>> apiResults = await Future.wait([
        appRepository.getListTransaction(isExpired: false, page: 1, size: 100),
        appRepository.getListTransaction(isExpired: true, page: 1, size: 100)
      ]);
      List.generate(apiResults.length, (index) {
        apiResults[index].when(success: (ListTransactionResponse response) {
          if (index == 0) {
            listActiveTransaction = response.data ?? [];
          } else {
            listExpiredTransaction = response.data ?? [];
          }
          emit(MyPackageSuccess());
        }, failure: (NetworkExceptions error) {
          emit(MyPackageFailure(NetworkExceptions.getErrorMessage(error)));
        });
      });
    } else {
      ApiResult<ListTransactionResponse> apiResult =
          await appRepository.getListTransaction(
              isExpired: false, page: _currentPage, size: Const.DEFAULT_SIZE);
      apiResult.when(success: (ListTransactionResponse response) {
        listExpiredTransaction.addAll(response.data ?? []);
        emit(MyPackageSuccess());
      }, failure: (NetworkExceptions error) {
        emit(MyPackageFailure(NetworkExceptions.getErrorMessage(error)));
      });
    }
  }
}
