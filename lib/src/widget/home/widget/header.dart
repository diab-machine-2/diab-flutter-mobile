import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_observer/Observer.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:medical/src/modal/user/motivation_model.dart';
import 'package:medical/src/repo/notification/notification_client.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/profile/user_info.dart';
import 'package:medical/src/widgets/qr_scan_widget.dart';
import 'package:medical/src/widgets/share_profile_popup.dart';

class HomeHeader extends StatefulWidget {
  const HomeHeader({this.sharedCode});
  final String? sharedCode;
  @override
  _HomeHeaderState createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> with Observer {
  bool isChoose = false;

  int? notificationCount = 0;
  MotivationModel? motivation;

  @override
  void initState() {
    super.initState();
    Observable.instance.addObserver(this);
    initData();
  }

  @override
  void update(Observable observable, String? notifyName, Map<dynamic, dynamic>? map) {
    if (notifyName == 'user_info_change') {
      setState(() {});
    }
    if (notifyName == 'reload_notification' || notifyName == 'read_notification_success') {
      loadNotification();
    }
    if (notifyName == 'motivation_change') {
      loadMotivation();
    }
  }

  @override
  void dispose() {
    Observable.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> initData() async {
    await Future.wait([
      loadNotification(),
      loadMotivation(),
    ]);
    if (widget.sharedCode?.isNotEmpty == true) {
      ShareProfilePopup.instance.onHasSharedCode(context: context, code: widget.sharedCode.toString());
    }
  }

  Future<void> loadNotification() async {
    notificationCount = await NotificationClient().fetchNotificationCount();
    setState(() {});
  }

  Future<void> loadMotivation() async {
    final result = await UserClient().fetchMotivationDiary(1);
    motivation = result.models.isEmpty ? null : result.models.first;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final user = AppSettings.userInfo!;
    return SafeArea(
        bottom: false,
        child: Container(
            padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, NavigatorName.profile);
                        },
                        child: Container(
                          color: R.color.transparent,
                          child: Row(children: [
                            Stack(alignment: AlignmentDirectional.bottomEnd, children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 4, bottom: 4),
                                child: Container(
                                    clipBehavior: Clip.hardEdge,
                                    decoration:
                                        BoxDecoration(color: R.color.white, borderRadius: BorderRadius.circular(21)),
                                    child: user.imageUrl!.url == null
                                        ? Icon(Icons.person, size: 42, color: R.color.mainColor)
                                        : Image.network(
                                            user.imageUrl!.url ?? '',
                                            width: 42,
                                            height: 42,
                                            errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                                              return Icon(Icons.person, size: 42, color: R.color.mainColor);
                                            },
                                          )),
                              ),
                              Container(
                                width: 20,
                                height: 20,
                                padding: const EdgeInsets.all(4),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: R.color.white,
                                ),
                                child: Image.asset(R.drawable.ic_crown_green),
                              )
                            ]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(user.fullName!.trim(),
                                    style: TextStyle(
                                      color: R.color.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    )),
                                const SizedBox(height: 4),
                                Text(R.string.thanh_vien_co_ban.tr(),
                                    style: TextStyle(color: R.color.white, fontSize: 14, fontWeight: FontWeight.w400))
                              ]),
                            ),
                          ]),
                        ),
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
                          child: Image.asset(R.drawable.ic_direct_chat, width: 24, height: 24),
                          // isChoose
                          //     ? Image.asset(R.drawable.ic_book_question_selected, width: 24, height: 24)
                          //     : Image.asset(R.drawable.ic_book_question, width: 24, height: 24),
                        ),
                        const SizedBox(width: 12),
                        InkWell(
                          onTap: () async {
                            final scanedResult = await NavigationUtil.navigatePage(
                              context,
                              const QRScanWidget(),
                            );
                            if (scanedResult is String) {
                              ShareProfilePopup.instance.onHasSharedCode(context: context, code: scanedResult);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            color: R.color.transparent,
                            child: Image.asset(
                              R.drawable.ic_qr_scan,
                              color: R.color.white,
                              width: 24,
                              height: 24,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, NavigatorName.notification);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            color: R.color.transparent,
                            child: Image.asset(notificationCount! > 0 ? R.drawable.ic_bell_dot : R.drawable.ic_bell,
                                width: 24, height: 24),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                // SizedBox(height: 30),
                if (!isChoose)
                  const SizedBox()
                else
                  motivation != null
                      ? Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(motivation!.content!,
                              style: TextStyle(color: R.color.white, fontSize: 14, fontWeight: FontWeight.w400)),
                        )
                      : Column(children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Text(R.string.share_with_diab.tr(),
                                style: TextStyle(color: R.color.white, fontSize: 14, fontWeight: FontWeight.w400)),
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                _showDialogUpdateMotivation(null);
                              },
                              child: Container(
                                  height: 32,
                                  decoration:
                                      BoxDecoration(color: R.color.white, borderRadius: BorderRadius.circular(16)),
                                  padding: const EdgeInsets.only(left: 16, right: 16),
                                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                                    Text(R.string.viet_dong_luc.tr(),
                                        style: TextStyle(
                                            color: R.color.mainColor, fontSize: 15, fontWeight: FontWeight.w600)),
                                    const SizedBox(width: 4),
                                    Image.asset(R.drawable.ic_arrow_right, width: 24, height: 24)
                                  ])),
                            ),
                          )
                        ])
              ],
            )));
  }

  _showDialogUpdateMotivation(MotivationModel? model) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: MotivationPopup(
                model: model,
                callback: (data) {
                  if (data.id == null) {
                    addMotivation(data);
                  }
                },
              ),
            ));
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
