import 'dart:ui';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/notification/notification_model.dart';

class Message {
  static showToastMessage(BuildContext context, String? title, {int seconds = 2}) {
    final FToast fToast = FToast();
    fToast.init(context);
    Future.delayed(Duration.zero, () async {
      fToast.showToast(
        child: ToastMessage(title: title),
        gravity: ToastGravity.BOTTOM,
        toastDuration: Duration(seconds: seconds),
      );
    });
  }

  static showNotificationMessage({NotificationModel? model, NotificationCallback? callback}) {
    BotToast.showCustomNotification(
        animationDuration: const Duration(milliseconds: 200),
        animationReverseDuration: const Duration(milliseconds: 200),
        duration: const Duration(seconds: 3),
        toastBuilder: (cancel) {
          return NotificationMessage(
            model: model,
            callback: (model) {
              cancel();
              callback!(model);
            },
          );
        });
  }
}

class ToastMessage extends StatelessWidget {
  const ToastMessage({this.title});
  final String? title;
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 80),
      child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: R.color.mainColor, borderRadius: BorderRadius.circular(16), boxShadow: [
            BoxShadow(
              color: R.color.black,
              blurRadius: 3,
              offset: const Offset(0, 0),
            )
          ]),
          child: Row(
            children: [
              Container(
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
                child: Image.asset(
                  R.drawable.ic_app,
                  width: 40,
                  height: 40,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(title!, style: TextStyle(color: R.color.white, fontSize: 16)),
              ),
            ],
          )),
    );
  }
}

typedef NotificationCallback = Function(NotificationModel?);

class NotificationMessage extends StatefulWidget {
  final NotificationCallback? callback;
  final NotificationModel? model;

  const NotificationMessage({Key? key, this.model, this.callback}) : super(key: key);

  @override
  _NotificationMessage createState() => _NotificationMessage();
}

class _NotificationMessage extends State<NotificationMessage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 18, right: 18),
      child: GestureDetector(
        onTap: () {
          widget.callback!(widget.model);
        },
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: R.color.white, borderRadius: BorderRadius.circular(16), boxShadow: [
                BoxShadow(
                  color: R.color.grey.withOpacity(0.5),
                  blurRadius: 1,
                  offset: const Offset(0, 2),
                )
              ]),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
                    child: Image.asset(
                      R.drawable.ic_app,
                      width: 40,
                      height: 40,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: widget.model!.body!.isEmpty
                          ? [
                              Text(
                                widget.model!.title!,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: R.color.black, fontSize: 16, fontWeight: FontWeight.w500),
                                maxLines: 2,
                              )
                            ]
                          : [
                              Text(
                                widget.model!.title!,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: R.color.black, fontSize: 16, fontWeight: FontWeight.w500),
                                maxLines: 2,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.model!.body!,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: R.color.black, fontSize: 14, fontWeight: FontWeight.w400),
                                maxLines: 2,
                              )
                            ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
