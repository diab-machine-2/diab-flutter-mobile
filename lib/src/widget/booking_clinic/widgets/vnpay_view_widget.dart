import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VNPayView extends StatefulWidget {
  const VNPayView({
    required this.paymentUrl,
    required this.tmnCode,
    super.key,
    this.onPaymentSuccess,
    this.onPaymentError,
  });

  final String paymentUrl;
  final String tmnCode;
  final void Function(Map<String, dynamic> value)? onPaymentSuccess;
  final void Function(Map<String, dynamic> error)? onPaymentError;

  @override
  State<VNPayView> createState() => _VNPayViewState();
}

class _VNPayViewState extends State<VNPayView> {
  static const platform = MethodChannel('paymentGateway');
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    platform.setMethodCallHandler(_handleMethod);
    _openVNPaySDK();
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    if (call.method == 'PaymentBack') {
      _handlePaymentResult(call.arguments);
    }
    return null;
  }

  void _handlePaymentResult(dynamic arguments) {
    final int? resultCode = arguments['resultCode'];

    if (resultCode == 0) {
      // Payment successful
      widget.onPaymentSuccess?.call({
        'vnp_ResponseCode': '00',
      });
    } else if (resultCode == 10) {
      // User selected mobile banking app, waiting for return
    } else {
      // Payment failed or canceled
      widget.onPaymentError?.call({
        'vnp_ResponseCode': resultCode == 24 ? '24' : '99',
        'error': resultCode == 24 ? 'Payment canceled' : 'Payment failed',
      });
    }
  }

  @override
  void dispose() {
    platform.setMethodCallHandler(null);
    super.dispose();
  }

  Future<void> _openVNPaySDK() async {
    try {
      await platform.invokeMethod('openSDK', {
        'url': widget.paymentUrl,
        'tmnCode': widget.tmnCode,
        'scheme': 'vnpflutterapp',
      });
      setState(() {
        isLoading = false;
      });
    } on PlatformException catch (e) {
      print("[VNPAY] Error opening SDK: ${e.message}");
      setState(() {
        isLoading = false;
      });
      widget.onPaymentError?.call({
        'vnp_ResponseCode': '99',
        'error': 'Failed to open payment: ${e.message}',
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : Text('Processing payment via VNPAY...'),
      ),
    );
  }
}
