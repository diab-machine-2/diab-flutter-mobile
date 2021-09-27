import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PopupWindowWidget extends StatelessWidget {
  final Widget child;
  PopupWindowWidget({required this.child});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: R.color.transparent,
      body: Container(
        alignment: Alignment.bottomCenter,
          child: Padding(
              padding: EdgeInsets.all(16.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: double.infinity,
                      padding: EdgeInsets.all(16.h),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.h),
                        image: DecorationImage(
                          image: AssetImage(R.drawable.bg_popup),
                          fit: BoxFit.fill,
                        ),
                      ),
                      child: child
                  ),
                  SizedBox(height: 16.h),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: R.color.greenGradientTop,
                            borderRadius: BorderRadius.circular(30)),
                        child: IconButton(
                            icon: Icon(Icons.close, color: R.color.white),
                            onPressed: () {
                              Navigator.pop(context);
                            }),
                      ),
                    ),
                  ),
                ],
              ))),
    );
  }
}
