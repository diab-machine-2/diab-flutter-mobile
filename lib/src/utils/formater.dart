import 'package:flutter/services.dart';

class CommaToDotFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text.replaceAll(',', '.');
    return newValue.copyWith(
      text: newText,
      selection: newValue.selection,
    );
  }
}

class DecimalTextInputFormatter extends TextInputFormatter {
  final int decimalRange;

  DecimalTextInputFormatter({required this.decimalRange})
      : assert(decimalRange >= 0);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;

    // Cho phép rỗng
    if (text.isEmpty) {
      return newValue;
    }

    // Cho phép số nguyên
    if (RegExp(r'^\d+$').hasMatch(text)) {
      return newValue;
    }

    // Cho phép số thập phân với giới hạn chữ số sau dấu chấm
    final regex = RegExp(r'^\d+([.,]\d{0,' + decimalRange.toString() + r'})?$');
    if (regex.hasMatch(text)) {
      return newValue;
    }

    // Nếu không khớp, giữ nguyên giá trị cũ
    return oldValue;
  }
}

