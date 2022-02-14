/// receipt : "string"
/// packageTransactionId : "string"

class IosReceiptRequest {
  IosReceiptRequest({
      String? receipt,}){
    _receipt = receipt;
}

  IosReceiptRequest.fromJson(dynamic json) {
    _receipt = json['receipt'];
  }
  String? _receipt;

  String? get receipt => _receipt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['receipt'] = _receipt;
    return map;
  }

}