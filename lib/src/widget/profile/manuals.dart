import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:medical/src/modal/user/manual.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:medical/src/theme/app_theme.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';

class ManualController extends StatefulWidget {
  @override
  _ManualControllerState createState() => _ManualControllerState();
}

class _ManualControllerState extends State<ManualController> {
  List<ManualModel> manuals = [];
  List<ManualModel> manualsSearch = [];

  void initState() {
    super.initState();
    loadData();
    TrackingManager.analytics.setCurrentScreen(screenName: 'Manuals');
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
                        Color(0xFFFDC798).withOpacity(0.3),
                        Color(0xFFE6F6ED).withOpacity(0.9),
                      ],
                      begin: FractionalOffset(1, 1),
                      end: FractionalOffset(0.9, 0.5),
                      stops: [0.0, 1.0])),
              child: Column(
                children: [
                  CustomAppBar(
                    backgroundColor: Colors.transparent,
                    title: Text('Hướng dẫn sử dụng',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: textDark)),
                    leadingIcon: IconButton(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        icon: Icon(Icons.arrow_back, color: textDark),
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                  ),
                  Container(
                      height: 54,
                      margin: EdgeInsets.only(left: 16, right: 16),
                      padding: EdgeInsets.only(left: 16, right: 16),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: grayComponentBorder)),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Container(
                                  height: 30,
                                  child: TextField(
                                    onChanged: (value) {
                                      setState(() {
                                        manualsSearch = manuals
                                            .where((element) =>
                                                element.answer
                                                    .toLowerCase()
                                                    .contains(
                                                        value.toLowerCase()) ||
                                                element.question
                                                    .toLowerCase()
                                                    .contains(
                                                        value.toLowerCase()))
                                            .toList();
                                      });
                                    },
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding:
                                            EdgeInsets.only(top: -20),
                                        hintText: 'Tìm kiếm hoạt động',
                                        fillColor: textDark),
                                  )),
                            ),
                            Image.asset('assets/images/search.png',
                                width: 24, height: 24, color: mainColor),
                          ])),
                  Expanded(
                    child: ListView.separated(
                      padding: EdgeInsets.all(16),
                      itemCount: manualsSearch.length,
                      separatorBuilder: (context, index) {
                        return Container(height: 1, color: Color(0xffE2E4E7));
                      },
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/manual_detail',
                                arguments: {'manual': manualsSearch[index]});
                          },
                          child: Container(
                              padding: EdgeInsets.only(top: 16, bottom: 16),
                              color: Colors.transparent,
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(manualsSearch[index].question,
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600)),
                                    ),
                                    SizedBox(width: 16),
                                    Icon(
                                      Icons.arrow_forward_ios_outlined,
                                      size: 16,
                                      color: Colors.black,
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
