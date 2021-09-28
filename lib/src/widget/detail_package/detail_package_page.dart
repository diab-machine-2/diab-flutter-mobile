import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_statusbar_manager/flutter_statusbar_manager.dart';
import 'package:medical/res/R.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/detail_package_data.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/payment_package/payment_package.dart';
import 'package:medical/src/widgets/avatar_widget.dart';
import 'package:medical/src/widgets/background_page.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:medical/src/widgets/card_widget.dart';
import 'package:medical/src/widgets/text_field_widget.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'detail_package.dart';

class DetailPackagePage extends StatefulWidget {
  final DetailPackageData? data;

  const DetailPackagePage({Key? key, required this.data}) : super(key: key);

  @override
  _DetailPackagePageState createState() => _DetailPackagePageState();
}

class _DetailPackagePageState extends State<DetailPackagePage> {
  late DetailPackageCubit _cubit;
  TextEditingController _controller = TextEditingController();
  final PageController _pageCourseController = PageController();
  final PageController _pageStoryController = PageController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FlutterStatusbarManager.setHidden(true);
    SystemChrome.setEnabledSystemUIOverlays([
      SystemUiOverlay.bottom, //This line is used for showing the bottom bar
    ]);
    AppRepository repository = AppRepository();
    _cubit = DetailPackageCubit(repository, widget.data);
    _cubit.getDetailPackage();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    FlutterStatusbarManager.setHidden(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => _cubit,
        child: BlocConsumer<DetailPackageCubit, DetailPackageState>(
          listener: (context, state) {
            if (state is DetailPackageFailure) {
              Utils.showErrorSnackBar(context, state.error);
            }
            if (state is SendInterestSuccess) {
              NavigationUtil.pop(context);
            }
            if (state is DetailPackageLoading) {
              BotToast.showLoading();
            } else {
              BotToast.closeAllLoading();
            }
          },
          builder: (BuildContext context,
              DetailPackageState state,) {
            return buildPage(context, state);
          },
        ),
      ),
    );
  }

  Widget buildPage(BuildContext context, DetailPackageState state) {
    DetailPackageData? data = _cubit.data;
    return SafeArea(
      top: false,
      child: BackgroundPage(
        background: R.drawable.bg_home,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: [
                  Image.asset(
                    R.drawable.img_list_service, width: double.infinity,
                    height: 240.h,),
                  Container(
                    padding: EdgeInsets.all(16.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 5.h,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(data?.name ?? R.string.diab_pro.tr(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: R.color.textDark,
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.096,
                                  height: 1.25,
                                )),
                            SizedBox(width: 10),
                            Image.asset(
                              R.drawable.ic_pro,
                              fit: BoxFit.contain,
                              color: Utils.getColorByCode(data?.code),
                              height: 20.h,
                              width: 20.h,
                            )
                          ],
                        ),
                        SizedBox(
                          height: 5.h,
                        ),
                        Text(data?.description ?? R.string.des_pro.tr(),
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: R.color.textDark,
                              fontSize: 16.sp,
                              letterSpacing: 0.4,
                              height: 1.375,
                            )),
                        SizedBox(
                          height: 24.h,
                        ),
                        Visibility(
                          visible: data?.code == Const.PRO,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceBetween,
                                children: List.generate(
                                    (data?.prices ?? []).length,
                                        (index) =>
                                        GestureDetector(
                                            onTap: () =>
                                                _cubit.selectPrice(index),
                                            child: packageWidget(
                                                data!.prices![index],
                                                index ==
                                                    _cubit.selectedPrice))),
                              ),
                              SizedBox(
                                height: 32.h,
                              ),
                              courseWidget(iconColor: R.color.green),
                              SizedBox(
                                height: 32.h,
                              ),
                              detailWidget(data),
                              SizedBox(
                                height: 32.h,
                              ),
                              storyWidget(data?.successStories ?? []),
                              SizedBox(
                                height: 40.h,
                              ),
                            ],
                          ),
                        ),
                        Visibility(
                          visible: data?.code == Const.PREMIUM &&
                              !_cubit.isBoughtPro,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                R.string.how_to_register.tr(),
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: R.color.textDark,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 20.sp,
                                  letterSpacing: 0.08,
                                  height: 1.4,
                                ),
                              ),
                              SizedBox(
                                height: 12.h,
                              ),
                              CardWidget(
                                  borderWidth: 0,
                                  borderColor: Colors.transparent,
                                  padding: EdgeInsets.all(16.h),
                                  child: Column(
                                    children: [
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child:
                                        RichText(
                                          text: TextSpan(
                                            text: R.string.upgrade_to_pro.tr(),
                                            style: TextStyle(
                                              color: R.color.textDark,
                                              fontWeight: FontWeight.w400,
                                              fontSize: 16.sp,
                                              letterSpacing: 0.4,
                                              height: 1.375,
                                            ),
                                            children: <TextSpan>[
                                              TextSpan(text: R.string.diab_pro.tr(), style: TextStyle(color: R.color.textDark,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16.sp,
                                                letterSpacing: 0.4,
                                                height: 1.375,)),
                                            ],
                                          ),
                                        )
                                      ),
                                      SizedBox(
                                        height: 16.h,
                                      ),
                                      Container(
                                        width: double.infinity,
                                        margin: EdgeInsets.symmetric(horizontal: 40.h),
                                        child: ButtonWidget(
                                          title: R.string.upgrade_package_pro.tr(),
                                          onPressed: () {

                                          },
                                        ),
                                      ),
                                    ],
                                  )
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Visibility(
              visible: data?.code == Const.PRO,
              child: Container(
                  width: double.infinity,
                  height: 80.h,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: R.color.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: 128.w,
                        child: ButtonWidget(
                          title: R.string.interest.tr(),
                          onPressed: () {
                            showModelSheet(context);
                          },
                          backgroundColor: R.color.white,
                          borderColor: R.color.accentColor,
                          textColor: R.color.accentColor,
                        ),
                      ),
                      Container(
                        width: 128.w,
                        child: ButtonWidget(
                          title: R.string.sign_up.tr(),
                          onPressed: () {
                            if (!Utils.isEmpty(data?.prices))
                              NavigationUtil.navigatePage(
                                  context,
                                  PaymentPackagePage(
                                    packageName:
                                    data?.name ?? R.string.diab_pro.tr(),
                                    packageCode: data?.code ?? Const.PRO,
                                    price: data!.prices![_cubit.selectedPrice],
                                  ));
                          },
                        ),
                      ),
                    ],
                  )),
            )
          ],
        ),
      ),
    );
  }

  Widget courseWidget({String? name,
    String? description,
    Color? iconColor,
    int? numberCourse,
    int? numberHour}) {
    return Column(
      children: [
        Container(
          height: 170.h,
          child: PageView(
            onPageChanged: (value) {
              _cubit.selectCourse(value);
            },
            controller: _pageCourseController,
            children: List.generate(
                4,
                    (index) =>
                    CardWidget(
                      borderWidth: 0,
                      borderColor: Colors.transparent,
                      backgroundImage: R.drawable.bg_pro_group_1,
                      padding: EdgeInsets.symmetric(horizontal: 12.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            name ?? "Hiểu đúng về bệnh lý",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: R.color.textDark,
                              fontWeight: FontWeight.w700,
                              fontSize: 20.sp,
                              letterSpacing: 0.08,
                              height: 1.4,
                            ),
                          ),
                          SizedBox(
                            height: 6.h,
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 100.w),
                            child: Text(
                              description ??
                                  "Cung cấp những kiến thức quan trọng về bệnh đái tháo đường.",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: R.color.textDark,
                                fontWeight: FontWeight.w400,
                                fontSize: 14.sp,
                                letterSpacing: 0.2,
                                height: 1.42857,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 13.h,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    height: 40.h,
                                    padding: EdgeInsets.all(11.h),
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: iconColor?.withOpacity(0.1)),
                                    child: Image.asset(
                                      R.drawable.ic_book,
                                      fit: BoxFit.fill,
                                      color: iconColor,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "25+",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: R.color.textDark,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16.sp,
                                          letterSpacing: 0.4,
                                          height: 1.375,
                                        ),
                                      ),
                                      Text(
                                        R.string.number_course.tr(),
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: R.color.textDark,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 14.sp,
                                          letterSpacing: 0.2,
                                          height: 1.42857,
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                              SizedBox(
                                width: 24.w,
                              ),
                              Row(
                                children: [
                                  Container(
                                    height: 40.h,
                                    padding: EdgeInsets.all(11.h),
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: iconColor?.withOpacity(0.1)),
                                    child: Image.asset(
                                      R.drawable.ic_stack,
                                      fit: BoxFit.fill,
                                      color: iconColor,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "25+",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: R.color.textDark,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16.sp,
                                          letterSpacing: 0.4,
                                          height: 1.375,
                                        ),
                                      ),
                                      Text(
                                        R.string.number_hour.tr(),
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: R.color.textDark,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 14.sp,
                                          letterSpacing: 0.2,
                                          height: 1.42857,
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    )),
          ),
        ),
        SizedBox(height: 12.h),
        SmoothPageIndicator(
          controller: _pageCourseController,
          count: 4,
          effect: ExpandingDotsEffect(
              dotWidth: 5,
              dotHeight: 5,
              dotColor: R.color.notActiveGreen,
              activeDotColor: R.color.mainColor),
        ),
      ],
    );
  }

  Widget storyWidget(List<SuccessStory> listStory) {
    return Column(
      children: [
        Container(
          height: 250.h,
          child: PageView(
            onPageChanged: (value) {
              _cubit.selectStory(value);
            },
            controller: _pageStoryController,
            children: listStory
                .map((e) =>
                CardWidget(
                  borderWidth: 0,
                  borderColor: Colors.transparent,
                  padding: EdgeInsets.symmetric(horizontal: 12.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        R.string.success_story.tr(),
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: R.color.textDark,
                          fontWeight: FontWeight.w700,
                          fontSize: 16.sp,
                          letterSpacing: 0.4,
                          height: 1.375,
                        ),
                      ),
                      SizedBox(
                        height: 12.h,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          AvatarWidget(
                            name: Utils.getImageUrl(e.avatarPath) ?? "",
                            size: 33.h,
                            avatar: e.name,
                          ),
                          SizedBox(width: 20.w),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  e.name ?? "",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: R.color.textDark,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16.sp,
                                    letterSpacing: 0.4,
                                    height: 1.375,
                                  ),
                                ),
                                Text(
                                  e.job ?? "",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: R.color.color0xff787A7D,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14.sp,
                                    letterSpacing: 0.2,
                                    height: 1.42857,
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 22.h,
                      ),
                      Flexible(
                        child: Text(
                          e.story ?? "",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: R.color.color0xff454649,
                            fontWeight: FontWeight.w400,
                            fontSize: 16.sp,
                            letterSpacing: 0.4,
                            height: 1.375,
                          ),
                        ),
                      ),
                    ],
                  ),
                ))
                .toList(),
          ),
        ),
        SizedBox(height: 12.h),
        SmoothPageIndicator(
          controller: _pageStoryController,
          count: listStory.length,
          effect: ExpandingDotsEffect(
              dotWidth: 5,
              dotHeight: 5,
              dotColor: R.color.notActiveGreen,
              activeDotColor: R.color.mainColor),
        ),
      ],
    );
  }

  Widget packageWidget(Price data, bool isSelected) {
    return CardWidget(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 6.h),
      borderColor:
      isSelected ? R.color.accentColor : R.color.grayComponentBorder,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(data.highlight ?? "",
              style: TextStyle(
                  color: R.color.yellow,
                  fontWeight: FontWeight.w600,
                  fontSize: 10.sp,
                  letterSpacing: 0.2,
                  height: 1.4)),
          SizedBox(
            height: 10.h,
          ),
          Text(
              R.string.package_number_month
                  .tr(args: [data.monthUsed?.toString() ?? ""]),
              style: TextStyle(
                  color: R.color.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                  letterSpacing: -0.2,
                  height: 1.375)),
          SizedBox(
            height: 5.h,
          ),
          Text(Utils.formatMoney(data.totalPrice) ?? "",
              style: TextStyle(
                color: R.color.textDark,
                fontSize: 16.sp,
                letterSpacing: 0.4,
                height: 1.375,
              )),
          Text(
              data.monthUsed == 1
                  ? ""
                  : R.string.price_per_month
                  .tr(args: [Utils.formatMoney(data.monthPrice) ?? ""]),
              style: TextStyle(
                color: R.color.gray,
                fontSize: 10.sp,
                letterSpacing: 0.2,
                height: 1.4,
              )),
          SizedBox(
            height: 12.h,
          ),
          Text(data.discount ?? "",
              style: TextStyle(
                color: R.color.green,
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
                letterSpacing: 0.2,
                height: 1.16667,
              )),
        ],
      ),
    );
  }

  Widget detailWidget(DetailPackageData? data) {
    return CardWidget(
      borderWidth: 0,
      borderColor: Colors.transparent,
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            R.string.detail.tr(),
            textAlign: TextAlign.left,
            style: TextStyle(
              color: R.color.textDark,
              fontWeight: FontWeight.w700,
              fontSize: 16.sp,
              letterSpacing: 0.4,
              height: 1.375,
            ),
          ),
          SizedBox(
            height: 8.h,
          ),
          Text(
            data?.detail ?? "",
            textAlign: TextAlign.left,
            style: TextStyle(
              color: R.color.color0xff454649,
              fontSize: 16.sp,
              letterSpacing: 0.4,
              height: 1.375,
            ),
          ),
          SizedBox(
            height: 12.h,
          ),
          ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: NeverScrollableScrollPhysics(),
            itemCount: data?.enableFeatures?.length ?? 0,
            itemBuilder: (context, index) =>
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      R.drawable.ic_verify,
                      fit: BoxFit.fill,
                      height: 15.h,
                    ),
                    SizedBox(
                      width: 7.w,
                    ),
                    Expanded(
                      child: Text(
                        data?.enableFeatures![index].featureName ?? "",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: R.color.color0xff454649,
                          fontSize: 16.sp,
                          letterSpacing: 0.4,
                        ),
                      ),
                    )
                  ],
                ),
            separatorBuilder: (context, index) =>
                SizedBox(
                  height: 8.h,
                ),
          )
        ],
      ),
    );
  }

  void showModelSheet(BuildContext context) {
    showBarModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) =>
      BlocProvider<DetailPackageCubit>.value(
          value: _cubit,
          child: BlocBuilder<DetailPackageCubit, DetailPackageState>(
              builder: (BuildContext context,
                  DetailPackageState state,) {
                return SingleChildScrollView(
                  child: Container(
                    color: R.color.white,
                    child: Column(
                      children: [
                        Container(
                          decoration:
                          BoxDecoration(color: R.color.white, boxShadow: [
                            BoxShadow(
                              color: R.color.accentColor.withOpacity(0.08),
                              spreadRadius: 0,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ]),
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                                vertical: 23.h, horizontal: 31.h),
                            color: R.color.white,
                            child: Text(
                              R.string.interest_course.tr(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: R.color.textDark,
                                fontWeight: FontWeight.w700,
                                fontSize: 16.sp,
                              ),
                            ),
                          ),
                        ),
                        rowOptionWidget(
                            R.string.option_already_register.tr(), 0),
                        rowOptionWidget(R.string.option_need_more_info.tr(), 1),
                        rowOptionWidget(R.string.option_another.tr(), 2),
                        sendMessageWidget(),
                        Container(
                          margin:
                          EdgeInsets.only(top: 24.h, left: 16.h, right: 16.h),
                          child: ButtonWidget(
                            title: R.string.send.tr(),
                            textColor: _cubit.selectedIndexInterest == null
                                ? R.color.gray
                                : R.color.white,
                            onPressed: _cubit.selectedIndexInterest == null
                                ? null
                                : () {
                              _cubit.sendInterestFeedback(_controller.text.trim());
                            },
                          ),
                        ),
                        SizedBox(height: 40.h),
                      ],
                    ),
                  ),
                );
              })),
    );
  }

  Widget sendMessageWidget() {
    return Visibility(
      visible: _cubit.selectedIndexInterest == 2,
      child: Container(
        alignment: Alignment.centerLeft,
        margin: EdgeInsets.only(top: 16.h, left: 16.h, right: 16.h),
        child: TextFieldWidget(
          controller: _controller,
          padding: EdgeInsets.all(16.h),
          maxLines: 5,
          hintText: R.string.hint_msg_to_diab.tr(),
          textInputAction: TextInputAction.send,
          onSubmitted: (text) {
            NavigationUtil.pop(context);
          },
        ),
      ),
    );
  }

  Widget rowOptionWidget(String title, int index) {
    bool isSelected = index == _cubit.selectedIndexInterest;
    return GestureDetector(
      onTap: () => _cubit.selectOptionInterest(index),
      child: Container(
        alignment: Alignment.centerLeft,
        margin: EdgeInsets.only(top: 16.h, left: 16.h, right: 16.h),
        padding: EdgeInsets.symmetric(vertical: 9.h, horizontal: 12.h),
        decoration: BoxDecoration(
            color: isSelected ? R.color.color0xffB1DDDB : R.color.white,
            border: Border.all(
                color: isSelected
                    ? R.color.color0xffB1DDDB
                    : R.color.grayComponentBorder,
                width: 1.5),
            borderRadius: BorderRadius.circular(10)),
        child: Text(
          title,
          style: TextStyle(
              color: isSelected ? R.color.accentColor : R.color.textDark,
              fontSize: 16.sp,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
        ),
      ),
    );
  }
}
