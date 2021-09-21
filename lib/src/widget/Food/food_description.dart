import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:easy_localization/easy_localization.dart';

class FoodDescription extends StatelessWidget {
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
                              R.drawable.im_des_person,
                              width: 71,
                              height: 76,
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Text(R.string.che_do_dinh_duong_benh_tieu_duong.tr(),
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
                                    '${R.string.food_advice.tr()}:'),
                                SizedBox(height: 16),
                                RichText(
                                  text: TextSpan(
                                    text: '${R.string.nhom_duong_bot.tr()}: ',
                                    style: TextStyle(
                                        color: R.color.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                    children: <TextSpan>[
                                      TextSpan(
                                          style: TextStyle(
                                              color: R.color.black,
                                              fontSize: 14,
                                              fontWeight: FontWeight.normal),
                                          text:
                                              R.string.nhom_duong_bot_description.tr()),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 16),
                                RichText(
                                  text: TextSpan(
                                    text: '${R.string.nhom_thit_ca.tr()}: ',
                                    style: TextStyle(
                                        color: R.color.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                    children: <TextSpan>[
                                      TextSpan(
                                          style: TextStyle(
                                              color: R.color.black,
                                              fontSize: 14,
                                              fontWeight: FontWeight.normal),
                                          text:
                                              R.string.nhom_thit_ca_description.tr()),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 16),
                                RichText(
                                  text: TextSpan(
                                    text: 'Nhóm chất béo, đường: ',
                                    style: TextStyle(
                                        color: R.color.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                    children: <TextSpan>[
                                      TextSpan(
                                          style: TextStyle(
                                              color: R.color.black,
                                              fontSize: 14,
                                              fontWeight: FontWeight.normal),
                                          text:
                                              R.string.nhom_chat_beo_duong_description.tr()),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 16),
                                RichText(
                                  text: TextSpan(
                                    text: '${R.string.nhom_rau.tr()}: ',
                                    style: TextStyle(
                                        color: R.color.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                    children: <TextSpan>[
                                      TextSpan(
                                          style: TextStyle(
                                              color: R.color.black,
                                              fontSize: 14,
                                              fontWeight: FontWeight.normal),
                                          text:
                                              R.string.nhom_rau_description.tr()),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 16),
                                RichText(
                                  text: TextSpan(
                                    text: '${R.string.nhom_hoa_qua.tr()}: ',
                                    style: TextStyle(
                                        color: R.color.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                    children: <TextSpan>[
                                      TextSpan(
                                          style: TextStyle(
                                              color: R.color.black,
                                              fontSize: 14,
                                              fontWeight: FontWeight.normal),
                                          text:
                                              R.string.nhom_hoa_qua_description.tr()),
                                    ],
                                  ),
                                )
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
