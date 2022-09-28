import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_observer/Observer.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:loadmore/loadmore.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/bloc/notification/notification_bloc.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:medical/src/modal/notification/notification_model.dart';
import 'package:medical/src/modal/notification/notification_type.dart';
import 'package:medical/src/repo/notification/notification_client.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/components/load_more.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widgets/network_image_widget.dart';

import '../../modal/notification/notification_list_model.dart';

class NotificationUnreadController extends StatefulWidget {
  const NotificationUnreadController({required this.isRemovealbe});

  final bool? isRemovealbe;

  @override
  NotificationUnreadControllerState createState() =>
      NotificationUnreadControllerState();
}

class NotificationUnreadControllerState
    extends State<NotificationUnreadController>
    with AutomaticKeepAliveClientMixin<NotificationUnreadController>, Observer {
  @override
  bool get wantKeepAlive => true;

  late BuildContext currentContext;

  int page = 1;
  bool hasMore = false;
  bool isLoading = false;

  List<String?> readIds = [];
  List<NotificationListModel> model = [];

  @override
  void initState() {
    super.initState();
    //  if (widget.isRemovealbe != true) {
    Observable.instance.addObserver(this);
    //  }
  }

  @override
  void update(
      Observable observable, String? notifyName, Map<dynamic, dynamic>? map) {
    if (notifyName == 'read_notification') {
      NotificationListModel notification = map?['notification'];
      if (widget.isRemovealbe == null) {
        setState(() {
          readIds.add(notification.id);
        });
      } else if (widget.isRemovealbe == false) {
        setState(() {
          model.removeWhere((element) => element.id == notification.id);
        });
      } else if (widget.isRemovealbe == true) {
        setState(() {
          notification.isRead = true;
          model.add(notification);
        });
      }
    }
  }

  @override
  void dispose() {
    Observable.instance.removeObserver(this);
    super.dispose();
  }

  Future<bool> _loadMore() async {
    if (isLoading || !hasMore) {
      return true;
    } else {
      isLoading = true;
      BlocProvider.of<NotificationBloc>(currentContext).add(
        FetchNotification(isRead: widget.isRemovealbe, page: page),
      );
    }
    return true;
  }

  Future<bool> refresh() async {
    page = 1;
    BlocProvider.of<NotificationBloc>(currentContext).add(
      FetchNotification(isRead: widget.isRemovealbe, page: page),
    );
    return true;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider<NotificationBloc>(
      create: (context) => NotificationBloc(),
      child: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (BuildContext context, NotificationState state) {
          currentContext = context;

          if (state is NotificationInitial) {
            Future.delayed(Duration(milliseconds: 10));
            BotToast.showLoading();
            BlocProvider.of<NotificationBloc>(context).add(
              FetchNotification(isRead: widget.isRemovealbe, page: page),
            );
          }
          if (state is NotificationError) {
            Message.showToastMessage(context, state.message);
          }
          if (state is NotificationLoaded) {
            BotToast.closeAllLoading();
            model = state.model?.models ?? [];
            hasMore = state.model?.hasMore ?? false;
            if (hasMore) {
              page += 1;
            }
            isLoading = false;
          }
          return RefreshIndicator(
            onRefresh: refresh,
            child: Scaffold(
              body: model == null
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : _buildNotificationList(model, state),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationList(
      List<NotificationListModel> model, NotificationState state) {
    return LoadMore(
      onLoadMore: _loadMore,
      isFinish: !hasMore,
      whenEmptyLoad: false,
      delegate: const CustomLoadMoreDelegate(),
      textBuilder: DefaultLoadMoreTextBuilder.english,
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.only(bottom: 32, top: 16),
        itemCount: model.isEmpty ? 1 : model.length,
        separatorBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Container(color: R.color.color0xffE5E5E5, height: 1),
          );
        },
        itemBuilder: (BuildContext context, int index) {
          if (state is NotificationInitial) {
            return Container();
          } else if (model.isNotEmpty != true) {
            return Container(
              height: MediaQuery.of(context).size.height - 190,
              child: Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Image.asset(R.drawable.img_notification_empty,
                      width: 235, height: 172),
                  const SizedBox(height: 24),
                  Text(
                    R.string.no_notification.tr(),
                  )
                ]),
              ),
            );
          } else {
            final NotificationListModel notificationModel = model[index];
            bool? isRead = notificationModel.isRead;
            if (!notificationModel.isRead! && (widget.isRemovealbe != true)) {
              final selected = readIds
                  .indexWhere((element) => element == notificationModel.id);
              if (selected != -1) {
                isRead = true;
              }
            }

            return GestureDetector(
              onTap: () {
                _onTapNotify(notificationModel);
              },
              child: Slidable(
                actionPane: const SlidableDrawerActionPane(),
                secondaryActions: widget.isRemovealbe != true
                    ? []
                    : [
                        IconSlideAction(
                          color: R.color.color0xffFF5552,
                          iconWidget: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(R.drawable.ic_trash2,
                                    width: 24, height: 24),
                                const SizedBox(height: 4),
                                Text(R.string.detele_notificaiton.tr(),
                                    style: TextStyle(
                                        color: R.color.white,
                                        fontWeight: FontWeight.w500),
                                    textAlign: TextAlign.center),
                              ]),
                          onTap: () {
                            _showDialogDelete(context, notificationModel);
                          },
                        ),
                      ],
                child: _buildSingleNotification(notificationModel, isRead),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildSingleNotification(NotificationListModel model, bool? isRead) {
    return Container(
      color: R.color.transparent,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: NetWorkImageWidget(
                  imageUrl: model.imageUrl!, width: 40, height: 40),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            model.title!,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: R.color.black),
                          ),
                        ),
                        if (isRead != true)
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: R.color.greenGradientTop,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          )
                      ],
                    ),
                  ),
                  Html(data: model.topic ?? ''),
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      convertToUTC(
                          model.sentDateTime ?? 0, 'HH:mm - dd/MM/yyyy'),
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: R.color.gray),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _onTapNotify(NotificationListModel notificationModel) {
    if ((widget.isRemovealbe != true) && !notificationModel.isRead!) {
      Observable.instance.notifyObservers([],
          notifyName: "read_notification",
          map: {'notification': notificationModel});
      NotificationClient().readNotification(
          notificationModel.id,
          notificationModel.notificationId,
          AppSettings.userInfo!.id,
          notificationModel.notificationType.toString(),
          true);
    }
    if (notificationModel.calendarId == null) {
      switch (notificationModel.actionType) {
        case NotificationActionType.redirect_to_activity_tab:
          Navigator.pushReplacementNamed(context, NavigatorName.tabbar,
              arguments: {
                'id': notificationModel.id,
                'isRedirectFromNotification': true,
              });
          break;
        case NotificationActionType.redirect_to_url:
          Navigator.pushNamed(context, NavigatorName.notification_detail,
              arguments: {
                'id': notificationModel.notificationId ?? '',
                'communicationId': notificationModel.id
              });
          break;
        case NotificationActionType.add_reminder:
          Navigator.pushNamed(context, NavigatorName.add_reminder,
              arguments: {'type': 'update', 'id': notificationModel.id});
          break;
        case NotificationActionType.add_blood_sugar:
          Navigator.pushNamed(context, NavigatorName.add_blood_sugar,
              arguments: {'type': 'input', 'id': notificationModel.id});
          break;
        case NotificationActionType.none:
          break;
        case NotificationActionType.share_profile:
          break;
        case NotificationActionType.redirect_date_detail:
          break;
        case NotificationActionType.redirect_survey:
          break;
        case NotificationActionType.register_referral_success:
          Navigator.pushNamed(context, NavigatorName.voucher_list,
              arguments: {'type': 'input', 'voucherId': notificationModel.id});
          break;
      }
    }
  }

  _showDialogDelete(BuildContext context, NotificationListModel model) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(0),
          content: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(R.drawable.ic_earse, width: 64, height: 64),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        R.string.mes_detele_notificaiton.tr(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: R.color.textDark,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(R.string.mes_detele_notificaiton.tr(),
                          textAlign: TextAlign.center,
                          style: R.style.normalTextStyle),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  height: 43,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(200),
                                      color: R.color.grayBorder),
                                  child: Center(
                                    child: Text(
                                      R.string.later.tr(),
                                      style: TextStyle(
                                          color: R.color.textDark,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  _delete(model);
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  height: 43,
                                  decoration: BoxDecoration(
                                    color: R.color.red,
                                    borderRadius: BorderRadius.circular(200),
                                  ),
                                  child: Center(
                                    child: Text(
                                      R.string.delete.tr(),
                                      style: TextStyle(
                                          color: R.color.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ]),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                    icon: Icon(Icons.close, color: R.color.color0xffBEC0C8),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
              )
            ],
          ),
        );
      },
    );
  }

  _delete(NotificationListModel model) async {
    try {
      BotToast.showLoading();
      await NotificationClient().deleteNotification(model.notificationId, model.messageType);
      refresh();
      BotToast.closeAllLoading();
    } catch (e, _) {
      BotToast.closeAllLoading();
      if (e is Error) {
        Message.showToastMessage(context, e.message);
      } else {
        Message.showToastMessage(
          context,
          e.toString(),
        );
      }
    }
  }
}
