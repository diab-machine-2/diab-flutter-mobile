import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/repo/glucose/glucose_client.dart';
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
  List<Map<String, String>> selectedGlucose = [];
  //Map<String, String>? glucose;

  @override
  void initState() {
    super.initState();
    checkData();
  }

  checkData() async {
    glucoseData = [];
    try {
      BotToast.showLoading();
      final result =
          await GlucoseClient().fetchGlucoseInputNotExist(widget.glucoseData);

      result.forEach((element) {
        glucoseData.add({
          'glucose': element['glucose'].toString(),
          'date': element['createDate'].toString()
        });
      });
      selectedGlucose = [...glucoseData];
      setState(() {});
      BotToast.closeAllLoading();
    } catch (e) {
      BotToast.closeAllLoading();
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom -
        54;

    final double countHight = glucoseData.length * 48.0 + 216;

    glucoseData.sort(((a, b) {
      return int.parse(b['date']!).compareTo(int.parse(a['date']!));
    }));

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
                                  if (isSelected(data)) {
                                    selectedGlucose.remove(data);
                                  } else {
                                    selectedGlucose.add(data);
                                  }
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
                                            isSelected(data)
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
                if (selectedGlucose.length == 0) {
                  Message.showToastMessage(
                      context, 'Bạn chưa chọn chỉ số dường huyết');
                  return;
                }
                submit();
                // Navigator.pop(context);
                // Navigator.of(context).pop(glucose);
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

  bool isSelected(Map<String, String> glucose) {
    bool isSelected = false;
    selectedGlucose.forEach((element) {
      if (element['glucose'] == glucose['glucose'] &&
          element['date'] == glucose['date']) {
        isSelected = true;
      }
    });
    return isSelected;
  }

  submit() async {
    try {
      BotToast.showLoading();
      await GlucoseClient().postGlucoseInputs(selectedGlucose);
      BotToast.closeAllLoading();
      showPopupSuccess();
    } catch (e) {
      BotToast.closeAllLoading();
      Message.showToastMessage(context, e.toString());
    }
  }

  showPopupSuccess() {
    showDialog(
      context: context,
      builder: (context) {
        return Container(
          child: AlertDialog(
              contentPadding: EdgeInsets.all(0),
              content: Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.info_outline, size: 64),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(
                          'Đã đồng bộ các chỉ số đã chọn từ thiết bị thành công',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: R.color.textDark,
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                    ),
                    SizedBox(height: 20),
                    GestureDetector(
                        onTap: () {
                          Observable.instance.notifyObservers([],
                              notifyName: "glucose_change_data",
                              map: {'index': 1});
                        },
                        child: Container(
                          height: 43,
                          width: 200,
                          decoration: BoxDecoration(
                              color: R.color.red,
                              borderRadius: BorderRadius.circular(200),
                              gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    R.color.greenGradientTop,
                                    R.color.greenGradientBottom
                                  ])),
                          child: Center(
                            child: Text('Hoàn tất',
                                style: TextStyle(
                                    color: R.color.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ))
                  ],
                ),
              )),
        );
      },
    );
  }
}
