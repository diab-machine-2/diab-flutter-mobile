import 'dart:convert';
import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/chat_supabase_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/utils/app_log.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  final GlobalKey<ChatState> _chatKey = GlobalKey();
  late List<types.Message> _messages = [];
  int _page = 0;
  String _conversationId = '11111111-1111-1111-1111-111111111111';
  final _user = types.User(
    id: AppSettings.userInfo?.id ?? '',
    firstName: AppSettings.userInfo?.fullName ?? '',
    // lastName: AppSettings.userInfo?.id as String,
    imageUrl: AppSettings.userInfo?.imageUrl?.url ?? '',
  );
  @override
  void initState() {
    super.initState();
    firebaseSetup();
    subpabaseInit();
  }

  Future subpabaseInit() async {
    Console.log('-------subpabaseInit');
    print('SupabaseConfigResponse: -----------------');
    final ApiResult<SupabaseConfigResponse> apiResult =
        await AppRepository().getSupabaseConfig();
    apiResult.when(
        success: ((data) async => {
              Console.log('SupabaseConfigResponse: ${data.supabaseUrl}'),
              Console.log('SupabaseConfigResponse: ${data.supabaseKey}'),
              await Supabase.initialize(
                url: data.supabaseUrl,
                anonKey: data.supabaseKey,
              ),
            }),
        failure: ((error) => {Console.log('Error: $error')}));
    _handleEndReached();
  }

  Future firebaseSetup() async {
    await TrackingManager.analytics.logScreenView(
        screenName: "conversation_chatbot_ai",
        screenClass: "ConversationChatbotAi");
    AppSettings.currentScreenName = 'conversation_chatbot_ai';
  }

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
                      height: MediaQuery.of(context).size.height -
                          MediaQuery.of(context).padding.bottom -
                          80,
                      // set Background color for the chatbot
                      child: Chat(
                          key: _chatKey,
                          messages: _messages,
                          onSendPressed: _handleSendPressed,
                          onPreviewDataFetched: _handlePreviewDataFetched,
                          user: _user,
                          showUserAvatars: true,
                          showUserNames: false,
                          onEndReached: _handleEndReached,
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

  Future<void> _handleEndReached() async {
    const pageSize = 20;
    final response = await Supabase.instance.client
        .from('messages')
        .select()
        .filter('conversation_id', 'eq', _conversationId)
        //     .filter('sender', 'in', [_user.id, 'ai'])
        //     .filter('sender_type', 'in', [
        //   'user',
        //   'ai'
        // ])
        .range(this._page * pageSize, (this._page + 1) * pageSize)
        .order('created_at', ascending: false);
    Console.log('-------_handleEndReached');
    final messages = response
        .map(
          (e) => types.TextMessage(
            author: new types.User(
                id: e['sender'] as String,
                firstName: e['sender'] as String,
                lastName: e['sender'] as String,
                imageUrl:
                    'https://cdn-icons-png.flaticon.com/512/147/147144.png'),
            id: e['id'] as String,
            text: e['content'] as String,
            createdAt: DateTime.parse(e['created_at'] as String)
                .millisecondsSinceEpoch,
          ),
        )
        .toList();
    setState(() {
      _messages = [..._messages, ...messages];
      _page = _page + 1;
    });
    // if (_messages.where((e) => e.id == 'lastReadMessageId').isEmpty) {
    //   // Recursively call to fetch more pages
    //   await _handleEndReached();
    // } else {
    //   // Give some delay for the library to calculate correct indices
    //   Future.delayed(const Duration(milliseconds: 20), () {
    //     _chatKey.currentState?.scrollToUnreadHeader();
    //   });
    // }
  }

  void _handleSendPressed(types.PartialText _message) async {
    var message = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: randomString(),
      text: _message.text,
    );

    // add the message to the database
    final dbMessage = await Supabase.instance.client
        .from('messages')
        .insert({
          'conversation_id': _conversationId,
          'sender': message.author.id,
          'sender_type': 'user',
          'content': message.text,
        })
        .select('id')
        .single();
    final updatedMessage = message.copyWith(id: dbMessage['id'] as String);
    setState(() {
      _messages.insert(0, updatedMessage);
    });
    _handleResponse(updatedMessage);
  }

  // This is the method auto response from the chatbot
  void _handleResponse(types.Message message) async {
    final ApiResult<MessageResponse> apiResult =
        await AppRepository().sendMessageById(_conversationId, message.id);
    apiResult.when(
        success: ((data) => {
              setState(() {
                _messages.insert(
                    0,
                    types.TextMessage(
                        author: data.senderType == 'user'
                            ? _user
                            : types.User(
                                id: data.sender,
                                firstName: data.sender,
                                lastName: data.sender,
                                imageUrl:
                                    'https://cdn-icons-png.flaticon.com/512/147/147144.png'),
                        id: data.id,
                        text: data.content,
                        createdAt: data.createdAt));
              })
            }),
        failure: ((error) => {Console.log('Error: $error')}));
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
