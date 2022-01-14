import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRScanWidget extends StatefulWidget {
  const QRScanWidget({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _QRScanWidgetState();
}

class _QRScanWidgetState extends State<QRScanWidget> {
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late final StreamSubscription<Barcode> subcription;

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    controller?.dispose();
    _stopTimer();
    super.dispose();
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  void _startTimer() {
    _stopTimer();
    _timer = Timer(const Duration(minutes: 1), () {
      Message.showToastMessage(context, R.string.qr_code_not_found.tr());
    });
  }

  _stopTimer() {
    if (_timer?.isActive == true) {
      _timer?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildQrView(context),
          Positioned(
            top: MediaQuery.of(context).padding.top,
            right: 16,
            child: IconButton(
              onPressed: () {
                NavigationUtil.pop(context);
              },
              icon: const Icon(
                Icons.close_rounded,
              ),
              color: R.color.white,
              iconSize: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    final double scanArea =
        (MediaQuery.of(context).size.width < 400 || MediaQuery.of(context).size.height < 400) ? 250.0 : 400.0;

    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.white, borderRadius: 10, borderLength: 30, borderWidth: 10, cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    subcription = controller.scannedDataStream.listen((scanData) {
      if (scanData.code?.isNotEmpty == true) {
        checkValidLink(scanData.code!);
      }
    });
  }

  Future<void> checkValidLink(String scanedText) async {
    subcription.pause();
    if (scanedText.contains('https://diab-portal-dev.savvycom.vn')) {
      subcription.cancel();
      Navigator.pop(context, scanedText.substring(scanedText.length - 6, scanedText.length));
    }
    subcription.resume();
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      Message.showToastMessage(context, R.string.error_can_not_access_camera.tr());
    }
  }
}
