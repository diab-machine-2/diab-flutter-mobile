import 'dart:async';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';
import 'package:medical/src/utils/logger.dart';
import 'package:medical/src/utils/utils.dart';

import 'payment_package.dart';

class PaymentPackageCubit extends Cubit<PaymentPackageState> {
  final AppRepository appRepository;
  late StreamSubscription _purchaseUpdatedSubscription;
  late StreamSubscription _purchaseErrorSubscription;
  late StreamSubscription _connectionSubscription;
  List<IAPItem> listItem = [];

  PaymentPackageCubit(this.appRepository) : super(PaymentPackageInitial()) {
    initConnect();
  }

  Future<void> initConnect() async {
    var result = await FlutterInappPurchase.instance.initConnection;
    logger.i('result: $result');
    initPlatformState();
    getListSubscription();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    _connectionSubscription =
        FlutterInappPurchase.connectionUpdated.listen((connected) {
      logger.i('connected: $connected');
    });

    _purchaseUpdatedSubscription =
        FlutterInappPurchase.purchaseUpdated.listen((productItem) {
      logger.i('purchase-updated: $productItem');
      if (productItem != null) {
        handlePurchase(productItem);
        FlutterInappPurchase.instance.finishTransaction(productItem);
      }
    });

    _purchaseErrorSubscription =
        FlutterInappPurchase.purchaseError.listen((purchaseError) {
      logger.i('purchase-error: $purchaseError');
      String? error = purchaseError?.message;
      handlePurchase(null, error: error);
    });
  }

  void requestPurchase(int monthUsed) async {
    emit(PaymentPackageLoading());
    if (!(await Utils.checkConnection())) {
      emit(PaymentPackageFailure(R.string.error_no_network_connection.tr()));
      return;
    } else {
      String skuId = "pro_${monthUsed}_${Platform.isIOS ? "months" : "month"}";
      logger.i(skuId);
      int indexSku =
          listItem.indexWhere((element) => element.productId == skuId);
      if (indexSku >= 0) {
        FlutterInappPurchase.instance.requestSubscription(skuId);
      } else {
        emit(PaymentPackageFailure(R.string.not_found_sku.tr()));
      }
    }
  }

  void handlePurchase(PurchasedItem? item, {String? error}) async {
    emit(PaymentPackageLoading());
    if (!Utils.isEmpty(error)) {
      emit(PaymentPackageFailure(error!));
    } else {
      if (Platform.isIOS) {
        ApiResult<dynamic> apiResult = await appRepository.verifyReceipt(
            receipt: item!.transactionReceipt);
        apiResult.when(success: (dynamic response) {
          emit(PurchaseSuccess());
        }, failure: (NetworkExceptions error) {
          logger.e(NetworkExceptions.getErrorMessage(error));
        });
      } else {
        emit(PurchaseSuccess());
      }
    }
  }

  void getListSubscription() async {
    emit(PaymentPackageLoading());
    List<String> skus = Platform.isIOS
        ? ["pro_1_months", "pro_3_months", "pro_12_months"]
        : ["pro_1_month", "pro_3_month", "pro_12_month"];
    listItem = await FlutterInappPurchase.instance.getSubscriptions(skus);
    emit(PaymentPackageInitial());
  }

  @override
  Future<void> close() async {
    _connectionSubscription.cancel();
    _purchaseUpdatedSubscription.cancel();
    _purchaseErrorSubscription.cancel();
    await FlutterInappPurchase.instance.endConnection;
    return super.close();
  }
}
