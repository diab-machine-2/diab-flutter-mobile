import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/detail_package_data.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/payment_package/payment_package.dart';
import 'package:medical/src/widgets/avatar_widget.dart';
import 'package:medical/src/widgets/background_page.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:medical/src/widgets/card_widget.dart';
import 'package:medical/src/widgets/image_widget.dart';
import 'package:medical/src/widgets/text_field_widget.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'detail_package.dart';

class DetailPackagePage extends StatefulWidget {
  final String code;
  final bool isBuyDirect;

  const DetailPackagePage({Key? key, required this.code, this.isBuyDirect = true}) : super(key: key);

  @override
  _DetailPackagePageState createState() => _DetailPackagePageState();
}

class _DetailPackagePageState extends State<DetailPackagePage> {
  final RefreshController _controller = RefreshController();
  late DetailPackageCubit _cubit;
  final TextEditingController _feedbackController = TextEditingController();
  final PageController _pageCourseController = PageController();
  final PageController _pageStoryController = PageController();

  @override
  void initState() {
    super.initState();
    // FlutterStatusbarManager.setHidden(true);
    AppRepository repository = AppRepository();
    _cubit = DetailPackageCubit(repository, widget.code);
    _cubit.getDetailPackage();
  }

  @override
  void dispose() {
    // FlutterStatusbarManager.setHidden(false);
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
              Message.showToastMessage(context, state.error);
            }
            if (state is SendInterestSuccess) {
              NavigationUtil.pop(context);
            }
          },
          builder: (BuildContext context,
              DetailPackageState state,) {
            if (state is DetailPackageLoading) {
              BotToast.showLoading();
            } else {
              _controller.refreshCompleted();
              BotToast.closeAllLoading();
            }
            return buildPage(context, state);
          },
        ),
      ),
    );
  }

  Widget buildPage(BuildContext context, DetailPackageState state) {
    DetailPackageData? data = _cubit.data;
    return BackgroundPage(
      background: R.drawable.bg_upgrade_account,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: SmartRefresher(
              controller: _controller,
              onRefresh: () => _cubit.getDetailPackage(isRefresh: true),
              child: ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                children: [
                  Stack(
                    children: [
                      Image.asset(
                        R.drawable.img_list_service, width: double.infinity,
                        fit: BoxFit.fill,
                        height: 240,),
                      Positioned(
                        top: 40,
                        left: 15,
                        child: GestureDetector(
                          onTap: () => NavigationUtil.pop(context),
                          child: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: R.color.textDark
                            ),
                            child: Icon(CupertinoIcons.arrow_left, color: R.color.white, size: 24)
                          ),
                        ),
                      )
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(data?.name ?? R.string.package_pro.tr(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: R.color.textDark,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.096,
                                  height: 1.25,
                                )),
                            SizedBox(width: 10),
                            Image.asset(
                              R.drawable.ic_pro,
                              fit: BoxFit.contain,
                              color: Utils.getColorByCode(data?.code),
                              height: 20,
                              width: 20,
                            )
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(data?.description ?? R.string.des_pro.tr(),
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: R.color.textDark,
                              fontSize: 16,
                              letterSpacing: 0.4,
                              height: 1.375,
                            )),
                        SizedBox(
                          height: 24,
                        ),
                        Visibility(
                          visible: data?.code == Const.PRO,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              rowPriceWidget(data?.prices ?? []),
                              SizedBox(
                                height: 32,
                              ),
                              courseWidget(data?.courseSections ?? []),
                              SizedBox(
                                height: 32,
                              ),
                              storyWidget(data?.successStories ?? []),
                              SizedBox(
                                height: 32,
                              ),
                              detailWidget(data),
                              SizedBox(
                                height: 20,
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
          ),
          Visibility(
            visible: data?.code == Const.PRO,
            child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 24),
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
                      width: 128 ,
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
                      width: 128 ,
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
                                  isBuyDirect: widget.isBuyDirect,
                                ));
                        },
                      ),
                    ),
                  ],
                )),
          ),
        ],
      ),
    );
  }

  Widget rowPriceWidget(List<Price> listData) {
    return Row(
      mainAxisAlignment: MainAxisAlignment
          .spaceBetween,
      children: List.generate(
          listData.length,
              (index) =>
              GestureDetector(
                  onTap: () =>
                      _cubit.selectPrice(index),
                  child: packageWidget(
                      listData[index],
                      index ==
                          _cubit.selectedPrice))),
    );
  }

  Widget courseWidget(List<CourseSection> listData) {
    return Column(
      children: [
        Container(
          height: 170,
          child: PageView(
            onPageChanged: (value) {
              _cubit.selectCourse(value);
            },
            controller: _pageCourseController,
            children: listData.map(
                    (data) =>
                    Stack(
                      children: [
                        ImageWidget(url: data.image?.url),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                data.name ?? "",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: R.color.textDark,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 20,
                                  letterSpacing: 0.08,
                                  height: 1.4,
                                ),
                              ),
                              SizedBox(
                                height: 6,
                              ),
                              Padding(
                                padding: EdgeInsets.only(right: 100),
                                child: Text(
                                  data.description ??
                                      "",
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: R.color.textDark,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    letterSpacing: 0.2,
                                    height: 1.42857,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 13,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        height: 40,
                                        padding: EdgeInsets.all(11),
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Utils.parseStringToColor(data.hexCode).withOpacity(0.4)),
                                        child: Image.asset(
                                          R.drawable.ic_book,
                                          fit: BoxFit.fill,
                                          color: Utils.parseStringToColor(data.hexCode),
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            (data.totalLesson ?? 0).toString(),
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                              color: R.color.textDark,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 16,
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
                                              fontSize: 14,
                                              letterSpacing: 0.2,
                                              height: 1.42857,
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    width: 24 ,
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        height: 40,
                                        padding: EdgeInsets.all(11),
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Utils.parseStringToColor(data.hexCode).withOpacity(0.4)),
                                        child: Image.asset(
                                          R.drawable.ic_stack,
                                          fit: BoxFit.fill,
                                          color: Utils.parseStringToColor(data.hexCode),
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            (data.totalHours ?? 0).toString(),
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                              color: R.color.textDark,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 16,
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
                                              fontSize: 14,
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
                        ),
                      ],
                    )).toList(),
          ),
        ),
        SizedBox(height: 12),
        Utils.isEmpty(listData) ? Container() : SmoothPageIndicator(
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
          height: 250,
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
                  padding: EdgeInsets.symmetric(horizontal: 12),
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
                          fontSize: 16,
                          letterSpacing: 0.4,
                          height: 1.375,
                        ),
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          AvatarWidget(
                            name: Utils.getImageUrl(e.image?.url) ?? "",
                            size: 33,
                            avatar: e.name,
                          ),
                          SizedBox(width: 20),
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
                                    fontSize: 16,
                                    letterSpacing: 0.4,
                                    height: 1.375,
                                  ),
                                ),
                                Text(
                                  e.job ?? "",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: R.color.grey_2,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
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
                        height: 22,
                      ),
                      Flexible(
                        child: Text(
                          e.story ?? "",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: R.color.grey_1,
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
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
        SizedBox(height: 12),
        Utils.isEmpty(listStory) ? Container() : SmoothPageIndicator(
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
    return Container(
      constraints: new BoxConstraints(
        minWidth: 107 ,
      ),
      child: CardWidget(
        padding: EdgeInsets.symmetric(vertical: 12),
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
                    fontSize: 10,
                    letterSpacing: 0.2,
                    height: 1.4)),
            SizedBox(
              height: 10,
            ),
            Text(
                R.string.package_number_month
                    .tr(args: [data.monthUsed?.toString() ?? ""]),
                style: TextStyle(
                    color: R.color.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: -0.2,
                    height: 1.375)),
            SizedBox(
              height: 5,
            ),
            Text(Utils.formatMoney(data.totalPrice) ?? "",
                style: TextStyle(
                  color: R.color.textDark,
                  fontSize: 16,
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
                  fontSize: 10,
                  letterSpacing: 0.2,
                  height: 1.4,
                )),
            SizedBox(
              height: 12,
            ),
            Text(data.discount ?? "",
                style: TextStyle(
                  color: R.color.green,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  letterSpacing: 0.2,
                  height: 1.16667,
                )),
          ],
        ),
      ),
    );
  }

  Widget detailWidget(DetailPackageData? data) {
    return CardWidget(
      borderWidth: 0,
      borderColor: Colors.transparent,
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            R.string.detail.tr(),
            textAlign: TextAlign.left,
            style: TextStyle(
              color: R.color.textDark,
              fontWeight: FontWeight.w700,
              fontSize: 16,
              letterSpacing: 0.4,
              height: 1.375,
            ),
          ),
          SizedBox(
            height: 8,
          ),
          Text(
            data?.detail ?? "",
            textAlign: TextAlign.left,
            style: TextStyle(
              color: R.color.grey_1,
              fontSize: 16,
              letterSpacing: 0.4,
              height: 1.375,
            ),
          ),
          SizedBox(
            height: 12,
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
                      height: 15,
                    ),
                    SizedBox(
                      width: 7 ,
                    ),
                    Expanded(
                      child: Text(
                        data?.enableFeatures![index].featureName ?? "",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: R.color.grey_1,
                          fontSize: 16,
                          letterSpacing: 0.4,
                        ),
                      ),
                    )
                  ],
                ),
            separatorBuilder: (context, index) =>
                SizedBox(
                  height: 8,
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
                                vertical: 23, horizontal: 31),
                            color: R.color.white,
                            child: Text(
                              R.string.interest_course.tr(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: R.color.textDark,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
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
                          EdgeInsets.only(top: 24, left: 16, right: 16),
                          child: ButtonWidget(
                            title: R.string.send.tr(),
                            textColor: _cubit.selectedIndexInterest == null
                                ? R.color.gray
                                : R.color.white,
                            onPressed: _cubit.selectedIndexInterest == null
                                ? null
                                : () {
                              _cubit.sendInterestFeedback(_feedbackController.text.trim());
                            },
                          ),
                        ),
                        SizedBox(height: 40),
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
        margin: EdgeInsets.only(top: 16, left: 16, right: 16),
        child: TextFieldWidget(
          controller: _feedbackController,
          padding: EdgeInsets.all(16),
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
        margin: EdgeInsets.only(top: 16, left: 16, right: 16),
        padding: EdgeInsets.symmetric(vertical: 9, horizontal: 12),
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
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
        ),
      ),
    );
  }
}
