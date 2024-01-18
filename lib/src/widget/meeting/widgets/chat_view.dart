import 'package:flutter/material.dart';
import 'package:flutter_zoom_videosdk/native/zoom_videosdk_chat_message.dart';

class ChatView extends StatelessWidget {
  final Function(String) onSendMessage;
  final ScrollController scrollController;
  final TextEditingController textEditingController;
  final ValueNotifier<List<ZoomVideoSdkChatMessage>> messagesValueNotifier;
  const ChatView({
    super.key,
    required this.messagesValueNotifier,
    required this.onSendMessage,
    required this.scrollController,
    required this.textEditingController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Column(
        children: [
          Container(
            alignment: Alignment.center,
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Container(
              width: 80.0,
              height: 6.0,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(3.0),
              ),
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<List<ZoomVideoSdkChatMessage>>(
              valueListenable: messagesValueNotifier,
              builder: (context, messages, child) {
                return ListView.builder(
                  controller: scrollController,
                  itemCount: messages.length,
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return ListTile(
                      title: Text(message.content),
                      subtitle: Text(
                        message.senderUser.userName,
                        style: TextStyle(fontWeight: FontWeight.w300, fontSize: 10.0),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Type your message here',
                    ),
                    controller: textEditingController,
                    keyboardType: TextInputType.multiline,
                  ),
                ),
                const SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: () async {
                    if (textEditingController.text.isNotEmpty) {
                      await onSendMessage(textEditingController.text);
                      textEditingController.clear();
                    }
                  },
                  child: Text('Send'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
