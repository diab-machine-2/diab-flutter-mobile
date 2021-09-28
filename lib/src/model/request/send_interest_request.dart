/// packageId : "3fa85f64-5717-4562-b3fc-2c963f66afa6"
/// type : 1
/// message : "string"

class SendInterestRequest {
  SendInterestRequest({
      String? packageId, 
      int? type, 
      String? message,}){
    _packageId = packageId;
    _type = type;
    _message = message;
}

  SendInterestRequest.fromJson(dynamic json) {
    _packageId = json['packageId'];
    _type = json['type'];
    _message = json['message'];
  }
  String? _packageId;
  int? _type;
  String? _message;

  String? get packageId => _packageId;
  int? get type => _type;
  String? get message => _message;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['packageId'] = _packageId;
    map['type'] = _type;
    map['message'] = _message;
    return map;
  }

}