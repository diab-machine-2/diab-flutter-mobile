import 'dart:convert';
import 'dart:ffi';
import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/chat_supabase_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/utils/app_log.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
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
  String _conversationId = '';
  late List<types.User> _typingUsers = [];
  final _user = types.User(
    id: AppSettings.userInfo?.id ?? '',
    firstName: AppSettings.userInfo?.fullName ?? '',
    // lastName: AppSettings.userInfo?.id as String,
    imageUrl: AppSettings.userInfo?.imageUrl?.url ?? '',
  );
  var _bot = types.User(
    id: 'ai',
    firstName: 'Chat Bot AI',
    // lastName: 'Chat Bot AI',
    imageUrl:
        'https://s160-ava-talk.zadn.vn/8/b/a/e/7/160/0e6d45871cf216bf78e2d435ed3ba31a.jpg',
  );
  @override
  void initState() {
    super.initState();
    firebaseSetup();
    subpabaseInit();
  }

  Future subpabaseInit() async {
    final ApiResult<SupabaseConfigResponse> apiResult =
        await AppRepository().getSupabaseConfig();
    apiResult.when(
        success: ((data) async => {
              await Supabase.initialize(
                url: data.supabaseUrl,
                anonKey: data.supabaseKey,
              ).onError((error, stackTrace) {
                return Supabase.instance;
              }),
              await conversationInit(),
            }),
        failure: ((error) => {Console.log('Error: $error')}));
  }

  Future conversationInit() async {
    // select first conversation with the status 'active'
    // if comes empty, create a new conversation
    // update conversationId state with the id of the conversation
    final apiGetResult = await AppRepository().getMyConversation();
    apiGetResult.whenOrNull(
        success: ((data) async => {
              if (data.data!.length > 0)
                {
                  setState(() {
                    _conversationId = data.data!.first.id;
                  }),
                  await _handleEndReached(isReset: true),
                }
              else
                await createConversation()
            }),
        failure: (error) => {
              Console.log('Error: $apiGetResult'),
            });
  }

  Future createConversation() async {
    CreateConversationRequest newConversation = CreateConversationRequest(
        title: 'Chat Bot AI', descrtiption: 'Chat Bot AI Description');
    final apiResult = await AppRepository().createConversation(newConversation);
    apiResult.when(
        success: ((data) async => {
              setState(() {
                _conversationId = data.data!.id;
              }),
              await _handleEndReached(isReset: true),
            }),
        failure: ((error) => {Console.log('Error: $error')}));
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
        appBar: AppBar(
          leading: IconButton(
              splashColor: R.color.transparent,
              highlightColor: R.color.transparent,
              icon: Icon(Icons.arrow_back, color: R.color.white),
              onPressed: () {
                Navigator.pushNamed(context, NavigatorName.tabbar);
              }),
          title: Align(
            alignment: Alignment.topLeft,
            child: Text(
              R.string.conversation_chatbot_ai_title.tr(),
              style: TextStyle(
                  color: R.color.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w400),
            ),
          ),
          actions: [
            IconButton(
              splashColor: R.color.transparent,
              highlightColor: R.color.transparent,
              icon: Icon(Icons.format_list_bulleted,
                  color: R.color.white, size: 24),
              onPressed: () {
                Navigator.pushNamed(context, NavigatorName.conversation_setting,
                    arguments: {
                      'conversationId': _conversationId,
                    });
              },
            ),
          ],
          backgroundColor: R.color.transparent, //No more green
          elevation: 0.0, //Shadow gone
          flexibleSpace: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                  R.color.greenGradientMid,
                  R.color.greenGradientBottom
                ])),
          ),
        ),
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
              Container(
                // set Container flex fill size
                width: double.infinity,
                height: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.bottom,
                // set Background color for the chatbot
                child: Chat(
                    key: _chatKey,
                    messages: _messages,
                    onSendPressed: _handleSendPressed,
                    onPreviewDataFetched: _handlePreviewDataFetched,
                    onMessageDoubleTap: (context, p1) => {
                          // copy message to clipboard
                          Clipboard.setData(ClipboardData(
                              text: p1 is types.TextMessage ? p1.text : p1.id)),
                          // show message copied by snackbar
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            padding: EdgeInsets.all(8),
                            content: Text('Copied to clipboard'),
                            backgroundColor: Colors.blueAccent,
                          ))
                        },
                    inputOptions: InputOptions(
                        onTextChanged: (str) => {
                              if (_typingUsers
                                  .where((e) => e.id == _user.id)
                                  .isEmpty)
                                {
                                  setState(() {
                                    _typingUsers = [..._typingUsers, _user];
                                  })
                                }
                            }),
                    user: _user,
                    showUserAvatars: true,
                    showUserNames: false,
                    onEndReached: _handleEndReached,
                    typingIndicatorOptions: TypingIndicatorOptions(
                      typingUsers: _typingUsers,
                    ),
                    onAvatarTap: (user) => {
                          Navigator.pushNamed(
                              context, NavigatorName.conversation_user_profile,
                              arguments: {
                                'userId': user.id,
                              })
                        },
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
                      primaryColor: Color.fromRGBO(202, 250, 245, 1),
                      sentMessageBodyTextStyle: TextStyle(
                        color: R.color.textDark,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                      sentMessageLinkDescriptionTextStyle: TextStyle(
                        color: R.color.captionColorGray,
                        fontSize: 14,
                        fontWeight: FontWeight.w200,
                        height: 1.2,
                      ),
                      sentMessageLinkTitleTextStyle: TextStyle(
                        color: R.color.textDark,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                      ),
                      typingIndicatorTheme: TypingIndicatorTheme(
                        animatedCirclesColor: neutral1,
                        animatedCircleSize: 5.0,
                        bubbleBorder: BorderRadius.all(Radius.circular(27.0)),
                        bubbleColor: neutral7,
                        countAvatarColor: primary,
                        countTextColor: secondary,
                        multipleUserTextStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: neutral2,
                        ),
                      ),
                      // sentMessageBodyLinkTextStyle: TextStyle(
                      //   color: R.color.red,
                      //   fontSize: 16,
                      //   fontWeight: FontWeight.w500,
                      //   height: 1.5,
                      // ),
                    )),
              ),
              // Positioned(
              //   bottom: MediaQuery.of(context).viewInsets.bottom + 60 + 8,
              //   left: 4,
              //   child: AnimatedOpacity(
              //     opacity: _typingUsers.where((e) => e.id == _bot.id).isNotEmpty
              //         ? 1
              //         : 0,
              //     duration: const Duration(milliseconds: 500),
              //     child: Container(
              //       padding:
              //           EdgeInsets.only(left: 4, right: 10, top: 3, bottom: 3),
              //       decoration: BoxDecoration(
              //           color: R.color.greenGradientMid,
              //           borderRadius: BorderRadius.circular(2),
              //           boxShadow: null),
              //       child: Row(
              //           crossAxisAlignment: CrossAxisAlignment.center,
              //           mainAxisSize: MainAxisSize.min,
              //           mainAxisAlignment: MainAxisAlignment.start,
              //           children: [
              //             Text('Typing',
              //                 style: TextStyle(
              //                     color: R.color.white,
              //                     fontSize: 12,
              //                     fontWeight: FontWeight.w400)),
              //             SizedBox(width: 6),
              //             LoadingAnimationWidget.staggeredDotsWave(
              //               color: R.color.white,
              //               size: 16,
              //             )
              //           ]),
              //     ),
              //   ),
              // ),

              // Positioned(
              //     bottom: 0,
              //     left: 0,
              //     child: Container(
              //       padding: EdgeInsets.all(4),
              //       child: Text('Typing...'),
              //     )),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleEndReached({bool? isReset = false}) async {
    if (isReset == true) {
      _page = 0;
      _messages = [];
    }
    const pageSize = 20;
    final response = await Supabase.instance.client
        .from('messages')
        .select()
        .filter('conversation_id', 'eq', _conversationId)
        .filter('sender', 'in', [_user.id, _bot.id])
        .filter('sender_type', 'in', ['user', 'ai'])
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
                    'https://s160-ava-talk.zadn.vn/8/b/a/e/7/160/0e6d45871cf216bf78e2d435ed3ba31a.jpg'),
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
    // Delay 1 second then remove _user from typing list
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _typingUsers = _typingUsers.where((e) => e.id != _user.id).toList();
    });

    _handleResponse(updatedMessage);
  }

  // This is the method auto response from the chatbot
  void _handleResponse(types.Message message) async {
    setState(() {
      _typingUsers = [..._typingUsers, _bot];
    });
    final ApiResult<MessageResponse> apiResult =
        await AppRepository().sendMessageById(_conversationId, message.id);
    apiResult.when(
        success: ((data) => {
              setState(() {
                _bot = types.User(
                  id: data.data!.sender,
                  firstName: data.data!.sender,
                  lastName: data.data!.sender,
                  imageUrl:
                      'https://s160-ava-talk.zadn.vn/8/b/a/e/7/160/0e6d45871cf216bf78e2d435ed3ba31a.jpg',
                );
                _messages.insert(
                    0,
                    types.TextMessage(
                        author: data.data!.senderType == 'user' ? _user : _bot,
                        id: data.data!.id,
                        text: data.data!.content,
                        createdAt: data.data!.createdAt));
                _typingUsers = _typingUsers
                    .where((e) => e.id != _bot.id)
                    .toList(); // remove user bot typing list
              })
            }),
        failure: ((error) {
          Console.log('Error: $error');
          setState(() {
            _typingUsers = _typingUsers
                .where((e) => e.id != _bot.id)
                .toList(); // remove bot from typing list
          });
        }));
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
