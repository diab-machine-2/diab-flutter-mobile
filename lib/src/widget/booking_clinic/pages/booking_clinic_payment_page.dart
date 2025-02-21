import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/booking_clinic/model/vnpay_model.dart';
import 'package:medical/src/widget/booking_clinic/widgets/vnpay_view_widget.dart';
import 'package:medical/src/widget/dsmes_appointment/dsmes_appointment_cubit.dart';
import 'package:http/http.dart' as http;
import 'package:medical/src/widget/dsmes_appointment/model/dsmes_appointment_model.dart';
import 'package:medical/src/widget/dsmes_appointment/pages/dsmes_navigation_mixin.dart';
import 'package:medical/src/widgets/gap_widget.dart';

class BookingClinicPaymentPage extends StatefulWidget {
  final int totalPrice;
  final String bookingType;
  final String serviceType;

  const BookingClinicPaymentPage({
    Key? key,
    required this.totalPrice,
    required this.bookingType,
    required this.serviceType,
  }) : super(key: key);

  @override
  State<BookingClinicPaymentPage> createState() =>
      _BookingClinicPaymentPageState();
}

class _BookingClinicPaymentPageState extends State<BookingClinicPaymentPage> {
  String responseCode = '';
  String paymentUrl = '';
  late DsmesAppointmentCubit _cubit;

  bool isLoading = true;
  Map<String, bool> isProcessing = {
    'recheckInfo': false,
    'backHome': false,
    'repay': false,
  };

  @override
  void initState() {
    super.initState();
    _cubit = context.read<DsmesAppointmentCubit>();

    _initiatePayment();
  }

  Future<void> _initiatePayment() async {
    final ipAddress = await _getPublicIpAddress();
    final accountId = AppSettings.userInfo?.accountId ?? '';
    paymentUrl = VNPAYFlutter.instance.generatePaymentUrl(
      url: 'https://sandbox.vnpayment.vn/paymentv2/vpcpay.html',
      version: '2.1.0',
      tmnCode: 'D3IIRNCX',
      txnRef: DateTime.now().millisecondsSinceEpoch.toString(),
      orderInfo:
          'Payment for booking ${widget.bookingType} - Account: $accountId',
      amount: widget.totalPrice.toDouble(),
      returnUrl: 'https://demo.ladipage.diab.vn/success',
      ipAdress: ipAddress,
      vnpayHashKey: 'S6X6KJBB4IJSJLMBL6CWIAZ4HBTBNKT8',
      vnPayHashType: VNPayHashType.HMACSHA512,
    );
    print('[VNPAY] Payment url: $paymentUrl');
    setState(() {
      isLoading = false;
    });
  }

  Future<String> _getPublicIpAddress() async {
    try {
      final response =
          await http.get(Uri.parse('https://api64.ipify.org/?format=text'));
      if (response.statusCode == 200) {
        return response.body; // IP công cộng
      } else {
        return 'Lỗi khi lấy IP công cộng';
      }
    } catch (e) {
      return 'Không thể lấy IP công cộng: $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                child: isLoading
                    ? Center(child: CircularProgressIndicator())
                    : Column(
                        children: [
                          VNPayView(
                            paymentUrl: paymentUrl,
                            onPaymentSuccess: (params) async {
                              print("[VNPAY] Payment success: $params");
                              await _handleCreateBookingClinic(params: params);
                            },
                            onPaymentError: (params) async {
                              print("[VNPAY] Payment error: $params");
                              await _handlePaymentFailed(params: params);
                            },
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleCreateBookingClinic(
      {required Map<String, dynamic> params}) async {
    final BuildContext dialogContext = context;
    DsmesAppointment? resp;

    String paymentMethod = params['vnp_CardType'] ?? '';

    String paymentDate = params['vnp_PayDate'] ??
        ''; // Format 20250219150205 -> 2025/02/19 15:02:05

    final selectedServices =
        _cubit.createDsmesBookingRequest?.paymentInfo?.services ?? [];

    _cubit.updateCreateDsmesBookingRequestServiceList(
        paymentType: paymentMethod.isEmpty
            ? null
            : "vnpay_${paymentMethod.toLowerCase()}",
        selectedServices: selectedServices);

    resp = await _cubit.createDsmesBookingOnline();

    if (!mounted || resp == null) return;

    final DateTime parsedDate =
        DateTime.parse('${paymentDate.substring(0, 4)}-' // year
            '${paymentDate.substring(4, 6)}-' // month
            '${paymentDate.substring(6, 8)} ' // day
            '${paymentDate.substring(8, 10)}:' // hour
            '${paymentDate.substring(10, 12)}:' // minute
            '${paymentDate.substring(12, 14)}' // second
            );

    final payTime = DateFormat('HH:mm').format(parsedDate);
    final payDate = DateFormat('dd/MM/yyyy').format(parsedDate);

    _showPopupBookingSuccess(
      context: dialogContext,
      title2: R.string.payment_success.tr(),
      title: Utils.formatMoney(widget.totalPrice) ?? '',
      subtitle: R.string.payment_success_content.tr(namedArgs: {
        'price': Utils.formatMoney(widget.totalPrice) ?? '',
        'time': payTime,
        'date': payDate,
      }),
      isShowImg: true,
      primaryButtonTitle: R.string.back_home_page.tr(),
      secondaryButtonTitle: R.string.recheck_information.tr(),
      onNavigateHome: () {
        // Back to homepage
        Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
          NavigatorName.tabbar,
          (route) => false, // This removes all routes from stack
        );
      },
      onShowInfo: () async {
        // Navigate to booking detail
        final myAppointment =
            await _cubit.getDsmesAppointmentDetail(appointmentId: resp!.id);

        if (myAppointment == null) return;

        DsmesNavigationMixin.navigationKey.currentState?.pushNamed(
          NavigatorName.dsmes_booking_detail,
          arguments: {
            'serviceType': widget.serviceType,
            'appointment': myAppointment,
            'bookingType': widget.bookingType,
          },
        );
      },
    );
  }

  _showPopupBookingSuccess({
    required BuildContext context,
    required Function onNavigateHome,
    Function? onShowInfo,
    bool isShowImg = false,
    String? subtitle,
    String? title,
    String? title2,
    String primaryButtonTitle = 'Xác nhận',
    String secondaryButtonTitle = 'Huỷ',
    String? icon,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async {
            Navigator.pop(context);
            onShowInfo?.call();
            return false;
          },
          child: Container(
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
                            Navigator.pop(context);
                            onShowInfo?.call();
                          },
                          child: Icon(
                            Icons.close,
                            color: R.color.textDark,
                            size: 24,
                          ),
                        )
                      ],
                    ),
                    GapH(16),
                    if (isShowImg)
                      Image.asset(icon ?? R.drawable.ic_dialog_success,
                          width: 43, height: 43),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (title2 != null)
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
                            title ?? "",
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
                        subtitle ?? "",
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: R.color.color0xff777E90,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    GapH(16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: GestureDetector(
                            onTap: () {
                              if (isProcessing['recheckInfo']!) return;
                              setState(
                                  () => isProcessing['recheckInfo'] = true);
                              try {
                                Navigator.pop(context);
                                onShowInfo?.call();
                              } finally {
                                setState(
                                    () => isProcessing['recheckInfo'] = false);
                              }
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
                                  secondaryButtonTitle,
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
                          child: _buildButton(primaryButtonTitle, () {
                            if (isProcessing['backHome']!) return;
                            setState(() => isProcessing['backHome'] = true);
                            try {
                              onNavigateHome();
                            } finally {
                              setState(() => isProcessing['backHome'] = false);
                            }
                          }),
                        ),
                      ],
                    ),
                    GapH(16),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handlePaymentFailed(
      {required Map<String, dynamic> params}) async {
    final BuildContext dialogContext = context;
    
    String errorMessage = VnpayResponseCode.getResponseCodeMessage(
        params['vnp_ResponseCode'] ?? '');

    _showPopupBookingSuccess(
      context: dialogContext,
      title2: R.string.payment_failed.tr(),
      title: Utils.formatMoney(widget.totalPrice) ?? '',
      subtitle: errorMessage,
      isShowImg: true,
      primaryButtonTitle: R.string.repayment.tr(),
      secondaryButtonTitle: R.string.back_home_page.tr(),
      onNavigateHome: () {
        Navigator.of(context).pop();
      },
      onShowInfo: () async {
        // Back to homepage
        Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
          NavigatorName.tabbar,
          (route) => false, // This removes all routes from stack
        );
      },
      icon: R.drawable.ic_dialog_fail,
    );
  }

  Widget _buildButton(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        // width: 158,
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
            text,
            style: TextStyle(
              color: R.color.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
