import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:linkify/linkify.dart';
import 'package:medical/res/R.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/meeting_message.dart';

class ChatView extends StatelessWidget {
  final String thisUserId;
  final Function(String) onSendMessage;
  final FocusNode focusNode;
  final TextEditingController textEditingController;
  final ValueNotifier<List<MeetingMessage>> messagesValueNotifier;
  const ChatView({
    super.key,
    required this.thisUserId,
    required this.messagesValueNotifier,
    required this.onSendMessage,
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
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: R.color.color0xffE5E5E5, width: 1.0),
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            padding: EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: 48.0),
                Text(
                  'zoom_chat'.tr(),
                  style: R.style.appBarTitle,
                ),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.close),
                ),
              ],
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<List<MeetingMessage>>(
              valueListenable: messagesValueNotifier,
              builder: (context, messages, child) {
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.only(bottom: 0.0, top: 16.0),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isThisUser = message.senderUser.userId == thisUserId;

                    double paddingVertical = 4.0;
                    if (message.isEndOfGroup) paddingVertical = 16.0;

                    return Padding(
                      padding: EdgeInsets.fromLTRB(16.0, 0, 16.0, paddingVertical),
                      child: Row(
                        mainAxisAlignment:
                            isThisUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                        children: isThisUser
                            ? [
                                const SizedBox(width: 66.0),
                                Flexible(child: _buildItemOfThisUser(message)),
                              ]
                            : [
                                Flexible(child: _buildItemOfOtherUser(message)),
                                const SizedBox(width: 66.0)
                              ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: R.color.color0xffE5E5E5, width: 1.0),
              ),
            ),
            padding: EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'zoom_chat_hint'.tr(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0)),
                    focusNode: focusNode,
                    controller: textEditingController,
                    keyboardType: TextInputType.multiline,
                    maxLines: 3,
                    minLines: 1,
                  ),
                ),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: textEditingController,
                  builder: (context, value, child) {
                    bool haveText = value.text.isNotEmpty;
                    return IconButton(
                      iconSize: 24,
                      onPressed: haveText ? () async {
                        if (textEditingController.text.isNotEmpty) {
                          await onSendMessage(textEditingController.text);
                          textEditingController.clear();
                        }
                      } : null,
                      icon: Image.asset(
                        R.drawable.ic_zoom_send_chat,
                        width: 24.0,
                        height: 24.0,
                        color: haveText ? Color(0xFF008479) : null,
                      ),
                    );
                  }
                ),
              ],
            ),
          ),
          Builder(
            builder: (
              context,
            ) {
              final media = MediaQuery.of(context);
              if (media.viewInsets.bottom > 0.0) {
                return SizedBox(height: media.viewInsets.bottom);
              }
              return SizedBox(height: media.padding.bottom);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContentWidget(MeetingMessage message) {
    final normalStyle = TextStyle(
      fontWeight: FontWeight.w500,
      height: 18 / 16,
      color: R.color.textDark,
    );
    final linkStyle = normalStyle.copyWith(
      color: Colors.blue,
      decoration: TextDecoration.underline,
    );
    if (message.haveLink) {
      return RichText(
        text: TextSpan(
          children: message.elements!.map((e) {
            if (e is TextElement) {
              return TextSpan(text: e.text, style: normalStyle);
            } else if (e is LinkableElement) {
              return TextSpan(
                text: e.text,
                style: linkStyle,
                recognizer: TapGestureRecognizer()..onTap = () => _onLinkTap(e),
              );
            }
            return TextSpan(text: '');
          }).toList(),
          style: normalStyle,
        ),
      );
    }
    return Text(message.content, style: normalStyle);
  }

  Widget _buildItemOfOtherUser(MeetingMessage message) {
    double expectSized = 24.0;
    double expectPadding = 1.0;
    final avatarWidget = Container(
      clipBehavior: Clip.antiAlias,
      width: expectSized,
      height: expectSized,
      decoration: BoxDecoration(
        color: R.color.mainColor,
        borderRadius: BorderRadius.circular(expectSized / 2),
      ),
      child: Padding(
        padding: EdgeInsets.all(expectPadding),
        child: Icon(Icons.person, size: 16.0, color: R.color.white),
      ),
    );
    final w = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // SizedBox Or Avatar
        if (message.isFirstMessage) avatarWidget else SizedBox(width: expectSized),

        const SizedBox(width: 8.0),

        // Column of message
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: R.color.color0xffE5E5E5, width: 1.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (message.isFirstMessage)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: Text(
                      message.senderUser.userName,
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                        color: R.color.greenGradientBottom,
                      ),
                    ),
                  ),
                _buildContentWidget(message),
                if (message.isEndOfGroup)
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Text(
                      DateFormat('HH:mm')
                          .format(DateTime.fromMillisecondsSinceEpoch(message.timestamp)),
                      style: TextStyle(
                        fontSize: 11.0,
                        fontWeight: FontWeight.w500,
                        color: R.color.color0xff666666,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
    return w;
  }

  Widget _buildItemOfThisUser(MeetingMessage message) {
    final w = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Color(0xFFE1FAF8),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: R.color.color0xffE5E5E5, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildContentWidget(message),
          if (message.isEndOfGroup)
            Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Text(
                DateFormat('HH:mm')
                    .format(DateTime.fromMillisecondsSinceEpoch(message.timestamp)),
                style: TextStyle(
                  fontSize: 11.0,
                  fontWeight: FontWeight.w500,
                  color: R.color.color0xff666666,
                ),
              ),
            ),
        ],
      ),
    );

    return w;
  }
}
