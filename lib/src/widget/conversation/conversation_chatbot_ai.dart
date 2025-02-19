import 'dart:async';
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
  types.User _author = types.User(
    id: AppSettings.userInfo?.id ?? '',
    firstName: AppSettings.userInfo?.fullName ?? '',
    // lastName: AppSettings.userInfo?.id as String,
    imageUrl: AppSettings.userInfo?.imageUrl?.url ?? '',
  );
  types.User _bot = types.User(
    id: 'ai',
    firstName: 'Chat Bot AI',
    // lastName: 'Chat Bot AI',
    imageUrl: Image.asset(R.drawable.chat_avatar_chatbot_ai).toString(),
  );
  types.Room _conversation = types.Room(
    id: '',
    type: types.RoomType.direct,
    imageUrl: Image.asset(R.drawable.chat_avatar_chatbot_ai).toString(),
    name: 'Chat Bot AI',
    users: [],
  );
  List<types.User> _typingUsers = [];
  bool _isLoading = false;
  final TextEditingController _messageController = TextEditingController();
  StreamSubscription<List<Map<String, dynamic>>>? _messageSubscription;

  @override
  void initState() {
    super.initState();
    _conversation = _conversation.copyWith(
        users: [
      _author,
      _bot,
    ].toList());
    firebaseSetup();
    subpabaseInit();
  }

  Future subpabaseInit() async {
    setState(() {
      _isLoading = true;
    });
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

  void _subscribeToMessages() {
    if (_conversation.id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Conversation ID is empty'),
        backgroundColor: Colors.red,
      ));
    }
    _messageSubscription?.cancel();
    _messageSubscription = Supabase.instance.client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('conversation_id', _conversation.id)
        .order('created_at', ascending: false)
        .listen(
          (data) {
            final messages =
                data.map((msg) => Message.fromMap(msg).uiMessage!).toList();

            setState(() => _messages = messages);
          },
          onError: (error) {
            debugPrint('Error in message subscription: $error');
          },
          onDone: () {
            debugPrint('Message subscription done');
          },
        );
  }

  Future conversationInit() async {
    // select first conversation with the status 'active'
    // if comes empty, create a new conversation
    // update conversationId state with the id of the conversation
    final apiGetResult = await AppRepository().getMyConversation();
    apiGetResult.whenOrNull(
        success: ((data) async => {
              if (data.data!.isNotEmpty)
                {
                  setState(() {
                    _conversation =
                        Conversation.fromMap(data.data!.first.toJson()).uiRoom!;
                    _isLoading = false;
                  }),
                  _subscribeToMessages()
                }
              else
                createConversation()
            }),
        failure: (error) => {
              Console.log('Error: $apiGetResult'),
              setState(() {
                _isLoading = false;
              })
            });
  }

  Future createConversation() async {
    var newConversation = CreateConversationRequest(
        title: 'Chat Bot AI', descrtiption: 'Chat Bot AI Description');
    final apiResult = await AppRepository().createConversation(newConversation);
    apiResult.whenOrNull(
        success: ((data) {
          // setState(() {
          //   _conversation = Conversation.fromMap({
          //     'id': data.data,
          //     'title': newConversation.title,
          //     'description': newConversation.descrtiption,
          //     'status': 'active',
          //     'created_at': DateTime.now().toIso8601String(),
          //   }).uiRoom!;
          //   _isLoading = false;
          // });
          // _subscribeToMessages();
          return conversationInit();
        }),
        failure: ((error) => {Console.log('Error: $error')}));
  }
  // Future createWellcomeMessage() async {
  //   final wcMessage = await Supabase.instance.client
  //       .from('messages')
  //       .insert({
  //         'conversation_id': _conversation.id,
  //         'sender': _bot.id,
  //         'sender_type': 'ai',
  //         'content': 'Hello, I am Chat Bot AI. How can I help you?',
  //       })
  //       .select('id')
  //       .single();
  // }

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
                      'conversationId': _conversation.id,
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
                    // l10n:
                    //     const ChatL10nEn(inputPlaceholder: 'Type a message...'),
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
                                  .where((e) => e.id == _author.id)
                                  .isEmpty)
                                {
                                  setState(() {
                                    _typingUsers = [..._typingUsers, _author];
                                  })
                                }
                            },
                        textEditingController: _messageController),
                    user: _author,
                    showUserAvatars: true,
                    showUserNames: false,
                    // onEndReached: _handleEndReached,
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
            ],
          ),
        ),
      ),
    );
  }

  // Future<void> _handleEndReached() async {
  // const pageSize = 20;
  // final response = await Supabase.instance.client
  //     .from('messages')
  //     .select()
  //     .filter('conversation_id', 'eq', _conversation.id)
  //     // .filter('sender', 'in', [_user.id, _bot.id])
  //     // .filter('sender_type', 'in', ['user', 'ai'])
  //     // .range(this._page * pageSize, (this._page + 1) * pageSize)
  //     .order('created_at', ascending: false);
  // final messages =
  //     response.map((e) => Message.fromMap(e).uiMessage!).toList();
  // setState(() {
  //   _messages = messages;
  //   // _page = _page + 1;
  // });
  // if (_messages.where((e) => e.id == 'lastReadMessageId').isEmpty) {
  //   // Recursively call to fetch more pages
  //   await _handleEndReached();
  // } else {
  //   // Give some delay for the library to calculate correct indices
  //   Future.delayed(const Duration(milliseconds: 20), () {
  //     _chatKey.currentState?.scrollToUnreadHeader();
  //   });
  // }
  // }

  void _handleSendPressed(types.PartialText _message) async {
    if (_typingUsers.where((e) => e.id == _bot.id).isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please wait for the bot to finish typing'),
        backgroundColor: R.color.yellowAccent,
      ));
      return;
    }
    var message = types.TextMessage(
      author: _author,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: randomString(),
      text: _message.text,
    );

    // add the message to the database
    final dbMessage = await Supabase.instance.client
        .from('messages')
        .insert({
          'conversation_id': _conversation.id,
          'sender': message.author.id,
          'sender_type': 'user',
          'content': message.text,
        })
        .select('id')
        .single();
    final updatedMessage = message.copyWith(id: dbMessage['id'] as String);
    setState(() {
      _messages.insert(0, updatedMessage);
      _typingUsers = _typingUsers.where((e) => e.id != _author.id).toList();
    });

    return _handleBotResponse(updatedMessage);
  }

  // // This is the method auto response from the chatbot
  void _handleBotResponse(types.Message message) async {
    if (_typingUsers.where((e) => e.id == _bot.id).isEmpty) {
      setState(() {
        _typingUsers = [..._typingUsers, _bot];
      });
    }
    final ApiResult<MessageResponse> apiResult =
        await AppRepository().sendMessageById(_conversation.id, message.id);
    apiResult.when(
        success: ((data) => {
              setState(() {
                _bot = _bot.copyWith(
                    id: data.data!.sender,
                    firstName: data.data!.sender,
                    lastName: data.data!.senderType);
                // Change load message from suprise event to the message response from the chatbot
                // _messages.insert(
                //     0,
                //     types.TextMessage(
                //         author:
                //             data.data!.sender == _author.id ? _author : _bot,
                //         id: data.data!.id,
                //         text: data.data!.content,
                //         createdAt: data.data!.createdAt));
                // _subscribeToMessages();
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
      title: map['title'] ?? 'Chat Bot AI',
      description: map['description'] ?? 'Chat Bot AI Description',
      status: map['status'] ?? 'active',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
      uiRoom: types.Room(
        id: map['id'],
        type: types.RoomType.direct,
        imageUrl: Image.asset(R.drawable.chat_avatar_chatbot_ai).toString(),
        name: map['title'] ?? 'Chat Bot AI',
        users: [],
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
