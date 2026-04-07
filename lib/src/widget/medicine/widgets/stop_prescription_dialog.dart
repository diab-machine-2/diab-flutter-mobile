import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../res/R.dart';

class StopPrescriptionDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const StopPrescriptionDialog({
    Key? key,
    required this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  R.string.stop_prescription.tr(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              InkWell(
                onTap: () { Navigator.pop(context); },
                child: Icon(Icons.close, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            R.string.stop_prescription_description.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFAF0000),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 32),
            ),
            onPressed: onConfirm,
            child: const Text(
              "Xác nhận",
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
