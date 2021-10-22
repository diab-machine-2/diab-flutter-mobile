/// lessonId : "string"
/// rating : 1
/// note : "string"

class SendFeedbackCourseRequest {
  SendFeedbackCourseRequest({
      String? lessonId, 
      double? rating, 
      String? note,}){
    _lessonId = lessonId;
    _rating = rating;
    _note = note;
}

  SendFeedbackCourseRequest.fromJson(dynamic json) {
    _lessonId = json['lessonId'];
    _rating = json['rating'];
    _note = json['note'];
  }
  String? _lessonId;
  double? _rating;
  String? _note;

  String? get lessonId => _lessonId;
  double? get rating => _rating;
  String? get note => _note;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['lessonId'] = _lessonId;
    map['rating'] = _rating;
    map['note'] = _note;
    return map;
  }

}