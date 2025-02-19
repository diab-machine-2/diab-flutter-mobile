class SupabaseConfigResponse {
  final String supabaseUrl;
  final String supabaseKey;

  SupabaseConfigResponse({
    required this.supabaseUrl,
    required this.supabaseKey,
  });

  factory SupabaseConfigResponse.fromJson(Map<String, dynamic> json) {
    return SupabaseConfigResponse(
      supabaseUrl: json['data']['Endpoint'],
      supabaseKey: json['data']['Key'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'supabaseUrl': supabaseUrl,
      'supabaseKey': supabaseKey,
    };
  }
}

class MessageModel {
  final String id;
  final String conversationId;
  final String content;
  final String sender;
  final String senderType;
  final int createdAt;
  int? updatedAt;
  int? deletedAt;
  // ConversationModel? conversation;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.content,
    required this.sender,
    required this.senderType,
    required this.createdAt,
    this.updatedAt,
    this.deletedAt,
    // this.conversation,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      conversationId: json['conversationId'],
      content: json['content'],
      sender: json['sender'],
      senderType: json['senderType'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      deletedAt: json['deletedAt'],
      // conversation: json['data']['conversation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id ?? '',
      'conversationId': conversationId ?? '',
      'content': content ?? '',
      'sender': sender ?? '',
      'senderType': senderType ?? '',
      'createdAt': createdAt ?? '',
      'updatedAt': updatedAt ?? '',
      'deletedAt': deletedAt ?? '',
      // 'conversation': conversation,
    };
  }
}

class MessageResponse {
  final BaseResponseMeta? meta;
  final MessageModel? data;

  MessageResponse({required this.meta, required this.data});

  MessageResponse.fromJson(Map<String, dynamic> json)
      : meta = (json['meta'] != null)
            ? BaseResponseMeta.fromJson(json['meta'])
            : null,
        data =
            (json['data'] != null) ? MessageModel.fromJson(json['data']) : null;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (meta != null) {
      map['meta'] = meta!.toJson();
    }
    if (data != null) {
      map['data'] = data!.toJson();
    }
    return map;
  }
}

class MessageGennerateResponse {
  final String messageId;
  final String questionMessageId;
  MessageGennerateResponse({
    required this.messageId,
    required this.questionMessageId,
  });

  factory MessageGennerateResponse.fromJson(Map<String, dynamic> json) {
    return MessageGennerateResponse(
      messageId: json['data']['messageId'],
      questionMessageId: json['data']['questionMessageId'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'questionMessageId': questionMessageId,
    };
  }
}

class CreateConversationRequest {
  final String title;
  final String descrtiption;

  CreateConversationRequest({
    required this.title,
    required this.descrtiption,
  });
  factory CreateConversationRequest.fromJson(Map<String, dynamic> json) {
    return CreateConversationRequest(
      title: json['title'],
      descrtiption: json['descrtiption'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'descrtiption': descrtiption,
    };
  }
}

class MemberModel {
  final String id;
  final String conversationId;
  final String userId;
  final String role;
  final int joinedAt;
  final int? leftAt;
  final int createdAt;
  final int updatedAt;

  MemberModel({
    required this.id,
    required this.conversationId,
    required this.userId,
    required this.role,
    required this.joinedAt,
    required this.leftAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      id: json['id'],
      conversationId: json['conversationId'],
      userId: json['userId'],
      role: json['role'],
      joinedAt: json['joinedAt'],
      leftAt: json['leftAt'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'userId': userId,
      'role': role,
      'joinedAt': joinedAt,
      'leftAt': leftAt,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class ConversationModel {
  final String id;
  final String? title;
  final String? descrtiption;
  final int? createdAt;
  final int? updatedAt;
  final int? deletedAt;
  final List<MessageModel>? messages;
  final List<MemberModel>? members;

  ConversationModel(
      {required this.id,
      this.title,
      this.descrtiption,
      this.createdAt,
      this.updatedAt,
      this.deletedAt,
      this.messages,
      this.members});

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'] ?? json['data'],
      title: json['title'],
      descrtiption: json['descrtiption'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      deletedAt: json['deletedAt'],
      messages: json['messages'] != null
          ? List<MessageModel>.from(
              json['messages'].map((x) => MessageModel.fromJson(x)))
          : null,
      members: json['members'] != null
          ? List<MemberModel>.from(
              json['members'].map((x) => MemberModel.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'descrtiption': descrtiption,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'deletedAt': deletedAt,
      'messages': messages != null
          ? List<dynamic>.from(messages!.map((x) => x.toJson()))
          : null,
      'members': members != null
          ? List<dynamic>.from(members!.map((x) => x.toJson()))
          : null,
    };
  }

  bool get isEmpty => id.isEmpty;
}

class ConversationResponse {
  BaseResponseMeta? meta;
  ConversationModel? data;

  ConversationResponse({required this.meta, required this.data});

  ConversationResponse.fromJson(Map<String, dynamic> json) {
    meta =
        (json['meta'] != null) ? BaseResponseMeta.fromJson(json['meta']) : null;
    if (json['data'] != null) {
      data = ConversationModel.fromJson(json['data']);
    }
  }
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (meta != null) {
      map['meta'] = meta!.toJson();
    }
    if (data != null) {
      map['data'] = data!.toJson();
    }
    return map;
  }
}

class BaseResponseMeta {
  bool? success;

  BaseResponseMeta({this.success});
  BaseResponseMeta.fromJson(Map<String, dynamic> json) {
    success = json['success'];
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['success'] = success;
    return data;
  }
}

class ConversationListResponseMeta extends BaseResponseMeta {
  int? total;
  int? pageCount;
  int? page;
  int? size;
  bool? canNext;
  bool? canPrev;

  ConversationListResponseMeta({
    this.total,
    this.pageCount,
    this.page,
    this.size,
    this.canNext,
    this.canPrev,
  }) {
    success = false;
  }
  @override
  ConversationListResponseMeta.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    total = json['total'];
    pageCount = json['pageCount'];
    page = json['page'];
    size = json['size'];
    canNext = json['canNext'];
    canPrev = json['canPrev'];
  }
  @override
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['success'] = success;
    data['total'] = total;
    data['pageCount'] = pageCount;
    data['page'] = page;
    data['size'] = size;
    data['canNext'] = canNext;
    data['canPrev'] = canPrev;
    return data;
  }
}

class ConversationListResponse {
  ConversationListResponseMeta? meta;
  List<ConversationModel>? data;

  ConversationListResponse({
    this.meta,
    this.data,
  });
  ConversationListResponse.fromJson(Map<String, dynamic> json) {
    meta = (json['meta'] != null)
        ? ConversationListResponseMeta.fromJson(json['meta'])
        : null;
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(ConversationModel.fromJson(v));
      });
    }
  }
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (meta != null) {
      map['meta'] = meta!.toJson();
    }
    if (data != null) {
      map['data'] = data!.map((v) => v.toJson()).toList();
    }
    return map;
  }
}
