import 'dart:collection';

import 'package:meta/meta.dart';

class ShortGuiModel {
  final String content1;
  final String content2;
  final String content3;
  final String content4;

  ShortGuiModel(
      {required this.content1,
      required this.content2,
      required this.content3,
      required this.content4});
  @override
  factory ShortGuiModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> data = json['data'];
    return ShortGuiModel(
        content1: data
                .lastWhere((element) => element['key'] == 'Content_1')
                .values
                .last ??
            '',
        content2: data
                .lastWhere((element) => element['key'] == 'Content_2')
                .values
                .last ??
            '',
        content3: data
                .lastWhere((element) => element['key'] == 'Content_3')
                .values
                .last ??
            '',
        content4: data
                .lastWhere((element) => element['key'] == 'Content_4')
                .values
                .last ??
            '');
  }
}
