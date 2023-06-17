import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/app_media_query.dart';
import 'package:medical/src/widgets/app_bar_widget.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:medical/src/widgets/normal_template.dart';

import '../data/models/device_info_model.dart';

class GuidelineView extends StatefulWidget {
  final DeviceInfoModel deviceInfo;
  final Function onConnectDevice;
  const GuidelineView({
    Key? key,
    required this.deviceInfo,
    required this.onConnectDevice,
  }) : super(key: key);

  @override
  State<GuidelineView> createState() => _GuidelineViewState();
}

class _GuidelineViewState extends State<GuidelineView> {
  late PageController _pageController;
  int initialPage = 0;

  @override
  void initState() {
    _pageController = PageController(initialPage: initialPage);
    _pageController.addListener(() {
      setState(() {
        initialPage = _pageController.page!.round();
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isFirstPage = initialPage == 0;
    bool isLastPage = initialPage == widget.deviceInfo.tutorials.length - 1;
    return Scaffold(
      body: NormalTemplate(
        appBar: AppBarWidget(title: 'Hướng dẫn kết nối'),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  children: widget.deviceInfo.tutorials
                      .map(
                        (info) => Container(
                          constraints: BoxConstraints(
                            maxWidth: 300,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Image.asset(
                                  info.image,
                                  height: 255,
                                ),
                              ),
                              SizedBox(height: 25),
                              info.title,
                              SizedBox(height: 15),
                              info.description ?? SizedBox(),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: widget.deviceInfo.tutorials
                    .map(
                      (info) => pagingWidget(info.index),
                    )
                    .toList(),
              ),
              SizedBox(height: 25),
              Row(
                children: [
                  AnimatedContainer(
                    duration: Duration(milliseconds: 100),
                    width:
                        isFirstPage ? 0 : AppMediaQuery.deviceWidth / 2 - 22.5,
                    height: 56,
                    margin: EdgeInsets.only(right: isFirstPage ? 0 : 15),
                    child: ButtonWidget(
                      backgroundColor: Colors.transparent,
                      textColor: Color(0xff249B92),
                      borderColor: Color(0xff249B92),
                      icon: R.icons.ic_chevron_left,
                      title: 'Trở lại',
                      onPressed: () {
                        _pageController.previousPage(
                          duration: Duration(milliseconds: 500),
                          curve: Curves.ease,
                        );
                        setState(() {
                          initialPage--;
                        });
                      },
                    ),
                  ),
                  AnimatedContainer(
                    duration: Duration(milliseconds: 100),
                    width: isFirstPage
                        ? AppMediaQuery.deviceWidth - 30
                        : AppMediaQuery.deviceWidth / 2 - 22.5,
                    height: 56,
                    child: ButtonWidget(
                      isArrowRight: true,
                      icon: R.icons.ic_dou_chevron_right,
                      title: isLastPage ? 'Trang đầu' : 'Tiếp tục',
                      onPressed: () {
                        int nextPage = initialPage + 1;
                        if (isLastPage) {
                          nextPage = 0;
                        }
                        _pageController.animateToPage(
                          nextPage,
                          duration: Duration(milliseconds: 500),
                          curve: Curves.ease,
                        );
                        setState(() {
                          initialPage = nextPage;
                        });
                      },
                    ),
                  )
                ],
              ),
              SizedBox(height: 15),
              Container(
                height: 56,
                margin: EdgeInsets.only(bottom: 0),
                width: double.infinity,
                child: ButtonWidget(
                  backgroundColor: Color(0xFFE8F9F7),
                  textColor: Color(0xff249B92),
                  title: 'Kết nối ngay',
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onConnectDevice();
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget pagingWidget(int index) {
    return AnimatedContainer(
      margin: EdgeInsets.symmetric(horizontal: 3),
      duration: Duration(milliseconds: 300),
      height: 4,
      width: 30,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.horizontal(
          left: Radius.circular(index == 0 ? 4 : 0),
          right: Radius.circular(
              index == widget.deviceInfo.tutorials.length - 1 ? 4 : 0),
        ),
        color: index == initialPage ? Color(0xFF141416) : Color(0xFFE6E8EC),
      ),
    );
  }
}
