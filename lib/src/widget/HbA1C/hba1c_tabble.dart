import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:easy_localization/easy_localization.dart';

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
                    child: Text(R.string.bang_chi_so_hba1c_va_duong_huyet.tr(),
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w700)),
                  ),
                  Expanded(
                      child: Center(
                          child:
                              Image.asset(R.drawable.img_tabble_hba1c))),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: 50,
                      width: 50,
                      child: Image.asset(R.drawable.ic_close_border),
                    ),
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
