import 'package:flutter/material.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/utils/app_log.dart';

import '../../../res/R.dart';
import '../../app_setting/app_setting.dart';
import '../helper/tracking_manager.dart';

class ConversationSetting extends StatefulWidget {
  const ConversationSetting({Key? key}) : super(key: key);

  @override
  _ConversationSettingState createState() => _ConversationSettingState();
}

class _ConversationSettingState extends State<ConversationSetting> {
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
    final arguments = (ModalRoute.of(context)!.settings.arguments ?? {}) as Map;
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
              title: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Tuỳ chọn trò chuyện',
                  style: TextStyle(
                      color: R.color.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600),
                ),
              ),
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
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(color: R.color.white),
                  child: Align(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Image.asset(
                            R.drawable.chat_avatar_chatbot_ai_2,
                            width: 120,
                            fit: BoxFit.cover,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Hỏi đáp sống khoẻ',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'sfpro'),
                          ),
                        ]),
                  )),
              SizedBox(height: 16),
              ListView(
                shrinkWrap: true,
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
                                        title: Text('Xoá lịch sử trò chuyện'),
                                        content: Text(
                                            'Bạn có chắc chắn muốn xoá lịch sử trò chuyện không?'),
                                        actions: [
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: Text('Hủy')),
                                          TextButton(
                                              onPressed: () =>
                                                  _handleDeleteConversation(
                                                      arguments[
                                                          'conversationId']),
                                              child: Text(
                                                  'Xoá lịch sử trò chuyện')),
                                        ],
                                      );
                                    })
                              },
                          child: ListTile(
                            title: Text('Xoá lịch sử trò chuyện',
                                style: TextStyle(color: R.color.red)),
                            leading: Icon(Icons.delete, color: R.color.red),
                          )))
                ],
              ),
            ])));
  }

  void _handleDeleteConversation(conversationId) async {
    final apiResult = await AppRepository().deleteConversation(conversationId);
    apiResult.when(
        success: (data) => {
              Console.log('Success: $data'),
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  padding: EdgeInsets.all(8),
                  content: Text('Xoá lịch sử trò chuyện thành công!'),
                  backgroundColor: Colors.red,
                ),
              ),
              Navigator.popUntil(context, (route) => route.isFirst)
            },
        failure: (error) => {
              Console.log('Error: $error'),
            });
  }
}
