import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'dart:io' show Platform;

class ConnectDeviceApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: R.color.backgroundColor,
        body: Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(R.drawable.bg_splash),
                    fit: BoxFit.cover)),
            child: Column(children: [
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
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                            context, NavigatorName.connection_instructions,
                            arguments: {'connectOnly': true});
                      },
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
                    Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12)),
                        padding: EdgeInsets.all(12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(children: [
                              Image.asset(
                                  Platform.isIOS
                                      ? R.drawable.ic_connect_apple
                                      : R.drawable.ic_connect_samsung,
                                  height: 48),
                              SizedBox(width: 12),
                              Text(
                                  Platform.isIOS
                                      ? 'Kết nối từ Apple Health'
                                      : 'Kết nối từ Samsung Health',
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
                        ))
                  ]))
            ])));
  }
}
