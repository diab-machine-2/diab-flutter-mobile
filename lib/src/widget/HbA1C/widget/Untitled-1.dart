import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';

class HbA1CDetailItem extends StatelessWidget {
  final bool hasNote;
  HbA1CDetailItem(this.hasNote);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 16, left: 16, right: 16),
      child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: R.color.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('30/08/2020',
                    style: TextStyle(
                        color: R.color.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w700)),
                Container(
                    height: 26,
                    padding: EdgeInsets.only(left: 14, right: 14),
                    decoration: BoxDecoration(
                        color: hasNote ? R.color.color0xffFF5756 : R.color.color0xff4AAF05,
                        // borderRadius: BorderRadius.circular(13))
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(13),
                            topRight: Radius.circular(13),
                            bottomLeft: Radius.circular(13))),
                    child: Center(
                      child: Text(hasNote ? 'Rất cao' : 'Tuyệt vời',
                          style: TextStyle(
                              color: R.color.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600)),
                    ))
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('HbA1C',
                    style: TextStyle(
                        color: R.color.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w400)),
                Text(hasNote ? '9.0%' : '6.2%',
                    style: TextStyle(
                        color: hasNote ? R.color.color0xffFF5756 : R.color.color0xff4AAF05,
                        fontSize: 24,
                        fontWeight: FontWeight.w700))
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Đuờng huyết',
                    style: TextStyle(
                        color: R.color.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w400)),
                Text(hasNote ? '243 (ml/dL)' : '136 (ml/dL)',
                    style: TextStyle(
                        color: R.color.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600))
              ],
            ),
            hasNote
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16),
                      Container(height: 1, color: R.color.color0xffEEEFF3),
                      SizedBox(height: 16),
                      Text(
                          'Ghi chú: Tôi đi khám và đo chỉ số này tại bệnh viện Nguyễn Tri Phương',
                          style: TextStyle(
                              color: R.color.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w400)),
                    ],
                  )
                : SizedBox()
          ])),
    );
  }
}
