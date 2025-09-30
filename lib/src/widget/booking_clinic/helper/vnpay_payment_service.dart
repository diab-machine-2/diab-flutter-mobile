import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/app_setting/firebase_remote_config.dart';
import 'package:medical/src/model/request/save_vnpay_transaction_request.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/booking_clinic/model/vnpay_model.dart';
import 'package:medical/src/widget/dsmes_appointment/dsmes_appointment_cubit.dart';
import 'package:http/http.dart' as http;
import 'package:medical/src/widget/dsmes_appointment/model/dsmes_appointment_model.dart';
import 'package:medical/src/widget/dsmes_appointment/pages/dsmes_navigation_mixin.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:uuid/uuid.dart';

class VNPayService {
  static const platform = MethodChannel('paymentGateway');

  final BuildContext context;
  final int totalPrice;
  final String bookingType;
  final String serviceType;
  final DsmesAppointmentCubit cubit;

  String tmnCode = '';
  String paymentUrl = '';
  String? currentTxnRef; // Store current transaction reference
  bool isProcessingAppToApp = false; // Flag to track app-to-app payment

  // Enhanced deduplication tracking
  bool hasProcessedFinalResult = false; // Flag to prevent duplicate processing
  String? processedTxnRef; // Track which transaction was already processed
  int? createdAppointmentId; // Store the created appointment ID
  DateTime? lastProcessedTime; // Track when last processed
  static const int duplicateThresholdSeconds = 10; // Time window for duplicates

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
    // Reset all states for new payment
    _resetPaymentStates();

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

    var uuid = Uuid();
    var txnRef = uuid.v4();
    txnRef = txnRef.replaceAll('-', '');
    currentTxnRef = txnRef; // Store the transaction reference

    var orderInfo = 'Payment for booking $bookingType $serviceType';
    paymentUrl = VNPAYFlutter.instance.generatePaymentUrl(
      url: vnpayIntegratedInfoMap['vnp_Url'] ?? '',
      version: '2.1.0',
      tmnCode: tmnCode,
      txnRef: txnRef,
      orderInfo: orderInfo,
      amount: totalPrice.toDouble(),
      returnUrl: vnpayIntegratedInfoMap['vnp_ReturnUrl'] ?? '',
      ipAdress: ipAddress,
      vnpayHashKey: vnpayIntegratedInfoMap['vnp_HashSecret'] ?? '',
      vnPayHashType: VNPayHashType.HMACSHA512,
    );
    print('[VNPAY] Payment url: $paymentUrl');

    final request = VnpayPaymentRequest(
      phoneNumber: AppSettings.userInfo?.phoneNumber ?? '',
      accountId: accountId,
      vnpTmnCode: tmnCode,
      vnpAmount: (totalPrice.toDouble() * 100).toStringAsFixed(0),
      vnpOrderInfo: orderInfo,
      vnpTxnRef: txnRef,
      vnpSecureHash: VNPAYFlutter.instance.vnpSecureHash ?? '',
    );

    final result = await cubit.saveVnpayTransactionInfo(request);

    if (result == false) {
      log('[VNPAY] saveVnpayTransactionInfo failed');
    }
    return true;
  }

  // Reset all payment states
  void _resetPaymentStates() {
    hasProcessedFinalResult = false;
    processedTxnRef = null;
    createdAppointmentId = null;
    isProcessingAppToApp = false;
    lastProcessedTime = null;
    currentTxnRef = null;
  }

  bool _isDuplicateProcessing(String? txnRef, String responseCode,
      {bool isAppToAppReturn = false}) {
    final now = DateTime.now();

    // If no transaction reference, can't determine if duplicate
    if (txnRef == null || txnRef.isEmpty) {
      return false;
    }

    // If we've already processed a successful result for this transaction
    if (hasProcessedFinalResult &&
        processedTxnRef == txnRef &&
        responseCode == '00') {
      print(
          '[VNPAY] Duplicate detected: Already processed successful result for txnRef: $txnRef');
      return true;
    }

    // If we processed the same transaction recently (within threshold)
    if (processedTxnRef == txnRef &&
        lastProcessedTime != null &&
        now.difference(lastProcessedTime!).inSeconds <
            duplicateThresholdSeconds &&
        responseCode == '00') {
      print(
          '[VNPAY] Duplicate detected: Same transaction processed recently for txnRef: $txnRef');
      return true;
    }

    // Don't treat app-to-app returns as duplicates - they should be processed
    if (isAppToAppReturn) {
      return false;
    }

    // Only consider it duplicate if we're in app-to-app mode AND this is a return URL callback with parameters
    if (isProcessingAppToApp &&
        txnRef == currentTxnRef &&
        responseCode == '00') {
      print(
          '[VNPAY] Duplicate detected: Return URL callback during app-to-app processing for txnRef: $txnRef');
      return true;
    }

    return false;
  }

  // Mark transaction as processed
  void _markTransactionProcessed(String txnRef, {int? appointmentId}) {
    hasProcessedFinalResult = true;
    processedTxnRef = txnRef;
    lastProcessedTime = DateTime.now();
    if (appointmentId != null) {
      createdAppointmentId = appointmentId;
    }
    isProcessingAppToApp = false;
    print('[VNPAY] Transaction marked as processed: $txnRef');
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
        "[VNPAY] handlePaymentResult callback: ${DateTime.now().millisecondsSinceEpoch}");
    if (call.method == 'PaymentBack') {
      try {
        final String action = call.arguments['action'] ?? '';
        final int resultCode = call.arguments['resultCode'] ?? -1;
        final String responseCode = call.arguments['vnp_ResponseCode'] ?? '';
        final String txnRef = call.arguments['vnp_TxnRef'] ?? '';

        print(
            "[VNPAY] Payment result: action=$action, resultCode=$resultCode, responseCode=$responseCode, txnRef=$txnRef");

        Map<String, dynamic> transactionDetails = {};

        call.arguments.forEach((key, value) {
          if (key.toString().startsWith('vnp_')) {
            transactionDetails[key] = value;
          }
        });

        // Check for duplicate processing FIRST, but be more specific about when to ignore
        if (responseCode == '00' && txnRef.isNotEmpty) {
          // Only ignore if we've already fully processed this transaction
          if (hasProcessedFinalResult && processedTxnRef == txnRef) {
            print(
                "[VNPAY] Ignoring duplicate: transaction already fully processed");
            return;
          }

          // If this is a return URL callback during app-to-app processing, check if we should ignore it
          if (isProcessingAppToApp && txnRef == currentTxnRef) {
            print(
                "[VNPAY] Return URL callback during app-to-app processing - this will be the actual processor");
            // Reset app-to-app flag since return URL callback will handle it
            isProcessingAppToApp = false;
          }
        }

        // Check if this is app-to-app return without parameters
        if (responseCode.isEmpty &&
            isProcessingAppToApp &&
            currentTxnRef != null) {
          print("[VNPAY] App-to-app return detected, querying payment status");
          await _handleAppToAppReturn();
          return;
        }

        if (resultCode == 0 || responseCode == '00') {
          // Payment successful
          await _handleCreateBookingClinic(params: {
            'vnp_ResponseCode': responseCode,
            'vnp_TxnRef': txnRef,
            ...transactionDetails,
          });
        } else if (resultCode == 10) {
          // User selected mobile banking app, waiting for return
          print("[VNPAY] App-to-app payment initiated");
          isProcessingAppToApp = true;
          await _handleCreateBookingAppToAppPayment(params: {
            'vnp_ResponseCode': responseCode,
            ...transactionDetails,
          });
        } else if (resultCode == 24) {
          // Payment canceled
          await _handlePaymentFailed(params: {
            'vnp_ResponseCode': responseCode,
            'error': 'Payment canceled',
            ...transactionDetails,
          });
        } else if (resultCode == 25) {
          // User returned from external app (like Play Store)
          print("[VNPAY] User returned from external app");
          await _handleAppResumeFromExternal();
        } else {
          // Payment failed
          await _handlePaymentFailed(params: {
            'vnp_ResponseCode': responseCode,
            ...transactionDetails,
          });
        }
      } catch (e) {
        print("[VNPAY] Error handling payment result: $e");
        Message.showToastMessage(
            context, "Create booking after payment success failed");
        BotToast.closeAllLoading();
      }
    }
    return null;
  }

  // Handle app-to-app return by querying payment status from DB
  Future<void> _handleAppToAppReturn() async {
    try {
      print("[VNPAY] Querying payment status for txnRef: $currentTxnRef");

      // Check if already processed
      if (hasProcessedFinalResult && processedTxnRef == currentTxnRef) {
        print(
            "[VNPAY] Transaction already processed, skipping app-to-app return");
        return;
      }

      // Show loading
      BotToast.showLoading();

      // Waiting server to update payment info into DB from IPN URL
      await Future.delayed(const Duration(seconds: 3));

      print("[VNPAY] Starting API call to getPaymentVnpayTransactionInfo");

      // Query payment status from your database using currentTxnRef
      final paymentStatus =
          await cubit.getPaymentVnpayTransactionInfo(txnRef: currentTxnRef!);

      print('[VNPAY] API call completed');
      log('[VNPAY] getPaymentVnpayTransactionInfo result: ${paymentStatus.toString()}');

      if (paymentStatus != null) {
        print('[VNPAY] Payment status found: ${paymentStatus.vnpResponseCode}');

        // Payment status found in DB, process accordingly
        if (paymentStatus.vnpResponseCode == '00') {
          print("[VNPAY] Processing successful payment from app-to-app return");
          // Payment successful - mark this as an app-to-app return processing
          var params = paymentStatus.toJsonFormatted();
          params['_isAppToAppReturn'] =
              true; // Add flag to indicate this is from app-to-app return
          await _handleCreateBookingClinic(params: params);
        } else {
          print("[VNPAY] Processing failed payment from app-to-app return");
          // Payment failed
          await _handlePaymentFailed(params: paymentStatus.toJsonFormatted());
        }
      } else {
        print("[VNPAY] Payment status not found in database yet");
        // Payment status not found yet, close loading and let the return URL callback handle it
        BotToast.closeAllLoading();

        // Wait a bit longer and try one more time
        print("[VNPAY] Waiting additional time for payment status update");
        await Future.delayed(const Duration(seconds: 2));

        final retryPaymentStatus =
            await cubit.getPaymentVnpayTransactionInfo(txnRef: currentTxnRef!);

        if (retryPaymentStatus != null) {
          print(
              '[VNPAY] Payment status found on retry: ${retryPaymentStatus.vnpResponseCode}');

          if (retryPaymentStatus.vnpResponseCode == '00') {
            print(
                "[VNPAY] Processing successful payment from app-to-app return (retry)");
            // Show loading again for processing
            BotToast.showLoading();
            var params = retryPaymentStatus.toJsonFormatted();
            params['_isAppToAppReturn'] =
                true; // Add flag to indicate this is from app-to-app return
            await _handleCreateBookingClinic(params: params);
          } else {
            print(
                "[VNPAY] Processing failed payment from app-to-app return (retry)");
            await _handlePaymentFailed(
                params: retryPaymentStatus.toJsonFormatted());
          }
        } else {
          print(
              "[VNPAY] Payment status still not found, will rely on return URL callback");
          // Keep app-to-app processing flag true so return URL callback can handle it
          return;
        }
      }
    } catch (e) {
      print("[VNPAY] Error querying payment status: $e");
      print("[VNPAY] Exception details: ${e.toString()}");
      BotToast.closeAllLoading();

      // Don't fail immediately, let the return URL callback handle it
      print("[VNPAY] Will rely on return URL callback due to query error");
      return;
    } finally {
      // Only reset app-to-app processing state if we successfully processed or failed
      // If we're relying on return URL callback, keep the flag
      print("[VNPAY] App-to-app return handling completed");
    }
  }

  Future<void> _handleCreateBookingClinic(
      {required Map<String, dynamic> params}) async {
    String txnRef = params['vnp_TxnRef'] ?? '';
    String responseCode = params['vnp_ResponseCode'] ?? '';
    bool isFromAppToAppReturn = params['_isAppToAppReturn'] == true;

    print(
        "[VNPAY] _handleCreateBookingClinic called - txnRef: $txnRef, responseCode: $responseCode, isFromAppToAppReturn: $isFromAppToAppReturn");

    // Final check for duplicate processing before creating booking
    // Skip duplicate check if this is from app-to-app return
    if (!isFromAppToAppReturn &&
        _isDuplicateProcessing(txnRef, responseCode, isAppToAppReturn: false)) {
      print(
          "[VNPAY] Booking creation skipped due to duplicate processing for txnRef: $txnRef");
      return;
    }

    // If we already have an appointment created for this transaction, reuse it
    if (createdAppointmentId != null && processedTxnRef == txnRef) {
      print(
          "[VNPAY] Reusing existing appointment: $createdAppointmentId for txnRef: $txnRef");
      _showExistingSuccessDialog(createdAppointmentId!);
      return;
    }

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

    if (resp == null) {
      print("[VNPAY] Failed to create booking");
      return;
    }

    // Mark as processed immediately after successful booking creation
    _markTransactionProcessed(txnRef, appointmentId: resp.id);

    final result = await cubit.updateVnpayTransactionInfo(
        appointmentId: resp.id, txnRef: params['vnp_TxnRef']);

    if (result == false) {
      log('[VNPAY] updateVnpayTransactionInfo failed');
    }

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

  // Show success dialog for already created appointment
  void _showExistingSuccessDialog(int appointmentId) {
    // Close any loading indicators
    BotToast.closeAllLoading();

    // Navigate directly to booking detail without showing dialog again
    print("[VNPAY] Navigating to existing appointment: $appointmentId");
    _navigateToBookingDetail(appointmentId);
  }

  Future<void> _handleCreateBookingAppToAppPayment(
      {required Map<String, dynamic> params}) async {
    // For app-to-app payment, we just wait for the return
    // The actual booking creation will happen in _handleAppToAppReturn
    print("[VNPAY] App-to-app payment initiated, waiting for return");

    // Show loading indicator while waiting for app-to-app return
    BotToast.showLoading();
  }

  Future<void> _handleAppResumeFromExternal() async {
    print("[VNPAY] Handling app resume from external app");

    // Close any loading indicators
    BotToast.closeAllLoading();

    // Reset app-to-app processing flag
    isProcessingAppToApp = false;
  }

  Future<void> _handlePaymentFailed(
      {required Map<String, dynamic> params}) async {
    log("[VNPAY] _handlePaymentFailed: $params");
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

    // Reset states for failed payments
    _resetPaymentStates();
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

    // Reset all states
    _resetPaymentStates();

    // Reinitialize payment
    bool initialized = await initializePayment();
    if (initialized) {
      await openVNPaySDK();
    }
  }

  // Make sure to call this method when done with the payment service
  void dispose() {
    platform.setMethodCallHandler(null);
    _resetPaymentStates();
  }
}
