import 'package:bot_toast/bot_toast.dart';
import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:loadmore/loadmore.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/bloc/notification/notification_bloc.dart';
import 'package:medical/src/modal/notification/notification_model.dart';
import 'package:medical/src/repo/notification/notification_client.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:medical/src/theme/app_theme.dart';
import 'package:medical/src/widget/components/load_more.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/notification_manager.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/modal/error/error_model.dart';

class NotificationController extends StatefulWidget {
  final bool isRead;
  NotificationController({Key key, @required this.isRead}) : super(key: key);
  @override
  NotificationControllerState createState() => NotificationControllerState();
}

class NotificationControllerState extends State<NotificationController>
    with AutomaticKeepAliveClientMixin<NotificationController> {
  @override
  bool get wantKeepAlive => true;

  BuildContext currentContext;

  int page = 1;
  bool hasMore = false;
  bool isLoading = false;

  List<String> readIds = [];

  @override
  void initState() {
    super.initState();
    if (widget.isRead == null || !widget.isRead) {
      DartNotificationCenter.subscribe(
        channel: 'read_notification',
        observer: this,
        onNotification: (data) {
          setState(() {
            readIds.add(data);
          });
        },
      );
    }
  }

  @override
  void dispose() {
    DartNotificationCenter.unsubscribe(
        channel: 'read_notification', observer: this);
    super.dispose();
  }

  Future<bool> _loadMore() async {
    if (isLoading || !hasMore) {
      return true;
    } else {
      isLoading = true;
      BlocProvider.of<NotificationBloc>(currentContext)
          .add(FetchNotification(isRead: widget.isRead, page: page));
    }
    return true;
  }

  Future<bool> refresh() async {
    page = 1;
    BlocProvider.of<NotificationBloc>(currentContext)
        .add(FetchNotification(isRead: widget.isRead, page: page));
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
          List<NotificationModel> model;
          if (state is NotificationInitial) {
            BlocProvider.of<NotificationBloc>(context)
                .add(FetchNotification(isRead: widget.isRead, page: page));
          }
          if (state is NotificationError) {
            Message.showToastMessage(context, state.message);
          }
          if (state is NotificationLoaded) {
            model = state.model.models;
            hasMore = state.model.hasMore;
            if (hasMore) {
              page += 1;
            }
            isLoading = false;
          }
          return RefreshIndicator(
              onRefresh: refresh,
              child: Scaffold(
                body: model == null
                    ? Center(child: CircularProgressIndicator())
                    : Container(
                        child: LoadMore(
                            onLoadMore: _loadMore,
                            isFinish: !hasMore,
                            whenEmptyLoad: false,
                            delegate: CustomLoadMoreDelegate(),
                            textBuilder: DefaultLoadMoreTextBuilder.english,
                            child: ListView.separated(
                              shrinkWrap: true,
                              padding: EdgeInsets.only(bottom: 32, top: 16),
                              itemCount: model.length == 0 ? 1 : model.length,
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                return Padding(
                                    padding:
                                        EdgeInsets.only(left: 16, right: 16),
                                    child: Container(
                                        color: Color(0xffE5E5E5), height: 1));
                              },
                              itemBuilder: (BuildContext context, int index) {
                                if (model.length == 0) {
                                  return Container(
                                    height: MediaQuery.of(context).size.height -
                                        190,
                                    child: Center(
                                      child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Image.asset(
                                                'assets/images/notification_empty.png',
                                                width: 235,
                                                height: 172),
                                            SizedBox(height: 24),
                                            Text('Không có thông báo nào')
                                          ]),
                                    ),
                                  );
                                } else {
                                  bool isRead = model[index].isRead;

                                  if (!model[index].isRead &&
                                      (widget.isRead == null ||
                                          !widget.isRead)) {
                                    final selected = readIds.indexWhere(
                                        (element) =>
                                            element == model[index].id);
                                    if (selected != -1) {
                                      isRead = true;
                                    }
                                  }

                                  return GestureDetector(
                                    onTap: () {
                                      if ((widget.isRead == null ||
                                              !widget.isRead) &&
                                          !model[index].isRead) {
                                        DartNotificationCenter.post(
                                            channel: 'read_notification',
                                            options: model[index].id);
                                        NotificationClient().readNotification(
                                            model[index].id,
                                            AppSettings.userInfo.id,
                                            model[index].notificationType,
                                            true);
                                      }

                                      if (model[index].notificationType == 1) {
                                        Navigator.pushNamed(
                                            context, '/notification_detail',
                                            arguments: {'id': model[index].id});
                                      } else if (model[index]
                                              .notificationType ==
                                          2) {
                                        Navigator.pushNamed(
                                            context, '/add_reminder',
                                            arguments: {
                                              'type': 'update',
                                              'id': model[index].id
                                            });
                                      } else if (model[index]
                                              .notificationType ==
                                          3) {
                                        Navigator.pushNamed(
                                            context, '/add_bloodSugar',
                                            arguments: {
                                              'type': 'input',
                                              'id': null
                                            });
                                      }
                                    },
                                    child: Slidable(
                                        actionPane: SlidableDrawerActionPane(),
                                        secondaryActions: widget.isRead ==
                                                    null ||
                                                !widget.isRead
                                            ? []
                                            : [
                                                IconSlideAction(
                                                  color: Color(0xffFF5552),
                                                  iconWidget: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Image.asset(
                                                            'assets/images/icon_trash2.png',
                                                            width: 24,
                                                            height: 24),
                                                        SizedBox(height: 4),
                                                        Text('Xoá\nthông báo',
                                                            style: TextStyle(
                                                                color: R.color
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                            textAlign: TextAlign
                                                                .center),
                                                      ]),
                                                  onTap: () {
                                                    _showDialogDelete(
                                                        context, model[index]);
                                                  },
                                                ),
                                              ],
                                        child: Container(
                                          color: R.color.transparent,
                                          child: Padding(
                                              padding: EdgeInsets.all(16),
                                              child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                      child: Image.network(
                                                          model[index].imageUrl,
                                                          width: 40,
                                                          height: 40,
                                                          fit: BoxFit.fill),
                                                    ),
                                                    SizedBox(width: 8),
                                                    Expanded(
                                                      child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      left: 8),
                                                              child: Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Expanded(
                                                                    child: Text(
                                                                        model[index]
                                                                            .title,
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                16,
                                                                            fontWeight:
                                                                                FontWeight.w700,
                                                                            color: R.color.black)),
                                                                  ),
                                                                  isRead
                                                                      ? SizedBox()
                                                                      : Container(
                                                                          width:
                                                                              10,
                                                                          height:
                                                                              10,
                                                                          decoration: BoxDecoration(
                                                                              color: Color(0xff4BB2AB),
                                                                              borderRadius: BorderRadius.circular(5)))
                                                                ],
                                                              ),
                                                            ),
                                                            Html(
                                                                data: model[index]
                                                                        .topic ??
                                                                    ''),
                                                            Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      left: 8),
                                                              child: Text(
                                                                  convertToUTC(
                                                                      model[index]
                                                                          .sentDateTime,
                                                                      'HH:mm - dd/MM/yyyy'),
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      color: Color(
                                                                          0xffA1A3A6))),
                                                            )
                                                          ]),
                                                    )
                                                  ])),
                                        )),
                                  );
                                }
                              },
                            ))),
              ));
        }));
  }

  _showDialogDelete(BuildContext context, NotificationModel model) {
    showDialog(
      context: context,
      builder: (context) {
        return Container(
          child: AlertDialog(
              contentPadding: EdgeInsets.all(0),
              content: Stack(children: [
                Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset('assets/images/earseIcon.png',
                          width: 64, height: 64),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text('Xoá thông báo?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: R.color.textDark,
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text('Bạn chắc chắn muốn xoá thông báo này?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: R.color.textDark,
                                fontSize: 14,
                                fontWeight: FontWeight.w400)),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 16),
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
                                          borderRadius:
                                              BorderRadius.circular(200),
                                          color: R.color.grayBorder),
                                      child: Center(
                                        child: Text('Để sau',
                                            style: TextStyle(
                                                color: R.color.textDark,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600)),
                                      )),
                                ),
                              ),
                              SizedBox(width: 14),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    delete(model);
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    height: 43,
                                    decoration: BoxDecoration(
                                      color: R.color.red,
                                      borderRadius: BorderRadius.circular(200),
                                    ),
                                    child: Center(
                                      child: Text('Xoá',
                                          style: TextStyle(
                                              color: R.color.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600)),
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
                      icon: Icon(Icons.close, color: Color(0xffBEC0C8)),
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                )
              ])),
        );
      },
    );
  }

  delete(NotificationModel model) async {
    try {
      BotToast.showLoading();
      await NotificationClient().deleteNotification(model.id);
      refresh();
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
