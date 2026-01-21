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

class DecimalLimitFormatter extends TextInputFormatter {
  final double maxValue;
  final int decimalDigits;

  DecimalLimitFormatter({this.maxValue = 999, this.decimalDigits = 1});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;

    // Cho phép rỗng
    if (text.isEmpty) return newValue;

    // Cho phép nhập dạng "123.", "0.", ".5"
    if (!RegExp(r'^\d*\.?\d*$').hasMatch(text)) {
      return oldValue;
    }

    // Giới hạn số chữ số thập phân
    if (text.contains('.')) {
      final parts = text.split('.');
      if (parts.length > 2) return oldValue; // nhiều hơn 1 dấu chấm
      if (parts[1].length > decimalDigits) return oldValue; // quá số lẻ cho phép
    }

    // Khi người dùng mới chỉ nhập ".", hoặc "0.", đừng parse
    if (text == '.' || text == '0.') return newValue;

    final value = double.tryParse(text);
    if (value == null) return newValue;

    // Cho phép nhập tối đa tới 999 (chưa vượt ngưỡng)
    if (value > maxValue) return oldValue;

    return newValue;
  }
}
