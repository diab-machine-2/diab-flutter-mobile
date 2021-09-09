import 'package:meta/meta.dart';

class CustomerModel {
  final String id;
  final String code;
  final String name;
  final String phone;
  final String address;
  final String avatarLink;

  CustomerModel(
      {@required this.id,
      @required this.code,
      @required this.name,
      @required this.phone,
      @required this.address,
      @required this.avatarLink});
  @override
  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
        id: json['id'],
        code: json['code'],
        name: json['name'],
        phone: json['phone'],
        address: json['address'],
        avatarLink: json['avatarLink']);
  }
}
