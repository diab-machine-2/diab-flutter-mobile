import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/utils/app_storages.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'dart:io' show Platform;
import 'package:medical/src/widget/nipro/health_app/widgets/request_health_connect.dart';
import 'package:medical/src/widget/nipro/roche_connection/roche_connection_view.dart';

class ConnectDeviceApp extends StatefulWidget {
  @override
  State<ConnectDeviceApp> createState() => _ConnectDeviceAppState();
}

class _ConnectDeviceAppState extends State<ConnectDeviceApp> {
  bool hasPermission = false;

  @override
  void initState() {
    onLoaded();
    super.initState();
  }

  onLoaded() async {
    bool? _hasPermission = await AppStorages.getHealthAppPermission();
    setState(() {
      hasPermission = _hasPermission ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: R.color.backgroundColor,
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage(R.drawable.bg_splash), fit: BoxFit.cover)),
        child: Column(
          children: [
            CustomAppBar(
                backgroundColor: R.color.transparent,
                title: Text('Kết nối thiết bị và app sức khoẻ',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: R.color.textDark)),
                leadingIcon: IconButton(
                    splashColor: R.color.transparent,
                    highlightColor: R.color.transparent,
                    icon: Icon(Icons.arrow_back, color: R.color.textDark),
                    onPressed: () {
                      Navigator.pop(context);
                    })),
            Expanded(
              child: ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.all(16),
                children: [
                  // GestureDetector(
                  //   onTap: () {
                  //     Navigator.pushNamed(
                  //         context, NavigatorName.connection_instructions,
                  //         arguments: {'connectOnly': true});
                  //   },
                  //   child: Container(
                  //       decoration: BoxDecoration(
                  //           color: Colors.white,
                  //           borderRadius: BorderRadius.circular(12)),
                  //       padding: EdgeInsets.all(12),
                  //       child: Row(
                  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //         children: [
                  //           Row(children: [
                  //             Image.asset(R.drawable.ic_connect_from_device,
                  //                 height: 48),
                  //             SizedBox(width: 12),
                  //             Text('Kết nối từ thiết bị',
                  //                 style: TextStyle(
                  //                     fontSize: 16,
                  //                     fontWeight: FontWeight.bold,
                  //                     color: R.color.textDark))
                  //           ]),
                  //           Padding(
                  //             padding: EdgeInsets.only(right: 8),
                  //             child: Icon(Icons.arrow_forward_ios,
                  //                 color: R.color.mainColor, size: 18),
                  //           )
                  //         ],
                  //       )),
                  // ),
                  // SizedBox(height: 16),
                  if (!AppSettings.isUS) ...[
                    GestureDetector(
                      onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    RocheConnectionView())),
                      child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12)),
                          padding: EdgeInsets.all(12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(children: [
                                Image.asset(R.drawable.ic_connect_from_device,
                                    height: 48),
                                SizedBox(width: 12),
                                Text('Kết nối từ thiết bị',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: R.color.textDark))
                              ]),
                              Padding(
                                padding: EdgeInsets.only(right: 8),
                                child: Icon(Icons.arrow_forward_ios,
                                    color: R.color.mainColor, size: 18),
                              )
                            ],
                          )),
                    ),
                    SizedBox(height: 16),
                  ],
                  GestureDetector(
                    onTap: () {
                      if (hasPermission == false) {
                        RequestHealthConnect.showModal(
                          context,
                          callback: () {
                            setState(() {
                              hasPermission = true;
                            });
                          },
                        );
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12)),
                      padding: EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Image.asset(
                                  Platform.isIOS
                                      ? R.drawable.logo_healthkit
                                      : R.drawable.logo_googleFit,
                                  height: 48),
                              SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    Platform.isIOS
                                        ? 'Kết nối từ Apple Health'
                                        : 'Kết nối từ Google Fit',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: R.color.textDark,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    hasPermission
                                        ? 'Đã kết nối'
                                        : 'Chưa kết nối',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: hasPermission
                                          ? R.color.greenGradientBottom
                                          : R.color.gray,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
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
