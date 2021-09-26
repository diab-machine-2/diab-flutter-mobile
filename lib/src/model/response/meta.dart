/// success : true
/// total : 0
/// pageCount : 0
/// page : 0
/// size : 0
/// canNext : true
/// canPrev : true

class Meta {
  Meta({
      bool? success, 
      int? total, 
      int? pageCount, 
      int? page, 
      int? size, 
      bool? canNext, 
      bool? canPrev,}){
    _success = success;
    _total = total;
    _pageCount = pageCount;
    _page = page;
    _size = size;
    _canNext = canNext;
    _canPrev = canPrev;
}

  Meta.fromJson(dynamic json) {
    _success = json['success'];
    _total = json['total'];
    _pageCount = json['pageCount'];
    _page = json['page'];
    _size = json['size'];
    _canNext = json['canNext'];
    _canPrev = json['canPrev'];
  }
  bool? _success;
  int? _total;
  int? _pageCount;
  int? _page;
  int? _size;
  bool? _canNext;
  bool? _canPrev;

  bool? get success => _success;
  int? get total => _total;
  int? get pageCount => _pageCount;
  int? get page => _page;
  int? get size => _size;
  bool? get canNext => _canNext;
  bool? get canPrev => _canPrev;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['success'] = _success;
    map['total'] = _total;
    map['pageCount'] = _pageCount;
    map['page'] = _page;
    map['size'] = _size;
    map['canNext'] = _canNext;
    map['canPrev'] = _canPrev;
    return map;
  }

}