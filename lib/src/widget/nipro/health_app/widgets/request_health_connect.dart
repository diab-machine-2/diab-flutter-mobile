import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/health_setting.dart';
import 'package:medical/src/utils/app_storages.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import '../blocs/healthApp_bloc.dart';

class RequestHealthConnect extends StatelessWidget {
  final bool isSyncing;
  final Function callback;
  const RequestHealthConnect(
      {Key? key, required this.isSyncing, required this.callback})
      : super(key: key);

  static showModal(
    BuildContext context, {
    required Function callback,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      backgroundColor: Colors.white,
      builder: (context) => RequestHealthConnect(
        isSyncing: false,
        callback: () => callback(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String appTitle = Platform.isIOS ? 'Apple Health' : 'Health Connect';
    String appLogo = Platform.isIOS
        ? R.drawable.logo_healthkit
        : R.drawable.logo_healthConnect;
    return BlocProvider<HealthAppBloc>(
      create: (_) => HealthAppBloc()..add(SubmitSyncData(isSyncing)),
      child: BlocBuilder<HealthAppBloc, HealthAppState>(
        builder: (context, state) {
          if (isSyncing == true && state.blocStatus == BlocStatus.success)
            return SizedBox();
          if (isSyncing == true && state.blocStatus == BlocStatus.loading) {
            return SizedBox();
          }
          return Padding(
            padding: const EdgeInsets.only(
                top: 100, left: 20, right: 20, bottom: 50),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          R.drawable.logo_diab,
                          width: 72,
                        ),
                        SizedBox(width: 15),
                        Image.asset(
                          appLogo,
                          width: 72,
                        )
                      ],
                    ),
                    SizedBox(height: 30),
                    Text(
                      "Kết nối diaB với $appTitle",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        "Chúng tôi sẽ tự động lấy dữ liệu từ $appTitle để giúp bạn theo dõi sức khỏe và hoạt động thể dục của mình.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          height: 1.4,
                          fontSize: 16,
                          color: R.color.textDark,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 105),
                Column(
                  children: [
                    SizedBox(height: 25),
                    ButtonWidget(
                      title: "Để sau",
                      textColor: R.color.textDark,
                      backgroundColor: R.color.grayBorder,
                      onPressed: () async {
                        Navigator.pop(context);
                        await AppStorages.setHealthAppPermission(false);
                      },
                    ),
                    SizedBox(height: 15),
                    ButtonWidget(
                      title: "Kết nối với $appTitle",
                      onPressed: () async {
                        if (Platform.isAndroid) {
                          // Note that for Android, the target phone needs to have the Health Connect app installed
                          // and have access to the internet.
                          final isHealthConnectAvailable = await HealthSetting
                              .instance
                              .isHealthConnectSdkStatusAvailable();
                          // Handle case target Android phone does not install Health Connect
                          if (!isHealthConnectAvailable) {
                            _showDialogWarning(context,
                                onConfirm: () async => await HealthSetting
                                    .instance
                                    .installHealthConnect());
                            return;
                          }

                          await Permission.activityRecognition.request();
                          await Permission.location.request();
                        }
                        bool _hasPermission = await HealthSetting.instance
                                .requestConnectionPermission() ??
                            false;
                        AppStorages.setHealthAppPermission(_hasPermission);
                        if (_hasPermission == true) {
                          Navigator.pop(context);
                          callback.call();
                          Message.showToastMessage(
                              context, "Đã hoàn thành kết nối với $appTitle");
                          Observable.instance.notifyObservers([],
                              notifyName: "syncing_heath_app");
                        } else {
                          Message.showToastMessage(
                              context, "Kết nối thất bại với $appTitle");
                        }
                      },
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }

  _showDialogWarning(BuildContext context, {required Function onConfirm}) {
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
                      Image.asset(R.drawable.ic_warning, width: 64, height: 64),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                            'Không thể kết nối với Health Connect. Vui lòng cài đặt ứng dụng Health Connect trên thiết bị của bạn.',
                            textAlign: TextAlign.center,
                            style: R.style.normalTextStyle),
                      ),
                      SizedBox(height: 16),
                      Row(
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
                                      ))),
                            ),
                            SizedBox(width: 14),
                            Expanded(
                              child: GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                    onConfirm();
                                  },
                                  child: Container(
                                    height: 43,
                                    decoration: BoxDecoration(
                                        color: R.color.red,
                                        borderRadius:
                                            BorderRadius.circular(200),
                                        gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.centerRight,
                                            colors: [
                                              R.color.greenGradientTop,
                                              R.color.greenGradientBottom
                                            ])),
                                    child: Center(
                                      child: Text('Cài Đặt',
                                          style: TextStyle(
                                              color: R.color.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600)),
                                    ),
                                  )),
                            ),
                          ])
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
              ])),
        );
      },
    );
  }
}
