import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/dsmes_appointment/dsmes_appointment_cubit.dart';
import 'package:vnpay_flutter/vnpay_flutter.dart';

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
  late DsmesAppointmentCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<DsmesAppointmentCubit>();
    // Trigger payment flow automatically when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initiatePayment();
    });
  }

  Future<void> _initiatePayment() async {
    final paymentUrl = VNPAYFlutter.instance.generatePaymentUrl(
      url: 'https://sandbox.vnpayment.vn/paymentv2/vpcpay.html',
      version: '2.0.1',
      tmnCode: 'D3IIRNCX',
      txnRef: DateTime.now().millisecondsSinceEpoch.toString(),
      orderInfo: 'Payment for ${widget.serviceType} - ${widget.bookingType}',
      amount: widget.totalPrice.toDouble(),
      returnUrl: '',
      ipAdress: '192.168.10.10',
      vnpayHashKey: 'S6X6KJBB4IJSJLMBL6CWIAZ4HBTBNKT8',
      vnPayHashType: VNPayHashType.HMACSHA512,
      vnpayExpireDate: DateTime.now().add(const Duration(hours: 1)),
    );

    await VNPAYFlutter.instance.show(
      paymentUrl: paymentUrl,
      onPaymentSuccess: (params) {
        setState(() {
          responseCode = params['vnp_ResponseCode'];
        });
        // Handle successful payment
        Navigator.pop(context, true);
      },
      onPaymentError: (params) {
        setState(() {
          responseCode = 'Error';
        });
        // Handle payment error
        Navigator.pop(context, false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final services = _cubit.createDsmesBookingRequest?.paymentInfo?.services ?? [];
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  ...services.map((e) {
                    final service = _cubit
                        .selectedClinic?.serviceList.categories
                        .expand((category) => category.data)
                        .firstWhere((service) => service.id == e.id);

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              service?.name ?? '',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: R.color.color0xff636A6B,
                              ),
                            ),
                          ),
                          Text(
                            Utils.formatMoney(service?.fromPrice ?? 0) ?? '',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: R.color.color0xff111515,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  Divider(color: R.color.color0xffE6E8EC),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          R.string.total_price.tr(),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: R.color.color0xff636A6B,
                          ),
                        ),
                        Text(
                          Utils.formatMoney(widget.totalPrice) ?? '',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: R.color.color0xff111515,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
