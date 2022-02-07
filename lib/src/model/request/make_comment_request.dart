class MakeCommentRequest {
  String? body;
  String? questionId;
  String? accountId;
  bool? isComment;

  MakeCommentRequest({
    this.body,
    this.questionId,
    this.accountId,
    this.isComment,
  });

  MakeCommentRequest.fromJson(Map<String, dynamic> json) {
    body = json['body']?.toString();
    questionId = json['questionId']?.toString();
    accountId = json['accountId']?.toString();
    isComment = json['isComment'];
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['body'] = body;
    data['questionId'] = questionId;
    data['accountId'] = accountId;
    data['isComment'] = isComment;
    return data;
  }
}
