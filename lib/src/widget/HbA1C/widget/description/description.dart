import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/HbA1C/short_gui.dart';
import 'package:medical/src/widget/HbA1C/widget/description/description_detail.dart';
import 'package:easy_localization/easy_localization.dart';

class Description extends StatelessWidget {
  final bool input;
  final ShortGuiModel? data;
  final String titleDetail;
  Description(
      {required this.input, required this.data, required this.titleDetail});

  static showTooltip(
    context, {
    required ShortGuiModel data,
    required String title,
  }) {
    showDialog(
      barrierColor: R.color.color0xff003F38.withOpacity(0.8),
      useSafeArea: false,
      context: context,
      builder: (_) => DetailDescription(
        input: false,
        data: data,
        title: title,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // final height = (MediaQuery.of(context).size.width - 32) * 153 / 343 - 54;
    final width = MediaQuery.of(context).size.width - 32;
    return GestureDetector(
        onTap: () {
          data == null
              ? SizedBox()
              : showDialog(
                  barrierColor: R.color.color0xff003F38.withOpacity(0.8),
                  useSafeArea: false,
                  context: context,
                  builder: (_) => DetailDescription(
                      input: input, data: data, title: titleDetail),
                );
        },
        child: Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Container(
            color: R.color.transparent,
            height: 110,
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 20, left: 8, bottom: 8),
                  child: Image.asset(R.drawable.img_des),
                ),
                SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    data == null
                        ? SizedBox()
                        : SizedBox(
                            width: width - 128,
                            height: 80,
                            child: Html(
                                data: input ? data!.content1 : data!.content3)),
                    Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Row(children: [
                        Text(R.string.tim_hieu_them.tr(),
                            style: TextStyle(
                                fontSize: 14,
                                color: R.color.mainColor,
                                fontWeight: FontWeight.w700)),
                        SizedBox(width: 4),
                        Image.asset(R.drawable.ic_arrow_des,
                            width: 20, height: 20)
                      ]),
                    )
                  ],
                )
              ],
            ),
          ),
        ));
  }
}
