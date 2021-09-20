import 'package:bot_toast/bot_toast.dart';
import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/modal/user/motivation_model.dart';
import 'package:medical/src/modal/user/user_model.dart';
import 'package:medical/src/repo/notification/notification_client.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:medical/src/theme/app_theme.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/profile/user_info.dart';
import 'package:medical/src/widget/tabbar/guidline_panel.dart';
import 'package:medical/src/modal/error/error_model.dart';

class HomeHeader extends StatefulWidget {
  @override
  _HomeHeaderState createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  bool isChoose = false;

  int notificationCount = 0;
  MotivationModel motivation;

  @override
  void initState() {
    super.initState();

    DartNotificationCenter.subscribe(
        channel: 'user_info_change',
        observer: this,
        onNotification: (_) {
          setState(() {});
        });

    DartNotificationCenter.subscribe(
        channel: 'reload_notification',
        observer: this,
        onNotification: (_) {
          loadNotification();
        });
    DartNotificationCenter.subscribe(
        channel: 'read_notification_success',
        observer: this,
        onNotification: (_) {
          loadNotification();
        });

    DartNotificationCenter.subscribe(
        channel: 'motivation_change',
        observer: this,
        onNotification: (_) {
          loadMotivation();
        });
    loadNotification();
    loadMotivation();
  }

  @override
  void dispose() {
    DartNotificationCenter.unsubscribe(
        channel: 'user_info_change', observer: this);
    DartNotificationCenter.unsubscribe(
        channel: 'reload_notification', observer: this);
    DartNotificationCenter.unsubscribe(
        channel: 'read_notification_success', observer: this);
    super.dispose();
  }

  loadNotification() async {
    notificationCount = await NotificationClient().fetchNotificationCount();
    setState(() {});
  }

  loadMotivation() async {
    final result = await UserClient().fetchMotivationDiary(1);
    motivation = result.models.length == 0 ? null : result.models.first;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final user = AppSettings.userInfo;
    return SafeArea(
        bottom: false,
        child: Container(
            padding: EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, NavigatorName.profile);
                      },
                      child: Container(
                        color: R.color.transparent,
                        child: Row(children: [
                          Stack(
                              alignment: AlignmentDirectional.bottomEnd,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(right: 4, bottom: 4),
                                  child: Container(
                                      clipBehavior: Clip.hardEdge,
                                      decoration: BoxDecoration(
                                          color: R.color.white,
                                          borderRadius:
                                              BorderRadius.circular(21)),
                                      child: user.imageUrl.url == null
                                          ? Icon(Icons.person,
                                              size: 42, color: R.color.mainColor)
                                          : Image.network(user.imageUrl.url,
                                              width: 42, height: 42)),
                                ),
                                Image.asset(R.drawable.icon_crown,
                                    width: 20, height: 20)
                              ]),
                          SizedBox(width: 8),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(user.fullName.trim(),
                                    style: TextStyle(
                                        color: R.color.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700)),
                                SizedBox(height: 4),
                                Text('Thành viên cơ bản',
                                    style: TextStyle(
                                        color: R.color.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400))
                              ]),
                        ]),
                      ),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            //showAction(context);
                            setState(() {
                              isChoose = !isChoose;
                            });
                          },
                          child: isChoose
                              ? Image.asset(
                                  R.drawable.ic_book_question_selected,
                                  width: 24,
                                  height: 24)
                              : Image.asset(R.drawable.ic_book_question,
                                  width: 24, height: 24),
                        ),
                        SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, NavigatorName.notification);
                          },
                          child: Container(
                            padding: EdgeInsets.all(4),
                            color: R.color.transparent,
                            child: Image.asset(
                                notificationCount > 0
                                    ? R.drawable.ic_bell_dot
                                    : R.drawable.ic_bell,
                                width: 24,
                                height: 24),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                // SizedBox(height: 30),
                !isChoose
                    ? SizedBox()
                    : (motivation != null
                        ? Padding(
                            padding: EdgeInsets.only(top: 16),
                            child: Text(motivation.content,
                                style: TextStyle(
                                    color: R.color.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400)),
                          )
                        : Column(children: [
                            Padding(
                              padding: EdgeInsets.only(top: 16),
                              child: Text(
                                  'Điều gì tạo động lực sống khỏe hơn mỗi ngày cho bạn? Hãy chia sẻ cùng diaB nhé!',
                                  style: TextStyle(
                                      color: R.color.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400)),
                            ),
                            SizedBox(height: 8),
                            Center(
                              child: GestureDetector(
                                onTap: () {
                                  _showDialogUpdateMotivation(null);
                                },
                                child: Container(
                                    height: 32,
                                    decoration: BoxDecoration(
                                        color: R.color.white,
                                        borderRadius:
                                            BorderRadius.circular(16)),
                                    padding:
                                        EdgeInsets.only(left: 16, right: 16),
                                    child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text('Viết động lực',
                                              style: TextStyle(
                                                  color: R.color.mainColor,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600)),
                                          SizedBox(width: 4),
                                          Image.asset(
                                              R.drawable.icon_arrow_right,
                                              width: 24,
                                              height: 24)
                                        ])),
                              ),
                            )
                          ]))
              ],
            )));
  }

  _showDialogUpdateMotivation(MotivationModel model) {
    showDialog(
        context: context,
        builder: (context) => Container(
                child: AlertDialog(
              content: MotivationPopup(
                model: model,
                callback: (data) {
                  if (data.id == null) {
                    addMotivation(data);
                  }
                },
              ),
            )));
  }

  addMotivation(MotivationModel model) async {
    try {
      BotToast.showLoading();
      await UserClient().inputMotivationDiary(model.content);
      await loadMotivation();
      BotToast.closeAllLoading();
    } catch (e, _) {
      BotToast.closeAllLoading();
      if (e is Error) {
        Message.showToastMessage(context, e.message);
      } else {
        Message.showToastMessage(context, e.toString());
      }
    }
  }
}
