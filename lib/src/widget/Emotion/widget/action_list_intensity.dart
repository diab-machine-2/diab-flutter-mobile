import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/exercrises/exercrises_intensity.dart';
import 'package:medical/src/repo/exercrises/exercrises_client.dart';
import 'package:medical/src/theme/app_theme.dart';

typedef TimeCallback = Function(ExercriseIntensityModel);

class ActionListIntensity extends StatefulWidget {
  final TimeCallback callback;
  ActionListIntensity({this.callback});
  @override
  ActionListIntensityState createState() => ActionListIntensityState();
}

class ActionListIntensityState extends State<ActionListIntensity> {
  ExercriseIntensityModel selected;

  List<ExercriseIntensityModel> intensity = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  loadData() async {
    BotToast.showLoading();
    intensity = await ExercrisesClient().fetchIntensity('');
    BotToast.closeAllLoading();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: R.color.transparent,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: R.color.white,
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Chọn cường độ vận động',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700)),
                  ),
                  // SizedBox(height: 8),
                  ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      // padding: EdgeInsets.only(
                      //     left: 10, right: 10, bottom: 8, top: 10),
                      itemCount: intensity.length,
                      itemBuilder: (BuildContext context, int index) {
                        return _buildItem(intensity[index], index);
                      }),
                  // SizedBox(height: 8),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        widget.callback(selected);
                        Navigator.pop(context);
                      },
                      child: Container(
                        margin: EdgeInsets.only(top: 16, bottom: 16),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Container(
                                    height: 43,
                                    width: 150,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(200),
                                        color: R.color.grayBorder),
                                    child: Center(
                                      child: Text('Huỷ',
                                          style: TextStyle(
                                              color: R.color.textDark,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600)),
                                    )),
                              ),
                              GestureDetector(
                                onTap: () {
                                  widget.callback(selected);
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  height: 43,
                                  width: 150,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.centerRight,
                                        colors: [
                                          R.color.greenGradientTop,
                                          R.color.greenGradientBottom
                                        ]),
                                    borderRadius: BorderRadius.circular(200),
                                  ),
                                  child: Center(
                                    child: Text('Tiếp tục',
                                        style: TextStyle(
                                            color: R.color.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600)),
                                  ),
                                ),
                              ),
                            ]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItem(ExercriseIntensityModel model, int index) {
    return Container(
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                selected = model;
              });
            },
            child: Container(
              color: selected == model ? R.color.greenbg : R.color.white,
              child: Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 16, top: 16, right: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          selected != model
                              ? Text(model.name,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400))
                              : Text(model.name,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: R.color.mainColor)),
                          selected == model
                              ? Image.asset(R.drawable.check_mark,
                                  width: 24, height: 24)
                              : SizedBox()
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  index != intensity.length - 1
                      ? Padding(
                          padding: const EdgeInsets.only(left: 16.0, right: 16),
                          child: Container(
                              height: 1,
                              width: 373,
                              color: selected == model
                                  ? R.color.greenbg
                                  : R.color.color0xffD6D8E0),
                        )
                      : SizedBox(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
