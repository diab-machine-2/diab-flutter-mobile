import 'package:meta/meta.dart';

class SecureModel {
  final String email;
  final String support;
  final String hotline;
  final String security;

  SecureModel(
      {@required this.email,
      @required this.support,
      @required this.hotline,
      @required this.security});

  factory SecureModel.fromJson(Map<String, dynamic> json) {
    return SecureModel(
      email: json['DiaB.Information.Contact.Email'],
      support: json['DiaB.Information.Contact.Supporter'],
      hotline: json['DiaB.Information.Contact.Hotline'],
      security: json['DiaB.Information.Security'],
    );
  }

  static List<SecureModel> toList(List<dynamic> items) {
    return items.map((item) => SecureModel.fromJson(item)).toList();
  }
}
