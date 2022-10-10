import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/Bmi/widget/add_bmi.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';

class ListData extends StatefulWidget {
  final List<Map<String, String>> glucoseData;
  ListData({required Key key, required this.glucoseData}) : super(key: key);

  @override
  State<ListData> createState() => ListDataState();
}

class ListDataState extends State<ListData> {
  List<Map<String, String>> glucoseData = [];
  Map<String, String>? glucose;

  @override
  void initState() {
    glucoseData = widget.glucoseData;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom -
        54;

    final double countHight = glucoseData.length * 48.0 + 216;
    return SafeArea(
        child: Container(
      height: height, //countHight > height ? height : countHight,
      child: Padding(
        padding: EdgeInsets.only(left: 16, right: 16, top: 20, bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Chỉ số đường huyết đã đo',
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: 24,
                    width: 24,
                    child: Image.asset(R.drawable.ic_close),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text('Chọn ngày bạn muốn cập nhật chỉ số.',
                style: TextStyle(fontSize: 16, color: Color(0xff8E8E8E))),
            SizedBox(height: 32),
            glucoseData.length == 0
                ? Expanded(
                    child: SingleChildScrollView(
                      child: Column(children: [
                        SizedBox(height: 32),
                        Image.asset(R.drawable.ic_no_device, height: 110),
                        SizedBox(height: 24),
                        Text('Không tìm thấy dữ liệu',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        SizedBox(height: 18),
                        Text(
                            'DiaB không tìm thấy dữ liệu từ máy đo đường huyết. Vui lòng kiểm tra lại thiết bị đã có dữ liệu chưa?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 16, color: Color(0xff8E8E8E))),
                      ]),
                    ),
                  )
                : Expanded(
                    child: ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.all(0),
                        itemCount: glucoseData.length,
                        separatorBuilder: (context, index) => Container(
                            height: 1,
                            color: R.color.grayBorder,
                            margin: EdgeInsets.only(bottom: 16, top: 16)),
                        itemBuilder: (BuildContext context, int index) {
                          final data = glucoseData[index];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              index < 2
                                  ? Padding(
                                      padding: EdgeInsets.only(bottom: 16),
                                      child: Text(
                                          index == 0 ? 'Hiện tại' : 'Trước đây',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Color(0xff8E8E8E),
                                              fontWeight: FontWeight.bold)),
                                    )
                                  : SizedBox(),
                              GestureDetector(
                                onTap: () {
                                  glucose = data;

                                  setState(() {});
                                },
                                child: Container(
                                    color: Colors.white,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                (double.tryParse(
                                                            data['glucose']!) ??
                                                        0)
                                                    .round()
                                                    .toString(),
                                                style: TextStyle(
                                                    fontSize: 24,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            SizedBox(height: 8),
                                            Text(
                                                convertToUTC(
                                                    int.tryParse(
                                                            data['date']!) ??
                                                        0,
                                                    'HH:mm - dd-MM-yyyy'),
                                                style: TextStyle(
                                                    color: R.color.grayCaption,
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w400))
                                          ],
                                        ),
                                        Image.asset(
                                            glucose == data
                                                ? R.drawable.ic_active
                                                : R.drawable.ic_unactive,
                                            height: 24)
                                      ],
                                    )),
                              ),
                            ],
                          );
                        }),
                  ),
            GestureDetector(
              onTap: () async {
                if (glucose == null) {
                  Message.showToastMessage(
                      context, 'Bạn chưa chọn chỉ số dường huyết');
                  return;
                }
                Navigator.pop(context);
                Navigator.of(context).pop(glucose);
              },
              child: SafeArea(
                top: false,
                child: Container(
                    margin: EdgeInsets.only(top: 16, bottom: 16),
                    height: 48,
                    decoration: BoxDecoration(
                        color: R.color.mainColor,
                        borderRadius: BorderRadius.circular(200),
                        gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.centerRight,
                            colors: [
                              R.color.greenGradientTop,
                              R.color.greenGradientBottom
                            ])),
                    child: Center(
                        child: Text('Xác nhận',
                            style: TextStyle(
                                color: R.color.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16)))),
              ),
            )
          ],
        ),
      ),
    ));
  }
}
