import 'dart:convert';
import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import '../../../res/R.dart';
import '../helper/tracking_manager.dart';

// For the testing purposes, you should probably use https://pub.dev/packages/uuid.
String randomString() {
  final random = Random.secure();
  final values = List<int>.generate(16, (i) => random.nextInt(255));
  return base64UrlEncode(values);
}

class ConversationChatbotAi extends StatefulWidget {
  const ConversationChatbotAi({Key? key}) : super(key: key);

  @override
  _ConversationChatbotAiState createState() => _ConversationChatbotAiState();
}

class _ConversationChatbotAiState extends State<ConversationChatbotAi> {
  final List<types.Message> _messages = [];
  final _user = const types.User(
      id: '82091008-a484-4a89-ae75-a22bf8d6f3ac',
      firstName: 'Long',
      lastName: 'Pham',
      imageUrl: 'https://cdn-icons-png.flaticon.com/512/147/147144.png');

  @override
  void initState() {
    super.initState();
    firebaseSetup();
  }

  Future firebaseSetup() async {
    await TrackingManager.analytics.logScreenView(
        screenName: "conversation_chatbot_ai",
        screenClass: "ConversationChatbotAi");
    AppSettings.currentScreenName = 'conversation_chatbot_ai';
  }

  // @override
  // Widget build(BuildContext context) => Scaffold(
  //       body: Chat(
  //         messages: _messages,
  //         onSendPressed: _handleSendPressed,
  //         user: _user,
  //       ),
  //     );
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: R.color.white,
        body: Container(
          height: double.infinity,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  R.drawable.bg_splash,
                  fit: BoxFit.fill,
                ),
              ),
              SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppBar(
                      leading: IconButton(
                          splashColor: R.color.transparent,
                          highlightColor: R.color.transparent,
                          icon: Icon(Icons.arrow_back, color: R.color.black),
                          onPressed: () {
                            Navigator.pop(context);
                          }),
                      title: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          R.string.conversation_chatbot_ai_title.tr(),
                          style: TextStyle(
                              color: R.color.textDark,
                              fontSize: 24,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      backgroundColor: R.color.transparent, //No more green
                      elevation: 0.0, //Shadow gone
                    ),
                    Container(
                      // set Container flex fill size
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.9,
                      // set Background color for the chatbot
                      child: Chat(
                          messages: _messages,
                          onSendPressed: _handleSendPressed,
                          onPreviewDataFetched: _handlePreviewDataFetched,
                          user: _user,
                          showUserAvatars: true,
                          showUserNames: false,
                          theme: DefaultChatTheme(
                            backgroundColor: R.color.transparent,
                            inputBackgroundColor: R.color.white,
                            inputBorderRadius: BorderRadius.zero,
                            inputTextColor: R.color.textDark,
                            inputContainerDecoration: BoxDecoration(
                              color: R.color.white,
                              boxShadow: [
                                BoxShadow(
                                  color: R.color.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                          )),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: randomString(),
      text: message.text,
    );

    _addMessage(textMessage);

    //delay for 1 second to simulate the response from the chatbot
    Future.delayed(const Duration(seconds: 1), () {
      _handleResponse(textMessage);
    });
  }

  // This is the method auto response from the chatbot
  void _handleResponse(types.TextMessage message) {
    final text = message.text.toLowerCase();
    final _bot = const types.User(
        id: 'bot-uid',
        firstName: 'Bot',
        lastName: 'Con',
        imageUrl:
            'https://cdn-icons-png.flaticon.com/512/147/147144.png');
    if (text.contains('hi') || text.contains('hello')) {
      _addMessage(
        types.TextMessage(
            author: _bot,
            text: "Hello!",
            id: randomString(),
            createdAt: DateTime.now().millisecondsSinceEpoch),
      );
    } else if (text.contains('bye')) {
      _addMessage(
        types.TextMessage(
            author: _bot,
            text: "Goodbye! Have a great day!",
            id: randomString(),
            createdAt: DateTime.now().millisecondsSinceEpoch),
      );
    } else {
      _addMessage(
        types.TextMessage(
            author: _bot,
            text: "I'm sorry, I don't understand that yet.",
            id: randomString(),
            createdAt: DateTime.now().millisecondsSinceEpoch),
      );
    }
  }
  void _handlePreviewDataFetched(
    types.TextMessage message,
    types.PreviewData previewData,
  ) {
    final index = _messages.indexWhere((element) => element.id == message.id);
    final updatedMessage = (_messages[index] as types.TextMessage).copyWith(
      previewData: previewData,
    );

    setState(() {
      _messages[index] = updatedMessage;
    });
  }
}
