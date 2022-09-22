import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/BloodSugar/widget/action_list_trend.dart';
import 'package:medical/src/widget/nipro/list_devices.dart';

class TempController extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: TextButton(
                onPressed: () {
                  showModalBottomSheet(
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(15))),
                      backgroundColor: R.color.white,
                      context: context,
                      isScrollControlled: true,
                      builder: (context) => ListDevices());
                },
                child: Text('Kết nối'))));
  }
}
