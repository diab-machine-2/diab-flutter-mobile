import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';

class HbA1CTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: R.color.white.withOpacity(0.90),
        body: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 20, bottom: 20),
                    child: Text('Bảng chỉ số HbA1C & đường huyết',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w700)),
                  ),
                  Expanded(
                      child: Center(
                          child:
                              Image.asset(R.drawable.tabble_hba1c))),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: 50,
                      width: 50,
                      child: Image.asset(R.drawable.icon_close_border),
                    ),
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
