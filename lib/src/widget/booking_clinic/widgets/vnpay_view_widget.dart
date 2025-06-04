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
    final String action = arguments['action'] ?? '';
    final int resultCode = arguments['resultCode'] ?? -1;
    final String responseCode = arguments['vnp_ResponseCode'] ?? '99';

    print("[VNPAY] Payment result: action=$action, resultCode=$resultCode, responseCode=$responseCode");

    // Extract transaction details if available
    Map<String, dynamic> transactionDetails = {};
    
    // Copy all vnp_ prefixed parameters to transaction details
    arguments.forEach((key, value) {
      if (key.startsWith('vnp_')) {
        transactionDetails[key] = value;
      }
    });

    if (resultCode == 0 || responseCode == '00') {
      // Payment successful
      widget.onPaymentSuccess?.call({
        'vnp_ResponseCode': responseCode,
        ...transactionDetails,
      });
    } else if (resultCode == 10) {
      // User selected mobile banking app, waiting for return
      // No dialog here as we're waiting for the user to return from the banking app
    } else if (resultCode == 24) {
      // Payment canceled
      widget.onPaymentError?.call({
        'vnp_ResponseCode': responseCode,
        'error': 'Payment canceled',
        ...transactionDetails,
      });
    } else {
      // Payment failed
      widget.onPaymentError?.call({
        'vnp_ResponseCode': responseCode,
        ...transactionDetails,
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
        'scheme': 'diabvnpay',
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
            ? SizedBox.shrink()
            : Text('Processing payment via VNPAY...'),
      ),
    );
  }
}
