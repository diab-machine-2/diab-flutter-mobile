// import 'package:flutter_zoom_videosdk/native/zoom_videosdk_chat_message.dart';
// import 'package:flutter_zoom_videosdk/native/zoom_videosdk_user.dart';
// import 'package:linkify/linkify.dart';

// class MeetingMessage {
//   final String content;
//   final MeetingUser? receiverUser;
//   final MeetingUser senderUser;
//   final int timestamp;
//   final bool? isSelfSend;
//   final bool? isChatToAll;
//   final String messageID;
//   late List<LinkifyElement>? elements;

//   bool isFirstMessage = false;
//   bool isEndOfGroup = false;

//   bool get haveLink {
//     if (elements == null) return false;
//     return elements!.any((e) => e is LinkableElement);
//   }

//   MeetingMessage(this.content, this.receiverUser, this.senderUser, this.timestamp, this.isSelfSend,
//       this.isChatToAll, this.messageID) {
//     elements = _linkify(content);
//   }

//   MeetingMessage.fromZoomVideoSdkChatMessage(ZoomVideoSdkChatMessage message)
//       : content = message.content,
//         receiverUser = message.receiverUser == null
//             ? null
//             : MeetingUser.fromZoomVideoSdkUser(message.receiverUser!),
//         senderUser = MeetingUser.fromZoomVideoSdkUser(message.senderUser),
//         timestamp = message.timestamp.toInt() * 1000,
//         isSelfSend = message.isSelfSend,
//         isChatToAll = message.isChatToAll,
//         messageID = message.messageID {
//     elements = _linkify(content);
//   }

//   List<Linkifier> _linkifiers = [EmailLinkifier(), UrlLinkifier(), PhoneNumberLinkifier()];
//   List<LinkifyElement> _linkify(String text) {
//     return linkify(text, options: LinkifyOptions(humanize: true), linkifiers: _linkifiers);
//   }
// }

// class MeetingUser {
//   final String userId;
//   final String userName;

//   bool isHost = false;

//   MeetingUser(this.userId, this.userName, [this.isHost = false]);

//   MeetingUser.fromZoomVideoSdkUser(ZoomVideoSdkUser user)
//       : userId = user.userId,
//         userName = user.userName,
//         isHost = user.isHost ?? false;
// }
