import 'package:flutter/material.dart';

class BloodPressureWarningPopupWidget extends StatefulWidget {
  const BloodPressureWarningPopupWidget({super.key});

  @override
  State<BloodPressureWarningPopupWidget> createState() => _BloodPressureWarningPopupWidgetState();
}

class _BloodPressureWarningPopupWidgetState extends State<BloodPressureWarningPopupWidget> {
  BloodPressureWarningPopupStep _step = BloodPressureWarningPopupStep.warning;

  void _inputtedReason() {
    setState(() {
      _step = BloodPressureWarningPopupStep.confirm;
    });
  }

  void _cancel() {
    Navigator.of(context).pop();
  }

  void _confirm() {
    // TODO: call api
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/warning.png', // Make sure this asset exists
            width: 40,
            height: 40,
          ),
          const SizedBox(height: 16),
          Text(
            'Warning',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Blood Pressure Alert',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please select the reason below:',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 16),
          if (_step == BloodPressureWarningPopupStep.warning) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                FilterChip(
                  label: const Text('Reason 1'),
                  selected: false,
                  onSelected: (bool selected) {
                    // Handle selection
                  },
                ),
                FilterChip(
                  label: const Text('Reason 2'),
                  selected: false,
                  onSelected: (bool selected) {
                    // Handle selection
                  },
                ),
                FilterChip(
                  label: const Text('Reason 3'),
                  selected: false,
                  onSelected: (bool selected) {
                    // Handle selection
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: const StadiumBorder(),
                    ),
                    onPressed: _cancel,
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: const StadiumBorder(),
                    ),
                    onPressed: _inputtedReason,
                    child: const Text('Confirm'),
                  ),
                ),
              ],
            ),
          ],
          if (_step == BloodPressureWarningPopupStep.confirm) ...[
            Column(
              children: [
                const Text(
                  'Bạn đã xác nhận lý do này. Cảm ơn bạn!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _confirm,
                  child: const Text('Toi da hieu'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 48), // Full width button
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

enum BloodPressureWarningPopupStep {
  warning,
  confirm,
}
