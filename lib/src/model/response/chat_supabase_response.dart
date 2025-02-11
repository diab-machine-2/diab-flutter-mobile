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

class MessageResponse {
  final String id;
  final String conversationId;
  final String content;
  final String sender;
  final String senderType;
  final dynamic metadata;
  final int createdAt;
  final int updatedAt;
  final dynamic deletedAt;
  final dynamic conversation;

  MessageResponse({
    required this.id,
    required this.conversationId,
    required this.content,
    required this.sender,
    required this.senderType,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.conversation,
  });

  factory MessageResponse.fromJson(Map<String, dynamic> json) {
    return MessageResponse(
      id: json['data']['id'],
      conversationId: json['data']['conversationId'],
      content: json['data']['content'],
      sender: json['data']['sender'],
      senderType: json['data']['senderType'],
      metadata: json['data']['metadata'],
      createdAt: json['data']['createdAt'],
      updatedAt: json['data']['updatedAt'],
      deletedAt: json['data']['deletedAt'],
      conversation: json['data']['conversation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'content': content,
      'sender': sender,
      'senderType': senderType,
      'metadata': metadata,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'deletedAt': deletedAt,
      'conversation': conversation,
    };
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
