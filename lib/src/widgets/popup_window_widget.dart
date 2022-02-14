import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';

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
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                        // padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: AssetImage(R.drawable.bg_des),
                            fit: BoxFit.fill,
                          ),
                        ),
                        child: child
                    ),
                  ),
                  SizedBox(height: 16),
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
