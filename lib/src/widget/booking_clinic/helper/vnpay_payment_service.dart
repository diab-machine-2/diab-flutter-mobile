import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/app_setting/firebase_remote_config.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/booking_clinic/model/vnpay_model.dart';
import 'package:medical/src/widget/dsmes_appointment/dsmes_appointment_cubit.dart';
import 'package:http/http.dart' as http;
import 'package:medical/src/widget/dsmes_appointment/model/dsmes_appointment_model.dart';
import 'package:medical/src/widget/dsmes_appointment/pages/dsmes_navigation_mixin.dart';
import 'package:bot_toast/bot_toast.dart';

class VNPayService {
  static const platform = MethodChannel('paymentGateway');

  final BuildContext context;
  final int totalPrice;
  final String bookingType;
  final String serviceType;
  final DsmesAppointmentCubit cubit;

  String tmnCode = '';
  String paymentUrl = '';

  Map<String, bool> isProcessing = {
    'recheckInfo': false,
    'backHome': false,
    'repay': false,
  };

  VNPayService({
    required this.context,
    required this.totalPrice,
    required this.bookingType,
    required this.serviceType,
    required this.cubit,
  });

  Future<bool> initializePayment() async {
    final ipAddress = await _getPublicIpAddress();
    final accountId = AppSettings.userInfo?.accountId ?? '';

    // Get VNPAY config
    final vnpayIntegratedInfo =
        FirebaseRemoteSetting.instance.vnpayIntegratedInfo ?? '';
    if (vnpayIntegratedInfo.isEmpty) {
      BotToast.showCustomText(
        toastBuilder: (_) => Container(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          decoration: BoxDecoration(
            color: R.color.color0xff111515.withOpacity(0.7),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            R.string.payment_unavailable_warning.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: R.color.white,
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        align: Alignment.center,
        duration: Duration(seconds: 2),
        clickClose: true,
        crossPage: true,
        onlyOne: true,
      );
      return false;
    }

    final vnpayIntegratedInfoMap = jsonDecode(vnpayIntegratedInfo);
    tmnCode = vnpayIntegratedInfoMap['vnp_TmnCode'] ?? '';

    paymentUrl = VNPAYFlutter.instance.generatePaymentUrl(
      url: vnpayIntegratedInfoMap['vnp_Url'] ?? '',
      version: '2.1.0',
      tmnCode: tmnCode,
      txnRef: DateTime.now().millisecondsSinceEpoch.toString(),
      orderInfo: 'Payment for booking ${bookingType} - Account: $accountId',
      amount: totalPrice.toDouble(),
      returnUrl: vnpayIntegratedInfoMap['vnp_ReturnUrl'] ?? '',
      ipAdress: ipAddress,
      vnpayHashKey: vnpayIntegratedInfoMap['vnp_HashSecret'] ?? '',
      vnPayHashType: VNPayHashType.HMACSHA512,
    );
    print('[VNPAY] Payment url: $paymentUrl');
    return true;
  }

  Future<String> _getPublicIpAddress() async {
    try {
      final response =
          await http.get(Uri.parse('https://api64.ipify.org/?format=text'));
      if (response.statusCode == 200) {
        return response.body;
      } else {
        return 'Error getting public IP';
      }
    } catch (e) {
      return 'Unknown IP';
    }
  }

  Future<void> openVNPaySDK() async {
    try {
      // Set up method call handler for payment result
      platform.setMethodCallHandler(_handlePaymentResult);

      print(
          "[VNPAY] start invokeMethod openSdk: ${DateTime.now().millisecondsSinceEpoch}");
      // Open VNPay SDK
      await platform.invokeMethod('openSDK', {
        "isSandbox": true,
        'url': paymentUrl,
        'tmnCode': tmnCode,
        'scheme': 'diabvnpay',
      });
    } on PlatformException catch (e) {
      print("[VNPAY] Error opening SDK: ${e.message}");
      _handlePaymentFailed(params: {
        'vnp_ResponseCode': '99',
        'error': 'Failed to open payment: ${e.message}',
      });
    }
  }

  Future<dynamic> _handlePaymentResult(MethodCall call) async {
    print(
        "[VNPAY] handlePyamentResult callback: ${DateTime.now().millisecondsSinceEpoch}");
    if (call.method == 'PaymentBack') {
      try {
        

        final String action = call.arguments['action'] ?? '';
        final int resultCode = call.arguments['resultCode'] ?? -1;
        final String responseCode = call.arguments['vnp_ResponseCode'] ?? '99';

        print(
            "[VNPAY] Payment result: action=$action, resultCode=$resultCode, responseCode=$responseCode");

        // Extract transaction details if available
        Map<String, dynamic> transactionDetails = {};

        // Copy all vnp_ prefixed parameters to transaction details
        call.arguments.forEach((key, value) {
          if (key.toString().startsWith('vnp_')) {
            transactionDetails[key] = value;
          }
        });

        if (resultCode == 0 || responseCode == '00') {
          // Payment successful
          await _handleCreateBookingClinic(params: {
            'vnp_ResponseCode': responseCode,
            ...transactionDetails,
          });
        } else if (resultCode == 10) {
          // User selected mobile banking app, waiting for return
          // Remove overlay as we're waiting for user to return from banking app
        } else if (resultCode == 24) {
          // Payment canceled
          await _handlePaymentFailed(params: {
            'vnp_ResponseCode': responseCode,
            'error': 'Payment canceled',
            ...transactionDetails,
          });
        } else {
          // Payment failed
          await _handlePaymentFailed(params: {
            'vnp_ResponseCode': responseCode,
            ...transactionDetails,
          });
        }
      } catch (e) {
        print("[VNPAY] Error handling payment result: $e");
        BotToast.closeAllLoading();
      }
    }
    return null;
  }

  Future<void> _handleCreateBookingClinic(
      {required Map<String, dynamic> params}) async {
    DsmesAppointment? resp;

    String paymentMethod = params['vnp_CardType'] ?? '';
    String paymentDate = params['vnp_PayDate'] ??
        ''; // Format 20250219150205 -> 2025/02/19 15:02:05

    final selectedServices =
        cubit.createDsmesBookingRequest?.paymentInfo?.services ?? [];

    cubit.updateCreateDsmesBookingRequestServiceList(
        paymentType: paymentMethod.isEmpty
            ? null
            : "vnpay_${paymentMethod.toLowerCase()}",
        selectedServices: selectedServices);

    resp = await cubit.createDsmesBookingOnline();

    if (resp == null) return;

    // Parse the payment date from VNPAY format
    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse('${paymentDate.substring(0, 4)}-' // year
          '${paymentDate.substring(4, 6)}-' // month
          '${paymentDate.substring(6, 8)} ' // day
          '${paymentDate.substring(8, 10)}:' // hour
          '${paymentDate.substring(10, 12)}:' // minute
          '${paymentDate.substring(12, 14)}' // second
          );
    } catch (e) {
      parsedDate = DateTime.now();
    }

    final payTime = DateFormat('HH:mm').format(parsedDate);
    final payDate = DateFormat('dd/MM/yyyy').format(parsedDate);

    // Close any loading indicators before showing the success dialog
    BotToast.closeAllLoading();

    print(
        "[VNPAY] showSuccessDialog: ${DateTime.now().millisecondsSinceEpoch}");
    _showSuccessDialog(
      title2: R.string.payment_success.tr(),
      title: Utils.formatMoney(totalPrice) ?? '',
      subtitle: R.string.payment_success_content.tr(namedArgs: {
        'price': Utils.formatMoney(totalPrice) ?? '',
        'time': payTime,
        'date': payDate,
      }),
      appointmentId: resp.id,
    );
  }

  Future<void> _handlePaymentFailed(
      {required Map<String, dynamic> params}) async {
    String errorMessage = VnpayResponseCode.getResponseCodeMessage(
        params['vnp_ResponseCode'] ?? '');

    // Close any loading indicators before showing the failure dialog
    BotToast.closeAllLoading();

    print(
        "[VNPAY] _showFailureDialog: ${DateTime.now().millisecondsSinceEpoch}");
        
    _showFailureDialog(
      title2: R.string.payment_failed.tr(),
      title: Utils.formatMoney(totalPrice) ?? '',
      subtitle: errorMessage,
    );
  }

  void _showSuccessDialog({
    required String title2,
    required String title,
    required String subtitle,
    required int appointmentId,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return WillPopScope(
          onWillPop: () async {
            Navigator.pop(dialogContext);
            _navigateToBookingDetail(appointmentId);
            return false;
          },
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            insetPadding: EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(dialogContext);
                          _navigateToBookingDetail(appointmentId);
                        },
                        child: Icon(
                          Icons.close,
                          color: R.color.textDark,
                          size: 24,
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 16),
                  Image.asset(R.drawable.ic_dialog_success,
                      width: 43, height: 43),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 14.0),
                        child: Text(
                          title2,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: R.color.color0xff636A6B,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          title,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: R.color.greenGradientBottom,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      subtitle,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: R.color.color0xff777E90,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(dialogContext);
                            _navigateToBookingDetail(appointmentId);
                          },
                          child: Container(
                            height: 43,
                            margin: EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: R.color.white,
                              borderRadius: BorderRadius.circular(200),
                              border: Border.all(
                                color: R.color.greenGradientBottom,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                R.string.recheck_information.tr(),
                                style: TextStyle(
                                  color: R.color.greenGradientBottom,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(dialogContext);
                            _navigateToHome();
                          },
                          child: Container(
                            height: 44,
                            decoration: BoxDecoration(
                              color: R.color.mainColor,
                              borderRadius: BorderRadius.circular(200),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  R.color.greenGradientTop,
                                  R.color.greenGradientMid,
                                  R.color.greenGradientBottom,
                                ],
                              ),
                            ),
                            child: Center(
                              child: Text(
                                R.string.back_home_page.tr(),
                                style: TextStyle(
                                  color: R.color.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showFailureDialog({
    required String title2,
    required String title,
    required String subtitle,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          insetPadding: EdgeInsets.symmetric(horizontal: 12),
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(dialogContext);
                      },
                      child: Icon(
                        Icons.close,
                        color: R.color.textDark,
                        size: 24,
                      ),
                    )
                  ],
                ),
                SizedBox(height: 16),
                Image.asset(R.drawable.ic_dialog_fail, width: 43, height: 43),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 14.0),
                      child: Text(
                        title2,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: R.color.color0xff636A6B,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        title,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: R.color.greenGradientBottom,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    subtitle,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: R.color.color0xff777E90,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(dialogContext);
                          _navigateToHome();
                        },
                        child: Container(
                          height: 43,
                          margin: EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: R.color.white,
                            borderRadius: BorderRadius.circular(200),
                            border: Border.all(
                              color: R.color.greenGradientBottom,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              R.string.back_home_page.tr(),
                              style: TextStyle(
                                color: R.color.greenGradientBottom,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(dialogContext);
                          // Reinitialize payment
                          _retryPayment();
                        },
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: R.color.mainColor,
                            borderRadius: BorderRadius.circular(200),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.centerRight,
                              colors: [
                                R.color.greenGradientTop,
                                R.color.greenGradientMid,
                                R.color.greenGradientBottom,
                              ],
                            ),
                          ),
                          child: Center(
                            child: Text(
                              R.string.repayment.tr(),
                              style: TextStyle(
                                color: R.color.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  void _navigateToHome() {
    Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
      NavigatorName.tabbar,
      (route) => false, // This removes all routes from stack
    );
  }

  Future<void> _navigateToBookingDetail(int appointmentId) async {
    final myAppointment =
        await cubit.getDsmesAppointmentDetail(appointmentId: appointmentId);

    if (myAppointment == null) return;

    DsmesNavigationMixin.getNavigationKey().currentState?.pushNamed(
      NavigatorName.dsmes_booking_detail,
      arguments: {
        'serviceType': serviceType,
        'appointment': myAppointment,
        'bookingType': bookingType,
      },
    );
  }

  Future<void> _retryPayment() async {
    // Reset method handler
    platform.setMethodCallHandler(null);

    // Reinitialize payment
    bool initialized = await initializePayment();
    if (initialized) {
      await openVNPaySDK();
    }
  }

  // Make sure to call this method when done with the payment service
  void dispose() {
    platform.setMethodCallHandler(null);
  }
}
