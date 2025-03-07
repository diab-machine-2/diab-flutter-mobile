import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../res/R.dart';
import '../../app_setting/app_setting.dart';
import '../helper/tracking_manager.dart';

class ConversationUserProfile extends StatefulWidget {
  const ConversationUserProfile({Key? key}) : super(key: key);

  @override
  _ConversationUserProfileState createState() =>
      _ConversationUserProfileState();
}

class _ConversationUserProfileState extends State<ConversationUserProfile> {
  final String title = 'Trợ lý Sống khoẻ Diab';
  final String introductionTitle = 'Giới thiệu';
  final List<String> introductionPoints = [
    'Được thiết kế để cung cấp thông tin và hỗ trợ quản lý sức khoẻ hiệu quả hơn.',
    'Không thay thế bác sĩ chuyên môn hoặc chuyên gia y tế.',
    'Liên hệ với bác sĩ hoặc chuyên gia y tế khi có vấn đề sức khoẻ cần giải quyết.'
  ];
  final String hotlineTitle = 'Hotline hỗ trợ';
  final String hotlineDescription =
      'Trong trường hợp cần trợ giúp, hãy gọi ngay đến Hotline của DiaB 0931888832';
  final String buttonText = 'Hỗ trợ';
  final String phoneNumber = '0931888832';
  final _coverHeightRate = 0.22; // -> 22% of screen height

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
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height:
                    MediaQuery.of(context).size.height * _coverHeightRate + 80,
                // color: R.color.blue,
                child: Stack(
                  children: [
                    Image.asset(
                      R.drawable.chat_banner_family,
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      width: double.infinity,
                      height:
                          MediaQuery.of(context).size.height * _coverHeightRate,
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        // color: R.color.red,
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
                                      border: Border.all(
                                          color: Colors.white, width: 1),
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                                              R.drawable
                                                  .chat_avatar_bagged_star,
                                              width: 12),
                                        ]),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              title,
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'sfpro'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  // color: R.color.yellow,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 16),
                      _buildInfoCard(introductionTitle, introductionPoints,
                          R.drawable.chat_ic_edu),
                      SizedBox(height: 16),
                      _buildInfoCard(hotlineTitle, [hotlineDescription],
                          R.drawable.chat_ic_hotline),
                    ],
                  ),
                ),
              ),
              Container(
                width: double.infinity,
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
          onPressed: () async {
            final Uri launchUri = Uri(
              scheme: 'tel',
              path: phoneNumber,
            );
            if (await canLaunch(launchUri.toString())) {
              await launch(launchUri.toString());
            } else {
              throw 'Could not launch $phoneNumber';
            }
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
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Color(0x042B2814).withOpacity(0.1),
              blurRadius: 6,
              spreadRadius: 1,
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
