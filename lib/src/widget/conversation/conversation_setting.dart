import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/utils/app_log.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/conversation/conversation_comon.dart'
    as itypes;

import '../../../res/R.dart';
import '../../app_setting/app_setting.dart';
import '../helper/show_message.dart';
import '../helper/tracking_manager.dart';

class ConversationSetting extends StatefulWidget {
  final itypes.Conversation conversation;
  const ConversationSetting({Key? key, required this.conversation})
      : super(key: key);

  @override
  _ConversationSettingState createState() => _ConversationSettingState();
}

class _ConversationSettingState extends State<ConversationSetting> {
  bool _isLoadingDelete = false;

  @override
  void initState() {
    super.initState();
    firebaseSetup();
  }

  Future firebaseSetup() async {
    await TrackingManager.analytics.logScreenView(
        screenName: "conversation_setting",
        screenClass: "conversation_setting");
    AppSettings.currentScreenName = 'conversation_setting';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: R.color.backgroundColor,
            appBar: AppBar(
              leading: IconButton(
                  splashColor: R.color.transparent,
                  highlightColor: R.color.transparent,
                  icon: Icon(Icons.arrow_back, color: R.color.white),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              title: Transform(
                  transform: Matrix4.translationValues(-20, 0.0, 0.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      R.string.conversation_setting_title.tr(),
                      style: TextStyle(
                          color: R.color.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600),
                    ),
                  )),
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
              elevation: 0.0, //Shadow gone
            ),
            body: Column(children: [
              Container(
                // color: R.color.red,
                margin: EdgeInsets.only(top: 32, bottom: 16),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: R.color.white,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Image.asset(
                              R.drawable.chat_avatar_chatbot_ai_3,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          width: 100,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 1),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: 1),
                              color: R.color.mainColor,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  blurRadius: 5,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Trợ lý AI',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w300,
                                        fontFamily: 'sfpro'),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(width: 4),
                                  Image.asset(
                                      R.drawable.chat_avatar_bagged_star,
                                      width: 12),
                                ]),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      widget.conversation.title,
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'sfpro'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Column(
                children: [
                  Container(
                      decoration: BoxDecoration(color: R.color.white),
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: R.color.transparent,
                              elevation: 0.0),
                          onPressed: () => {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        titleTextStyle: TextStyle(
                                            color: R.color.black,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                        title: Text(R.string
                                            .conversation_setting_delete_title
                                            .tr()),
                                        actions: [
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: Text(
                                                R.string
                                                    .conversation_setting_delete_btn_cancel
                                                    .tr(),
                                                style: TextStyle(
                                                    color: R.color.textDark,
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )),
                                          TextButton(
                                              onPressed: () =>
                                                  _handleDeleteConversation(
                                                      widget.conversation.id),
                                              child: Container(
                                                width: 130,
                                                child: Row(
                                                  children: [
                                                    (_isLoadingDelete)
                                                        ? SpinKitCircle(
                                                            color: R.color.red,
                                                            size: 16,
                                                          )
                                                        : Container(),
                                                    SizedBox(width: 2),
                                                    Text(
                                                      R.string
                                                          .conversation_setting_delete_btn_delete
                                                          .tr(),
                                                      style: TextStyle(
                                                          color: R.color.red,
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ],
                                                ),
                                              )),
                                        ],
                                      );
                                    })
                              },
                          child: ListTile(
                            title: Text(
                                R.string.conversation_setting_action_delete
                                    .tr(),
                                style: TextStyle(color: R.color.red)),
                            leading: Icon(Icons.delete, color: R.color.red),
                          )))
                ],
              ),
            ])));
  }

  void _handleDeleteConversation(conversationId) async {
    if (_isLoadingDelete) return;
    setState(() {
      _isLoadingDelete = true;
    });
    final apiResult = await AppRepository().deleteConversation(conversationId);
    apiResult.when(
        success: (data) => {
              // Console.log('Success: $data'),
              setState(() {
                _isLoadingDelete = false;
              }),
              Message.showToastMessage(
                  context, R.string.conversation_setting_delete_success.tr()),
              Navigator.pushReplacementNamed(
                  context, NavigatorName.conversation_chatbot_ai)
            },
        failure: (error) => {
              setState(() {
                _isLoadingDelete = false;
              }),
              Console.log('Error: $error'),
            });
  }
}
