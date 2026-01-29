import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:bubble/bubble.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_chat_ui/src/models/date_header.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/chat_supabase_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/utils/app_log.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/conversation/conversation_comon.dart'
    as itypes;
import 'package:readmore/readmore.dart';
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

class _ConversationChatbotAiState extends State<ConversationChatbotAi>
    with WidgetsBindingObserver {
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
    imageUrl: R.drawable.chat_avatar_chatbot_ai_3,
  );
  types.Room _conversation = types.Room(
    id: '',
    type: types.RoomType.direct,
    imageUrl: R.drawable.chat_avatar_chatbot_ai_3,
    name: 'Chat Bot AI',
    users: [],
  );
  List<types.User> _typingUsers = [];
  bool _isLoading = true;
  bool _isKeyboardVisible = false;
  final TextEditingController _messageController = TextEditingController();
  StreamSubscription<List<Map<String, dynamic>>>? _messageSubscription;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _conversation = _conversation.copyWith(
        users: [
      _author,
      _bot,
    ].toList());
    firebaseSetup();
    subpabaseInit();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _messageSubscription?.cancel();
    _messages.clear();
    super.dispose();
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

  @override
  void didChangeMetrics() {
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    final newValue = bottomInset > 0.0;
    if (newValue != _isKeyboardVisible) {
      setState(() {
        _isKeyboardVisible = newValue;
      });
      if (!newValue &&
          _typingUsers.where((e) => e.id == _author.id).isNotEmpty) {
        setState(() {
          _typingUsers = _typingUsers.where((e) => e.id != _author.id).toList();
        });
      }
    }
  }

  void _subscribeToMessages() {
    if (_conversation.id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(R.string.conversation_alert_id_is_empty.tr()),
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
            final messages = data
                .map((msg) => itypes.Message.fromMap(msg).uiMessage!)
                .toList();

            setState(() {
              _messages = messages;
              _isLoading = false;
            });
          },
          onError: (error) {
            debugPrint('Error in message subscription: $error');
            setState(() {
              _isLoading = false;
            });
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
                        itypes.Conversation.fromMap(data.data!.first.toJson())
                            .uiRoom!;
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
        title: R.string.conversation_chatbot_ai_title.tr(),
        descrtiption: R.string.conversation_mockup_description.tr());
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
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
          NavigatorName.tabbar,
          (route) => false, // This removes all routes from stack
        );
        return false;
      },
      child: GestureDetector(
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
                  Navigator.of(context, rootNavigator: true)
                      .pushNamedAndRemoveUntil(
                    NavigatorName.tabbar,
                    (route) => false, // This removes all routes from stack
                  );
                }),
            title: Transform(
              transform: Matrix4.translationValues(-20, 0.0, 0.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  R.string.conversation_chatbot_ai_title.tr(),
                  style: TextStyle(
                      color: R.color.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w400),
                ),
              ),
            ),
            actions: [
              IconButton(
                splashColor: R.color.transparent,
                highlightColor: R.color.transparent,
                icon: Icon(Icons.format_list_bulleted,
                    color: R.color.white, size: 24),
                onPressed: () {
                  Navigator.pushNamed(
                      context, NavigatorName.conversation_setting,
                      arguments: _conversation.metadata);
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
          body: _buildContainer(),
        ),
      ),
    );
  }

  Widget _buildContainer() {
    return Container(
      height: double.infinity,
      child: Stack(
        children: [
          // Positioned.fill(
          //   child: Image.asset(
          //     R.drawable.bg_splash,
          //     fit: BoxFit.fill,
          //   ),
          // ),
          Container(
            // set Container flex fill size
            width: double.infinity,
            height: MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.bottom,
            // set Background color for the chatbot
            child: _isLoading
                ? Center(
                    child: SpinKitDoubleBounce(
                    color: R.color.mainColor,
                    size: 50.0,
                  ))
                : Chat(
                    key: _chatKey,
                    messages: _messages,
                    onSendPressed: _handleSendPressed,
                    onPreviewDataFetched: _handlePreviewDataFetched,
                    bubbleBuilder: _bubbleBuilder,
                    dateHeaderBuilder: _dateHeaderBuilder,
                    emptyState: Center(
                      child: Text(
                        'No messages here yet',
                        style: TextStyle(
                          color: R.color.textDark,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    l10n: ChatL10nEn(
                        inputPlaceholder:
                            R.string.conversation_message_placeholder.tr()),
                    onMessageDoubleTap: (context, p1) => {
                          // copy message to clipboard
                          Clipboard.setData(ClipboardData(
                              text: p1 is types.TextMessage ? p1.text : p1.id)),
                          // show message copied by snackbar
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            padding: EdgeInsets.all(8),
                            content:
                                Text(R.string.conversation_message_copied.tr()),
                            backgroundColor: Colors.blueAccent,
                          ))
                        },
                    avatarBuilder: (author) => GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                              context, NavigatorName.conversation_user_profile,
                              arguments: {
                                'userId': author.id,
                              });
                        },
                        child: CircleAvatar(
                          backgroundImage: author.imageUrl != null
                              ? NetworkImage(author.imageUrl!)
                              : AssetImage(R.drawable.chat_avatar_chatbot_ai_3)
                                  as ImageProvider,
                        )),
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
                    // typingIndicatorOptions: TypingIndicatorOptions(
                    //   typingUsers: _typingUsers,
                    //   // typingWidgetBuilder: _typingWidgetBuilder,
                    // ),
                    // onAvatarTap: (user) => {
                    //       Navigator.pushNamed(
                    //           context, NavigatorName.conversation_user_profile,
                    //           arguments: {
                    //             'userId': user.id,
                    //           })
                    //     },
                    theme: DefaultChatTheme(
                      backgroundColor: R.color.bg_conversation_chat,
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
          Positioned(
            bottom: MediaQuery.of(context).viewInsets.bottom + 60 + 5,
            left: 1,
            child: AnimatedOpacity(
              opacity:
                  _typingUsers.where((e) => e.id == _bot.id).isNotEmpty ? 1 : 0,
              duration: const Duration(milliseconds: 500),
              child: Container(
                padding: EdgeInsets.only(left: 6, right: 10, top: 3, bottom: 3),
                decoration: BoxDecoration(
                    color: R.color.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border(
                        top: BorderSide(
                            color: R.color.conversation_typing_broder,
                            width: 1),
                        left: BorderSide(
                            color: R.color.conversation_typing_broder,
                            width: 1),
                        bottom: BorderSide(
                            color: R.color.conversation_typing_broder,
                            width: 1),
                        right: BorderSide(
                            color: R.color.conversation_typing_broder,
                            width: 1))),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SpinKitThreeBounce(
                        color: R.color.mainColor,
                        size: 10,
                      ),
                      SizedBox(width: 4),
                      Text(R.string.conversation_typing.tr(),
                          style: TextStyle(
                              color: R.color.mainColor,
                              fontSize: 12,
                              fontFamily: 'sfpro',
                              fontWeight: FontWeight.w400)),
                    ]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _typingWidgetBuilder(
      {required BuildContext context,
      required TypingIndicatorMode mode,
      required TypingIndicator widget}) {
    return widget;
  }

  Widget _dateHeaderBuilder(DateHeader dateHeader) {
    return Container(
      alignment: Alignment.center,
      child: Opacity(
        opacity: 0.3,
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFF3E3F3F),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          margin: EdgeInsets.only(
            bottom: 32,
            top: 16,
          ),
          child: Text(
            DateFormat('HH:mm dd/MM/yyyy').format(dateHeader.dateTime),
            style: TextStyle(
              color: R.color.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _bubbleBuilder(
    Widget child, {
    required types.Message message,
    required bool nextMessageInGroup,
  }) {
    DateTime dateTime =
        DateTime.fromMillisecondsSinceEpoch(message.createdAt ?? 0, isUtc: true)
            .toLocal();
    // String formattedDateTime = dateTime.isSameDayWith(DateTime.now())
    //     ? DateFormat('HH:mm').format(dateTime)
    //     : DateFormat('HH:mm - dd/MM/yyyy').format(dateTime);
    String formattedDateTime = DateFormat('HH:mm').format(dateTime);
    return Bubble(
      padding: BubbleEdges.all(10),
      borderColor: _author.id == message.author.id
          ? R.color.conversation_bubble_author_broder
          : R.color.conversation_bubble_bot_broder,
      child: message.type != types.MessageType.text
          ? child
          : Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  ReadMoreText((message as types.TextMessage).text,
                      trimMode: TrimMode.Length,
                      trimLines: 5,
                      trimLength: 240,
                      style: TextStyle(color: R.color.textDark, fontSize: 16),
                      colorClickableText: Color.fromARGB(149, 104, 46, 1),
                      trimCollapsedText:
                          R.string.conversation_message_read_more.tr(),
                      trimExpandedText:
                          R.string.conversation_message_read_less.tr()),
                  // Draw time for each group of messages
                  if (!nextMessageInGroup) ...[
                    Container(
                      margin: EdgeInsets.only(top: 6),
                      child: Text(
                        formattedDateTime,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: R.color.captionColorGray,
                            fontSize: 12,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                    // AI citation: dashed line + disclaimer (only for sender == ai)
                    if (message.author.id == _bot.id) ...[
                      LayoutBuilder(
                        builder: (context, constraints) {
                          const dashW = 4.0;
                          const dashSpace = 3.0;
                          final n = ((constraints.maxWidth + dashSpace) /
                                  (dashW + dashSpace))
                              .floor()
                              .clamp(0, 120);
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Row(
                              children: List.generate(
                                n,
                                (i) => Padding(
                                  padding: EdgeInsets.only(
                                      right: i < n - 1 ? dashSpace : 0),
                                  child: Container(
                                    width: dashW,
                                    height: 1,
                                    color: R.color.captionColorGray,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        child: Text(
                          R.string.conversation_ai_citation.tr(),
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: R.color.captionColorGray,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ],
                ]),
      color: _author.id != message.author.id ||
              message.type == types.MessageType.image
          ? R.color.white
          : const Color(0xffCAFAF5),
      nip: nextMessageInGroup
          ? BubbleNip.no
          : _author.id != message.author.id
              ? BubbleNip.leftBottom
              : BubbleNip.rightBottom,
      showNip: false,
      margin: nextMessageInGroup
          ? const BubbleEdges.symmetric(horizontal: 6)
          : null,
      stick: true,
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
    if (_isSending) return; // Prevent multiple submissions
    _isSending = true;

    if (_typingUsers.where((e) => e.id == _bot.id).isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(R.string.conversation_pls_wait_bot_finish_typing.tr()),
        backgroundColor: R.color.deepOrange,
      ));
      _isSending = false;
      return;
    } else {
      setState(() {
        _typingUsers = [_bot];
      });
    }
    var message = types.TextMessage(
      author: _author,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: randomString(),
      text: _message.text,
    );
    try {
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
      // final updatedMessage = itypes.Message.fromMap(dbMessage).uiMessage!;
      // setState(() {
      //   _messages.insert(0, updatedMessage);
      // });

      await _handleBotResponse(dbMessage['id'] as String);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
        backgroundColor: R.color.deepOrange,
      ));
      setState(() {
        _typingUsers = _typingUsers
            .where((e) => e.id != _bot.id)
            .toList(); // remove bot from typing list
      });
    }

    _isSending = false;
  }

  // // This is the method auto response from the chatbot
  _handleBotResponse(String messageId) async {
    final ApiResult<MessageResponse> apiResult =
        await AppRepository().sendMessageById(_conversation.id, messageId);
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
