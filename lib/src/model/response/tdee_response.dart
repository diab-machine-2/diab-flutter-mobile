import 'meta.dart';

class TDEEResponse {
  TDEEResponse({
      Meta? meta,
    num? data,}){
    _meta = meta;
    _data = data;
}

  TDEEResponse.fromJson(dynamic json) {
    _meta = json['meta'] != null ? Meta.fromJson(json['meta']) : null;
    _data = json['data'];
  }
  Meta? _meta;
  num? _data;

  Meta? get meta => _meta;
  num? get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_meta != null) {
      map['meta'] = _meta?.toJson();
    }
    map['data'] = _data;
    return map;
  }

}

