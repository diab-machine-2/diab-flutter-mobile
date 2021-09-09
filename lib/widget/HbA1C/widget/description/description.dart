import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:medical/modal/HbA1C/short_gui.dart';
import 'package:medical/theme/app_theme.dart';
import 'package:medical/widget/HbA1C/widget/description/description_detail.dart';

class Description extends StatelessWidget {
  final bool input;
  final ShortGuiModel data;
  final String titleDetail;
  Description(
      {@required this.input, @required this.data, @required this.titleDetail});
  @override
  Widget build(BuildContext context) {
    // final height = (MediaQuery.of(context).size.width - 32) * 153 / 343 - 54;
    final width = MediaQuery.of(context).size.width - 32;
    return GestureDetector(
        onTap: () {
          data == null
              ? SizedBox()
              : showDialog(
                  barrierColor: Color(0xff003F38).withOpacity(0.8),
                  useSafeArea: false,
                  context: context,
                  builder: (_) => DetailDescription(
                      input: input, data: data, title: titleDetail),
                );
        },
        // child: Container(
        //   color: Colors.transparent,
        //   child: Stack(
        //     alignment: AlignmentDirectional.centerStart,
        //     children: [
        //       Image.asset(input
        //           ? 'assets/images/hba1c_des_input.png'
        //           : 'assets/images/hba1c_des.png'),
        //       Padding(
        //         padding: EdgeInsets.only(top: 8, left: 130, right: 26, bottom: 0),
        //         child: Column(
        //           mainAxisAlignment: MainAxisAlignment.spaceAround,
        //           children: [
        //             SizedBox(
        //                 height: height,
        //                 child: data == null
        //                     ? SizedBox()
        //                     : Center(
        //                         child: Html(
        //                             data:
        //                                 input ? data.content1 : data.content3))),
        //             Padding(
        //               padding: EdgeInsets.only(top: 12, left: 8),
        //               child: Row(children: [
        //                 Text('Tìm hiểu thêm',
        //                     style: TextStyle(
        //                         fontSize: 16,
        //                         color: mainColor,
        //                         fontWeight: FontWeight.w700)),
        //                 SizedBox(width: 4),
        //                 Image.asset('assets/images/icon_arrow_des.png',
        //                     width: 24, height: 24)
        //               ]),
        //             )
        //           ],
        //         ),
        //       )
        //     ],
        //   ),
        // ),
        child: Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Container(
            color: Colors.transparent,
            height: 110,
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 20, left: 8, bottom: 8),
                  child: Image.asset('assets/images/icon_des.png'),
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
                                data: input ? data.content1 : data.content3)),
                    Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Row(children: [
                        Text('Tìm hiểu thêm',
                            style: TextStyle(
                                fontSize: 14,
                                color: mainColor,
                                fontWeight: FontWeight.w700)),
                        SizedBox(width: 4),
                        Image.asset('assets/images/icon_arrow_des.png',
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
