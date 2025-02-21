import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import '../../../res/R.dart';

class Conversation {
  final String id;
  final String title;
  final String? description;
  final String status;
  final DateTime createdAt;
  types.Room? uiRoom;

  Conversation({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    required this.createdAt,
    this.uiRoom,
  }) {
    uiRoom = this.uiRoom ??
        types.Room(
          id: id,
          type: types.RoomType.direct,
          imageUrl: Image.asset(R.drawable.chat_avatar_chatbot_ai).toString(),
          name: title,
          users: [],
        );
  }

  factory Conversation.fromMap(Map<String, dynamic> map) {
    return Conversation(
      id: map['id'],
      title: map['title'] ?? R.string.conversation_mockup_title.tr(),
      description:
          map['description'] ?? R.string.conversation_mockup_description.tr(),
      status: map['status'] ?? 'active',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
      uiRoom: types.Room(
        id: map['id'],
        type: types.RoomType.direct,
        imageUrl: Image.asset(R.drawable.chat_avatar_chatbot_ai).toString(),
        name: map['title'] ?? R.string.conversation_mockup_title.tr(),
        users: [],
        metadata: map,
      ),
    );
  }
}

class Message {
  final String id;
  final String conversationId;
  final String content;
  final String sender;
  final String senderType;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;
  types.Message? uiMessage;

  Message({
    required this.id,
    required this.conversationId,
    required this.content,
    required this.sender,
    required this.senderType,
    required this.createdAt,
    this.uiMessage,
    this.metadata,
  }) {
    uiMessage = this.uiMessage ??
        types.TextMessage(
          id: id,
          author: types.User(id: sender),
          text: content,
        );
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
        id: map['id'],
        conversationId: map['conversation_id'] ?? '',
        content: map['content'] ?? '',
        sender: map['sender'] ?? '',
        senderType: map['sender_type'] ?? '',
        createdAt: map['created_at'] != null
            ? DateTime.parse(map['created_at'])
            : DateTime.now(),
        metadata: map['metadata'],
        uiMessage: types.TextMessage(
          id: map['id'],
          author: types.User(
              id: map['sender'] ?? '',
              lastName: map['sender'] ?? '',
              firstName: map['sender']),
          text: map['content'] ?? '',
          createdAt: map['created_at'] != null
              ? DateTime.parse(map['created_at']).millisecondsSinceEpoch
              : DateTime.now().millisecondsSinceEpoch,
          roomId: map['conversation_id'],
          metadata: map,
        ));
  }
}
