class MakeQuestionRequest {
  String? body;
  String? lessonModuleId;
  String? accountId;

  MakeQuestionRequest({
    this.body,
    this.lessonModuleId,
    this.accountId,
  });
  MakeQuestionRequest.fromJson(Map<String, dynamic> json) {
    body = json['body']?.toString();
    lessonModuleId = json['lessonModuleId']?.toString();
    accountId = json['accountId']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['body'] = body;
    data['lessonModuleId'] = lessonModuleId;
    data['accountId'] = accountId;
    return data;
  }
}
