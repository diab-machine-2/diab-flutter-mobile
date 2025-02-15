import 'package:flutter/material.dart';

import '../../../res/R.dart';
import '../../app_setting/app_setting.dart';
import '../../utils/navigator_name.dart';
import '../helper/tracking_manager.dart';

class ConversationUserProfile extends StatefulWidget {
  const ConversationUserProfile({Key? key}) : super(key: key);

  @override
  _ConversationUserProfileState createState() =>
      _ConversationUserProfileState();
}

class _ConversationUserProfileState extends State<ConversationUserProfile> {
  final String title = 'Trợ lý Sống khoẻ diaB';
  final String introductionTitle = 'Giới thiệu';
  final List<String> introductionPoints = [
    'Được thiết kế để cung cấp thông tin và hỗ trợ quản lý sức khoẻ hiệu quả hơn.',
    'Không thay thế bác sĩ chuyên môn hoặc chuyên gia y tế.',
    'Liên hệ với bác sĩ hoặc chuyên gia y tế khi có vấn đề sức khoẻ cần giải quyết.'
  ];
  final String hotlineTitle = 'Hotline hỗ trợ';
  final String hotlineDescription =
      'Trong trường hợp cần trợ giúp, hãy gọi ngay đến Hotline của DiaB 012.3456.789';
  final String buttonText = 'Liên hệ hỗ trợ';

  Future firebaseSetup() async {
    await TrackingManager.analytics.logScreenView(
        screenName: "conversation user profile",
        screenClass: "conversation_user_profile");
    AppSettings.currentScreenName = 'conversation_user_profile';
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
                icon: Icon(Icons.arrow_back, color: R.color.textDark),
                onPressed: () {
                  Navigator.pop(context);
                }),

            backgroundColor: R.color.transparent, //No more green
            elevation: 0.0, //Shadow gone
          ),
          body: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Image.asset(
                  R.drawable.chat_banner_family,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.20),
                      Image.asset(
                        R.drawable.chat_avatar_chatbot_ai_2,
                        width: 120,
                        fit: BoxFit.cover,
                      ),
                      SizedBox(height: 10),
                      Text(
                        title,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'sfpro'),
                      ),
                      SizedBox(height: 16),
                      _buildInfoCard(introductionTitle, introductionPoints,
                          R.drawable.chat_ic_edu),
                      SizedBox(height: 16),
                      _buildInfoCard(hotlineTitle, [hotlineDescription],
                          R.drawable.chat_ic_hotline),
                      SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildCallToAction(),
              ),
            ],
          ),
        ));
  }

  Widget _buildCallToAction() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 5,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text(buttonText),
                    content: Text(hotlineDescription),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Đóng'),
                      ),
                    ],
                  );
                });
          },
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          child: Text(
            buttonText,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ));
  }

  Widget _buildInfoCard(String title, List<String> content, String iconAsset) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Image(image: AssetImage(iconAsset), height: 24),
        SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'sfpro'),
        )
      ]),
      SizedBox(height: 10),
      Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 5,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SizedBox(height: 8),
            ...content.map((text) => _buildBulletPoint(text)).toList(),
          ],
        ),
      )
    ]);
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('•  ', style: TextStyle(fontSize: 16, fontFamily: 'sfpro')),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 16, fontFamily: 'sfpro'),
            ),
          ),
        ],
      ),
    );
  }
}
