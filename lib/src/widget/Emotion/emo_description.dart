import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:easy_localization/easy_localization.dart';

class EmoDescription extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: R.color.transparent,
      body: SafeArea(
          child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(R.drawable.bg_des),
                          fit: BoxFit.fill,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(children: [
                            Image.asset(
                              R.drawable.img_des_person,
                              width: 71,
                              height: 76,
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Text(R.string.kiem_soat_cam_xuc_benh_tieu_duong.tr(),
                                  style: TextStyle(
                                      color: R.color.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700)),
                            )
                          ]),
                          SizedBox(height: 16),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 16),
                              child: ListView(children: [
                                Text(
                                    R.string.emotion_description.tr()),
                              ]),
                            ),
                          ),
                        ],
                      ),
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
                  )
                ],
              ))),
    );
  }
}
