import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/widget/booking_clinic/helper/vnpay_model.dart';
import 'package:medical/src/widget/booking_clinic/widgets/vnpay_view_widget.dart';
import 'package:medical/src/widget/dsmes_appointment/dsmes_appointment_cubit.dart';

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

  @override
  void initState() {
    super.initState();
    _cubit = context.read<DsmesAppointmentCubit>();

    _initiatePayment();
  }

  Future<void> _initiatePayment() async {
    paymentUrl = VNPAYFlutter.instance.generatePaymentUrl(
      url: 'https://sandbox.vnpayment.vn/paymentv2/vpcpay.html',
      version: '2.1.0',
      tmnCode: 'D3IIRNCX',
      txnRef: DateTime.now().millisecondsSinceEpoch.toString(),
      orderInfo: 'Payment for ${widget.serviceType} - ${widget.bookingType}',
      amount: widget.totalPrice.toDouble(),
      returnUrl: 'xxxxx',
      ipAdress: '192.168.10.10',
      vnpayHashKey: 'S6X6KJBB4IJSJLMBL6CWIAZ4HBTBNKT8',
      vnPayHashType: VNPayHashType.HMACSHA512,
    );
    print('[VNPAY] Payment url: $paymentUrl');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                child: Column(
                  children: [
                    VNPayView(
                      paymentUrl: paymentUrl,
                      onPaymentSuccess: (params) {
                        print("[VNPAY] Payment success: $params");
                        setState(() {
                          responseCode = params['vnp_ResponseCode'];
                        });
                      },
                      onPaymentError: (params) {
                        print("[VNPAY] Payment error: $params");
                        setState(() {
                          responseCode = 'Error';
                        });
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
}
