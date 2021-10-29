import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widgets/background_page.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'welcome_service.dart';

class WelcomeServicePage extends StatefulWidget {
  final String code;

  const WelcomeServicePage({Key? key, required this.code}) : super(key: key);

  @override
  _WelcomeServicePageState createState() => _WelcomeServicePageState();
}

class _WelcomeServicePageState extends State<WelcomeServicePage> {
  late WelcomeServiceCubit _cubit;
  final PageController _pageController = PageController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    AppRepository repository = AppRepository();
    _cubit = WelcomeServiceCubit(repository);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
        body: BlocProvider(
          create: (context) => _cubit,
          child: BlocConsumer<WelcomeServiceCubit, WelcomeServiceState>(
            listener: (context, state) {
              if (state is WelcomeServiceFailure) {
                Message.showToastMessage(context, state.error);
              }
            },
            builder: (
              BuildContext context,
              WelcomeServiceState state,
            ) {
              if (state is WelcomeServiceLoading) {
                BotToast.showLoading();
              } else {
                BotToast.closeAllLoading();
              }
              return buildPage(context, state);
            },
          ),
        ),
      ),
    );
  }

  Widget buildPage(BuildContext context, WelcomeServiceState state) {
    return BackgroundPage(
          background: R.drawable.bg_welcome,
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(height: 20),
                  Expanded(
                    child: PageView(
                      onPageChanged: (value) {
                        _cubit.selectOption(value);
                      },
                      controller: _pageController,
                      children: [
                        widget.code == Const.PRO
                            ? pageFirst(
                                R.drawable.img_welcome_1,
                                R.string.package_pro.tr(),
                                R.string.description_diab_pro.tr())
                            : pageFirst(
                                R.drawable.img_welcome_0,
                                R.string.package_premium.tr(),
                                R.string.description_diab_basic.tr()),
                        pageNext(R.drawable.img_welcome_2, [
                          R.string.des_1_welcome_2.tr(),
                          R.string.des_2_welcome_2.tr(),
                          R.string.des_3_welcome_2.tr()
                        ]),
                        pageNext(R.drawable.img_welcome_3, [
                          R.string.des_1_welcome_3.tr(),
                          R.string.des_2_welcome_3.tr(),
                          R.string.des_3_welcome_2.tr()
                        ])
                      ],
                    ),
                  ),
                  Column(children: [
                    SizedBox(height: 33),
                    Column(
                      children: [
                        SmoothPageIndicator(
                          controller: _pageController,
                          count: 3,
                          effect: ExpandingDotsEffect(
                              dotWidth: 5,
                              dotHeight: 5,
                              dotColor: R.color.notActiveGreen,
                              activeDotColor: R.color.mainColor),
                        ),
                        Container(
                          width: double.infinity,
                          margin: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 32),
                          child: _cubit.selectedIndex < 2
                              ? Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                      GestureDetector(
                                        onTap: _cubit.selectedIndex == 0
                                            ? null
                                            : () {
                                                _pageController.previousPage(
                                                  duration: const Duration(
                                                      milliseconds: 400),
                                                  curve: Curves.easeInOut,
                                                );
                                                // _cubit.selectOption(
                                                //     _cubit.selectedIndex--);
                                              },
                                        child: Container(
                                            width: 100 ,
                                            alignment: Alignment.center,
                                            child: Text(R.string.ignore.tr(),
                                                style: TextStyle(
                                                    color:
                                                        _cubit.selectedIndex ==
                                                                0
                                                            ? R.color.gray
                                                            : R.color
                                                                .accentColor,
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w700))),
                                      ),
                                      Container(
                                          width: 128 ,
                                          child: ButtonWidget(
                                              title:
                                                  R.string.text_continue.tr(),
                                              onPressed: () {
                                                _pageController.nextPage(
                                                  duration: const Duration(
                                                      milliseconds: 400),
                                                  curve: Curves.easeInOut,
                                                );
                                                // _cubit.selectOption(
                                                //     _cubit.selectedIndex++);
                                              })),
                                    ])
                              : Wrap(
                                  alignment: WrapAlignment.center,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Container(
                                        width: 128 ,
                                        child: ButtonWidget(
                                            title: R.string.start.tr(),
                                            onPressed: () {
                                              Future.delayed(Duration(milliseconds: 200), () =>
                                              NavigationUtil.popToFirst(context));
                                            })),
                                  ],
                                ),
                        ),
                        SizedBox(height: 16)
                      ],
                    )
                  ]),
                ]),
          ),
    );
  }

  Widget pageFirst(String image, String titleWidget, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 50,
        ),
        Container(height: 240, child: Image.asset(image)),
        SizedBox(
          height: 50,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(titleWidget,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: R.color.textDark,
                    fontSize: 24,
                    fontWeight: FontWeight.w700)),
            SizedBox(width: 10),
            Image.asset(
              R.drawable.ic_pro,
              height: 20,
              color: Utils.getColorByCode(widget.code),
            )
          ],
        ),
        SizedBox(
          height: 12,
        ),
        Text(
          description,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: R.color.textDark,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget pageNext(String image, List<String> descriptions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 50,
        ),
        Container(height: 240, child: Image.asset(image)),
        SizedBox(
          height: 50,
        ),
      ]..addAll(descriptions.map((e) => rowInfoDescription(e)).toList()),
    );
  }

  Widget rowInfoDescription(String title) {
    return Container(
      margin: EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 45,
            padding: EdgeInsets.all(11),
            decoration:
                BoxDecoration(shape: BoxShape.circle, color: R.color.main_6),
            child: Image.asset(
              R.drawable.ic_verify,
              fit: BoxFit.fill,
              height: 22,
            ),
          ),
          SizedBox(
            width: 16 ,
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.left,
              style: TextStyle(
                color: R.color.textDark,
                fontSize: 16,
              ),
            ),
          )
        ],
      ),
    );
  }
}
