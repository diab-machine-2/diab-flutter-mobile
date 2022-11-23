import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/user/manual.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:easy_localization/easy_localization.dart';

class ManualController extends StatefulWidget {
  @override
  _ManualControllerState createState() => _ManualControllerState();
}

class _ManualControllerState extends State<ManualController> {
  List<ManualModel>? manuals = [];
  List<ManualModel>? manualsSearch = [];

  void initState() {
    super.initState();
    loadData();
    TrackingManager.analytics.setCurrentScreen(screenName: 'User Manual');
  }

  loadData() async {
    BotToast.showLoading();
    manuals = await UserClient().fetchManuals();
    manualsSearch = manuals;
    BotToast.closeAllLoading();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
          body: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [
                        R.color.color0xFFFDC798.withOpacity(0.3),
                        R.color.greenbg.withOpacity(0.9),
                      ],
                      begin: FractionalOffset(1, 1),
                      end: FractionalOffset(0.9, 0.5),
                      stops: [0.0, 1.0])),
              child: Column(
                children: [
                  CustomAppBar(
                    backgroundColor: R.color.transparent,
                    title: Text(R.string.user_manual.tr(),
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: R.color.textDark)),
                    leadingIcon: IconButton(
                        splashColor: R.color.transparent,
                        highlightColor: R.color.transparent,
                        icon: Icon(Icons.arrow_back, color: R.color.textDark),
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                  ),
                  Container(
                      height: 54,
                      margin: EdgeInsets.only(left: 16, right: 16),
                      padding: EdgeInsets.only(left: 16, right: 16),
                      decoration: BoxDecoration(
                          color: R.color.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: R.color.grayComponentBorder)),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Container(
                                  height: 30,
                                  child: TextField(
                                    onChanged: (value) {
                                      setState(() {
                                        manualsSearch = manuals!
                                            .where((element) =>
                                                element.answer!
                                                    .toLowerCase()
                                                    .contains(
                                                        value.toLowerCase()) ||
                                                element.question!
                                                    .toLowerCase()
                                                    .contains(
                                                        value.toLowerCase()))
                                            .toList();
                                      });
                                    },
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        counterText: '',
                                        contentPadding:
                                            EdgeInsets.only(top: -20),
                                        hintText: R.string.tim_kiem_hoat_dong.tr(),
                                        fillColor: R.color.textDark),
                                  )),
                            ),
                            Image.asset(R.drawable.ic_search,
                                width: 24, height: 24, color: R.color.mainColor),
                          ])),
                  Expanded(
                    child: ListView.separated(
                      padding: EdgeInsets.all(16),
                      itemCount: manualsSearch!.length,
                      separatorBuilder: (context, index) {
                        return Container(height: 1, color: R.color.grayBorder);
                      },
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, NavigatorName.manual_detail,
                                arguments: {'manual': manualsSearch![index]});
                          },
                          child: Container(
                              padding: EdgeInsets.only(top: 16, bottom: 16),
                              color: R.color.transparent,
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(manualsSearch![index].question!,
                                          style: TextStyle(
                                              color: R.color.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600)),
                                    ),
                                    SizedBox(width: 16),
                                    Icon(
                                      Icons.arrow_forward_ios_outlined,
                                      size: 16,
                                      color: R.color.black,
                                    )
                                  ])),
                        );
                      },
                    ),
                  ),
                ],
              ))),
    );
  }
}
