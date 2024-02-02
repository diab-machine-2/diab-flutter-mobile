import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:linkify/linkify.dart';
import 'package:medical/res/R.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/MeetingMessage.dart';

class ChatView extends StatelessWidget {
  final Function(String) onSendMessage;
  final Function() onClose;
  final FocusNode focusNode;
  final TextEditingController textEditingController;
  final ValueNotifier<List<MeetingMessage>> messagesValueNotifier;
  const ChatView({
    super.key,
    required this.messagesValueNotifier,
    required this.onSendMessage,
    required this.onClose,
    required this.focusNode,
    required this.textEditingController,
  });

  void _onLinkTap(LinkableElement link) async {
    String url = link.url;
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        if (link is EmailElement || link is PhoneNumberElement) {
          await launchUrl(uri, mode: LaunchMode.externalNonBrowserApplication);
          return;
        }
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        print('Could not launch $url');
      }
    } catch (e) {
      print('error when launching $url, $e');
    }
  }

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
            padding: EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: onClose,
                  icon: Icon(Icons.close),
                ),
                Container(
                  width: 80.0,
                  height: 6.0,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(3.0),
                  ),
                ),
                const SizedBox(width: 48.0),
              ],
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<List<MeetingMessage>>(
              valueListenable: messagesValueNotifier,
              builder: (context, messages, child) {
                return ListView.builder(
                  reverse: true,
                  padding: EdgeInsets.zero,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final senderNameWidget = Text(
                      message.senderUser.userName,
                      style: TextStyle(fontWeight: FontWeight.w300, fontSize: 10.0),
                    );
                    if (message.haveLink) {
                      return ListTile(
                        title: RichText(
                          text: TextSpan(
                            children: message.elements!.map((e) {
                              if (e is TextElement) {
                                return TextSpan(text: e.text, style: TextStyle(color: Colors.black));
                              } else if (e is LinkableElement) {
                                return TextSpan(
                                  text: e.text,
                                  style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () => _onLinkTap(e),
                                );
                              }
                              return TextSpan(text: '');
                            }).toList(),
                          ),
                        ),
                        subtitle: senderNameWidget,
                      );
                    }
                    return ListTile(
                      title: Text(message.content),
                      subtitle: senderNameWidget,
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
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0)),
                    focusNode: focusNode,
                    controller: textEditingController,
                    keyboardType: TextInputType.multiline,
                    maxLines: 3,
                    minLines: 1,
                  ),
                ),
                // const SizedBox(width: 4.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(12.0),
                    backgroundColor: R.color.primaryColor,
                  ),
                  onPressed: () async {
                    if (textEditingController.text.isNotEmpty) {
                      await onSendMessage(textEditingController.text);
                      textEditingController.clear();
                    }
                  },
                  child: Image.asset(
                    R.drawable.ic_send,
                    width: 20,
                    height: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
