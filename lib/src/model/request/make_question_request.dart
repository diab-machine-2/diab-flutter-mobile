class MakeQuestionRequest {
  String? body;
  String? lessonModuleId;
  String? accountId;
  late List<String> pictures;

  MakeQuestionRequest({
    this.body,
    this.lessonModuleId,
    this.accountId,
    required this.pictures,
  });
  MakeQuestionRequest.fromJson(Map<String, dynamic> json) {
    body = json['body']?.toString();
    lessonModuleId = json['lessonModuleId']?.toString();
    accountId = json['accountId']?.toString();
    pictures = List<String>.from(json["pictures"]);
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['body'] = body;
    data['lessonModuleId'] = lessonModuleId;
    data['accountId'] = accountId;
    data['pictures'] = pictures;
    return data;
  }
}
