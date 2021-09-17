import 'package:bot_toast/bot_toast.dart';
import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:flutter/material.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/modal/user/manual.dart';
import 'package:medical/src/modal/user/secure.dart';
import 'package:medical/src/modal/user/user_model.dart';
import 'package:medical/src/repo/login/login_client.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:medical/src/theme/app_theme.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/modal/error/error_model.dart';

class ProfileController extends StatefulWidget {
  @override
  _ProfileControllerState createState() => _ProfileControllerState();
}

class _ProfileControllerState extends State<ProfileController> {
  SecureModel secureModel;

  void initState() {
    super.initState();
    DartNotificationCenter.subscribe(
        channel: 'user_info_change',
        observer: this,
        onNotification: (_) {
          setState(() {});
        });
    loadData();
    TrackingManager.analytics.setCurrentScreen(screenName: 'Profile');
  }

  loadData() async {
    try {
      BotToast.showLoading();
      secureModel = await UserClient().fetchInfoSecure();
      BotToast.closeAllLoading();
      setState(() {});
    } catch (_) {
      BotToast.closeAllLoading();
    }
  }

  @override
  void dispose() {
    DartNotificationCenter.unsubscribe(
        channel: 'user_info_change', observer: this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = AppSettings.userInfo;
    return Scaffold(
        appBar: CustomAppBar(
          backgroundColor: Color(0xffB1DDDB).withOpacity(0.2),
          title: Text('Hồ sơ',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w600, color: textDark)),
          leadingIcon: IconButton(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              icon: Icon(Icons.arrow_back, color: textDark),
              onPressed: () {
                Navigator.pop(context);
              }),
        ),
        body: Container(
            color: Color(0xffB1DDDB).withOpacity(0.2),
            padding: EdgeInsets.all(16),
            child: Center(
              child: ListView(
                //crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                            color: mainColor,
                            borderRadius: BorderRadius.circular(52)),
                        child: user.imageUrl.url == null
                            ? Icon(Icons.person, size: 104, color: Colors.white)
                            : Image.network(user.imageUrl.url,
                                width: 104, height: 104)),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.fullName,
                              style: TextStyle(
                                  color: textDark,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 8),
                            Text('Mã người dùng: ${user.code ?? '0'}',
                                style: TextStyle(
                                    color: Color(0xff666666),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400)),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  height: 32,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16)),
                                  padding: EdgeInsets.only(left: 16, right: 16),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                          'assets/images/icon_crown.png',
                                          width: 20,
                                          height: 20),
                                      SizedBox(width: 8),
                                      Text('Gói Coaching',
                                          style: TextStyle(
                                              color: textDark,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700))
                                    ],
                                  ),
                                ),
                              ],
                            )
                          ]),
                    ),
                  ]),
                  SizedBox(height: 16),
                  Row(children: [
                    buildItem(Color(0xffD3EFEE), 'Thiết lập mục tiêu',
                        'assets/images/icon_muc_tieu.png', 0),
                    SizedBox(width: 16),
                    buildItem(Color(0xffFEEDDC), 'Nhắc nhở',
                        'assets/images/icon_nhac_nho.png', 1)
                  ]),
                  SizedBox(height: 16),
                  Row(children: [
                    buildItem(Color(0xffFCF8DA), 'Lịch sinh hoạt\ncá nhân',
                        'assets/images/icon_lich.png', 2),
                    SizedBox(width: 16),
                    buildItem(Color(0xffFDE9E9), 'Lịch đo\nđường huyết',
                        'assets/images/icon_lich_do_duong_huyet.png', 3)
                  ]),
                  SizedBox(height: 16),
                  buildAction(
                      'Thông tin cá nhân', 'assets/images/icon_user.png', 0),
                  buildAction(
                      'Hướng dẫn sử dụng', 'assets/images/question.png', 1),
                  buildAction('Bảo mật thông tin',
                      'assets/images/icon_security.png', 2),
                  buildAction(
                      'Liên hệ với DiaB', 'assets/images/icon_contact.png', 3),
                  buildAction('Mật khẩu', 'assets/images/icon_password.png', 4),
                ],
              ),
            )));
  }

  Widget buildItem(Color color, String title, String image, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (index == 0) {
            Navigator.pushNamed(context, '/goal_setting');
          }
          if (index == 2) {
            Navigator.pushNamed(context, '/schedule_activity');
          }
          if (index == 1) {
            Navigator.pushNamed(context, '/reminder');
          }
          if (index == 3) {
            Navigator.pushNamed(context, '/schedule_glucose');
          }
          // if (index == 1 || index == 3) {
          //   Message.showToastMessage(context,
          //       'Tính năng này sẽ được ra mắt trong bản nâng cấp tiếp theo');
          //}
        },
        child: Container(
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(12)),
            padding: EdgeInsets.all(14),
            child: Column(children: [
              Image.asset(image, width: 35, height: 35),
              SizedBox(height: 12),
              Text(title,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: textDark),
                  textAlign: TextAlign.center)
            ])),
      ),
    );
  }

  Widget buildAction(String title, String icon, int index) {
    return GestureDetector(
      onTap: () {
        if (index == 0) {
          if (AppSettings.userInfo.phoneNumber.contains('User') ||
              AppSettings.userInfo.phoneNumber.isEmpty) {
            showPopupUpdatePhone();
          } else {
            Navigator.pushNamed(context, '/profile_info');
          }
        } else if (index == 1) {
          Navigator.pushNamed(context, '/manual');
        } else if (index == 2) {
          Navigator.pushNamed(context, '/manual_detail', arguments: {
            'manual': ManualModel(
                id: '',
                question: 'Bảo mật thông tin',
                answer: secureModel.security)
          });
        } else if (index == 3) {
          Navigator.pushNamed(context, '/contact',
              arguments: {'contact': secureModel});
        } else if (index == 4) {
          Navigator.pushNamed(context, '/change_password');
        }
      },
      child: Container(
          color: Colors.transparent,
          padding: EdgeInsets.only(left: 16, right: 16, top: 20),
          child: Column(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Row(children: [
                  Image.asset(icon, width: 20, height: 20),
                  SizedBox(width: 16),
                  Text(title, style: TextStyle(fontSize: 16))
                ]),
                Icon(Icons.arrow_forward_ios, color: mainColor, size: 16)
              ]),
              SizedBox(height: 20),
              Container(height: 1, color: Colors.grey.withOpacity(0.2))
            ],
          )),
    );
  }

  showPopupUpdatePhone() {
    FocusScope.of(context).unfocus();
    final width = MediaQuery.of(context).size.width;
    TextEditingController textEditingController = TextEditingController();
    textEditingController.text = AppSettings.userInfo.secondPhoneNumber;
    showDialog(
        context: context,
        builder: (context) => Container(
              child: AlertDialog(
                  content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Cập nhật số điện thoại',
                            style: TextStyle(
                                color: textDark,
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                        GestureDetector(
                            child: Icon(Icons.close, color: Color(0xffBEC0C8)),
                            onTap: () {
                              Navigator.pop(context);
                            })
                      ]),
                  SizedBox(height: 16),
                  Container(
                      height: 54,
                      width: width - 36,
                      child: TextField(
                          controller: textEditingController,
                          keyboardType: TextInputType.number,
                          minLines: 1,
                          maxLines: 1,
                          obscureText: false,
                          decoration: InputDecoration(
                            fillColor: textDark,
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color(0xffDDDDDD), width: 1.0),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: mainColor, width: 1.0),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding:
                                EdgeInsets.only(top: 0, left: 16, right: 16),
                            hintText: 'Nhập số điện thoại',
                          ),
                          onChanged: (value) {})),
                  Container(
                    margin: EdgeInsets.only(top: 16),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.pushNamed(context, '/profile_info');
                            },
                            child: Container(
                                height: 48,
                                width: 119,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(200),
                                    color: grayBorder),
                                child: Center(
                                  child: Text('Huỷ',
                                      style: TextStyle(
                                          color: textDark,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600)),
                                )),
                          ),
                          GestureDetector(
                            onTap: () {
                              final phone = textEditingController.text ?? '';
                              if (phone.isEmpty) {
                                Message.showToastMessage(
                                    context, 'Bạn chưa nhập số điện thoại');
                                return;
                              } else {
                                updatePhone(phone);
                              }
                            },
                            child: Container(
                              height: 48,
                              width: 119,
                              decoration: BoxDecoration(
                                  color: red,
                                  borderRadius: BorderRadius.circular(200),
                                  gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.centerRight,
                                      colors: [
                                        greenGradientTop,
                                        greenGradientBottom
                                      ])),
                              child: Center(
                                child: Text('Lưu',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ),
                        ]),
                  ),
                ],
              )),
            ));
  }

  updatePhone(String phone) async {
    try {
      BotToast.showLoading();
      await LoginClient().changePhoneNumber(phone);
      await UserClient().fetchUser();
      Navigator.pop(context);
      Navigator.pushNamed(context, '/profile_info');
      BotToast.closeAllLoading();
    } catch (error) {
      BotToast.closeAllLoading();
      if (error is Error) {
        Message.showToastMessage(context, error.message);
      } else {
        Message.showToastMessage(context, error.toString());
      }
    }
  }
}
