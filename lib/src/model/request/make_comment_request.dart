class MakeCommentRequest {
  String? body;
  String? questionId;
  String? accountId;

  MakeCommentRequest({
    this.body,
    this.questionId,
    this.accountId,
  });

  MakeCommentRequest.fromJson(Map<String, dynamic> json) {
    body = json['body']?.toString();
    questionId = json['questionId']?.toString();
    accountId = json['accountId']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['body'] = body;
    data['questionId'] = questionId;
    data['accountId'] = accountId;
    return data;
  }
}
