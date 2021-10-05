import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/detail_package_data.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/HbA1C/widget/description/description_detail.dart';
import 'package:medical/src/widget/detail_package/detail_package_page.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/payment_package/payment_package_page.dart';
import 'package:medical/src/widgets/avatar_widget.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:medical/src/widgets/card_widget.dart';
import 'package:medical/src/widgets/common_page.dart';
import 'package:medical/src/widgets/image_widget.dart';
import 'package:medical/src/widgets/popup_window_widget.dart';
import 'package:medical/src/widgets/text_field_widget.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'upgrade_account.dart';

class UpgradeAccountPage extends StatefulWidget {
  final String code;

  const UpgradeAccountPage({Key? key, required this.code}) : super(key: key);

  @override
  _UpgradeAccountPageState createState() => _UpgradeAccountPageState();
}

class _UpgradeAccountPageState extends State<UpgradeAccountPage> {
  final RefreshController _controller = RefreshController();
  late UpgradeAccountCubit _cubit;
  final TextEditingController _feedbackController = TextEditingController();
  final PageController _packageAdvantageController = PageController();
  final PageController _pageStoryController = PageController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    AppRepository repository = AppRepository();
    _cubit = UpgradeAccountCubit(repository);
    _cubit.getUpgradeAccount(widget.code);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => _cubit,
        child: BlocConsumer<UpgradeAccountCubit, UpgradeAccountState>(
          listener: (context, state) {
            if (state is UpgradeAccountLoading) {
              BotToast.showLoading();
            } else {
              _controller.refreshCompleted();
              BotToast.closeAllLoading();
            }
            if (state is UpgradeAccountFailure) {
              Message.showToastMessage(context, state.error);
            }
          },
          builder: (
            BuildContext context,
            UpgradeAccountState state,
          ) {
            return buildPage(context, state);
          },
        ),
      ),
    );
  }

  Widget buildPage(BuildContext context, UpgradeAccountState state) {
    DetailPackageData? data = _cubit.data;
    return Scaffold(
      backgroundColor: R.color.white,
      body: CommonPage(
        title: data?.name ?? R.string.upgrade_account.tr(),
        background: R.drawable.bg_upgrade_account,
        child: Column(
          children: [
            Expanded(
              child: SmartRefresher(
                controller: _controller,
                onRefresh: () => _cubit.getUpgradeAccount(widget.code, isRefresh: true),
                child: ListView(
                    padding: EdgeInsets.all(16.h),
                    shrinkWrap: true,
                    children: [
                      AspectRatio(
                        aspectRatio: 2,
                        child: ImageWidget(
                          url: data?.image?.url ?? "",
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 23.h),
                        child: Text(
                          data?.advantageHighlight?.toUpperCase() ?? "",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              color: R.color.accentColor,
                              fontWeight: FontWeight.w800,
                              fontSize: 18.sp,
                              height: 1.56,
                              letterSpacing: 0.4),
                        ),
                      ),
                      sliderWidget(data?.packageAdvantages ?? []),
                      SizedBox(
                        height: 30.h,
                      ),
                      Visibility(
                          visible: widget.code == Const.PREMIUM,
                          child: Container(
                              margin: EdgeInsets.only(bottom: 24.h),
                              child: priceWidget(data?.prices ?? []))),
                      tableComparison(data?.featuresComparisonTable ?? []),
                      Visibility(
                        visible: widget.code == Const.PREMIUM,
                        child: Column(
                          children: [
                            SizedBox(
                              height: 32.h,
                            ),
                            storyWidget(data?.successStories ?? []),
                            SizedBox(
                              height: 32.h,
                            ),
                            detailWidget(data),
                          ],
                        ),
                      )
                    ]),
              ),
            ),
            Visibility(
              visible: widget.code == Const.PREMIUM,
              child: Container(
                  decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: R.color.grayBorder,
                          spreadRadius: 0,
                          blurRadius: 5,
                          offset: Offset(0, -3),
                        ),
                      ],
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16))),
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.h, vertical: 24.h),
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
                            if (!Utils.isEmpty(data?.prices)) {
                              int index = widget.code == Const.PREMIUM
                                  ? 0
                                  : _cubit.selectedPrice;
                              NavigationUtil.navigatePage(
                                  context,
                                  PaymentPackagePage(
                                    packageName:
                                        data?.name ?? R.string.diab_pro.tr(),
                                    packageCode: data?.code ?? Const.PRO,
                                    price: data!.prices![index],
                                  ));
                            }
                          },
                        ),
                      ),
                    ],
                  )),
            ),
            Visibility(
              visible: widget.code == Const.PRO,
              child: Container(
                  decoration: BoxDecoration(
                      color: R.color.white,
                      boxShadow: [
                        BoxShadow(
                          color: R.color.grayBorder,
                          spreadRadius: 0,
                          blurRadius: 5,
                          offset: Offset(0, -3),
                        ),
                      ],
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16))),
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.h, vertical: 24.h),
                  child: ButtonWidget(
                    title: R.string.see_detail.tr(),
                    onPressed: () {
                      NavigationUtil.navigatePage(
                          context,
                          DetailPackagePage(
                            code: widget.code,
                          ));
                    },
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget priceWidget(List<Price> listData) {
    Price? price;
    if (!Utils.isEmpty(listData)) {
      price = listData.first;
    }
    return CardWidget(
      borderWidth: 0,
      borderColor: Colors.transparent,
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(R.string.service_price.tr(),
                      style: TextStyle(
                        color: R.color.textDark,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      )),
                  SizedBox(
                    height: 8.h,
                  ),
                  Text(Utils.formatMoney(price?.totalPrice) ?? "",
                      style: TextStyle(
                        color: R.color.textDark,
                        fontSize: 16.sp,
                      )),
                ],
              )),
          Container(
            color: R.color.gray,
            width: 0.7,
            height: 45.h,
          ),
          Expanded(
            flex: 1,
            child: Padding(
                padding: EdgeInsets.only(left: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(R.string.time.tr(),
                        style: TextStyle(
                          color: R.color.textDark,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        )),
                    SizedBox(
                      height: 8.h,
                    ),
                    Text(
                        R.string.number_month
                            .tr(args: [price?.monthUsed?.toString() ?? ""]),
                        style: TextStyle(
                          color: R.color.textDark,
                          fontSize: 16.sp,
                        )),
                  ],
                )),
          )
        ],
      ),
    );
  }

  Widget sliderWidget(List<PackageAdvantage> listData) {
    return Column(
      children: [
        SizedBox(
          height: 100.h,
          child: PageView(
            onPageChanged: (value) {
              _cubit.selectAdvantage(value);
            },
            controller: _packageAdvantageController,
            children: listData
                .map((e) => Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10.h),
                          child: CachedNetworkImage(
                            imageUrl: e.image?.url ?? "",
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                Container(color: R.color.white),
                          ),
                        ),
                        Positioned(
                            left: 24.h,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: Text(e.name ?? "",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: R.color.textDark,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.sp,
                                  )),
                            ))
                      ],
                    ))
                .toList(),
          ),
        ),
        SizedBox(height: 12.h),
        Utils.isEmpty(listData)
            ? Container()
            : SmoothPageIndicator(
                controller: _packageAdvantageController,
                count: listData.length,
                effect: ExpandingDotsEffect(
                    dotWidth: 5,
                    dotHeight: 5,
                    dotColor: R.color.notActiveGreen,
                    activeDotColor: R.color.mainColor),
              ),
      ],
    );
  }

  Widget tableComparison(List<FeaturesComparisonTable> listData) {
    List<TableRow> listRow = [];
    final List<Widget> listCell = [];
    listCell.add(tableCell(
      child: Container(
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(10.h)),
            color: R.color.color0xffB1DDDB),
        padding: EdgeInsets.symmetric(horizontal: 10.h, vertical: 10.h),
        child: Text(R.string.feature.tr(),
            textAlign: TextAlign.start,
            style: TextStyle(
              color: R.color.textDark,
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
            )),
      ),
    ));
    if (widget.code == Const.PRO) {
      listCell.add(
        tableCell(
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(color: R.color.color0xffB1DDDB),
            child: Text(R.string.basic.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: R.color.textDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                )),
          ),
        ),
      );
    }
    listCell.add(tableCell(
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(topRight: Radius.circular(10.h)),
            color: R.color.color0xffB1DDDB),
        child: Text(R.string.diab_pro.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Utils.getColorByCode(Const.PRO),
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
            )),
      ),
    ));
    if (widget.code == Const.PREMIUM) {
      listCell.add(
        tableCell(
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(color: R.color.color0xffB1DDDB),
            child: Text(R.string.diab_premium.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Utils.getColorByCode(Const.PREMIUM),
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                )),
          ),
        ),
      );
    }
    listRow.add(TableRow(children: listCell));
    listRow.addAll(listData.map((e) {
      int index = listData.indexOf(e);
      bool isLast = index + 1 == listData.length;
      return TableRow(children: [
        tableCell(
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    bottomLeft: !isLast ? Radius.zero : Radius.circular(10.h)),
                color:
                    index % 2 == 0 ? R.color.white : R.color.color0xffB1DDDB),
            padding: EdgeInsets.symmetric(horizontal: 10.h, vertical: 10.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                    onTap: () {
                      showDescriptionPopup(e);
                    },
                    child: Image.asset(
                      R.drawable.ic_question_circle,
                      color: R.color.accentColor,
                      fit: BoxFit.fill,
                      height: 24.h,
                    )),
                SizedBox(
                  width: 16.w,
                ),
                Expanded(
                  child: Text(
                    e.name ?? "",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: R.color.textDark,
                      fontSize: 16.sp,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        tableCell(
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color:
                    index % 2 == 0 ? R.color.white : R.color.color0xffB1DDDB),
            child: Image.asset(
              e.toggleStatus?.isEnableBasic == true
                  ? R.drawable.ic_mark
                  : R.drawable.ic_x,
              height: 26.h,
            ),
          ),
        ),
        tableCell(
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    bottomRight: !isLast ? Radius.zero : Radius.circular(10.h)),
                color:
                    index % 2 == 0 ? R.color.white : R.color.color0xffB1DDDB),
            child: Image.asset(
              e.toggleStatus?.isEnablePro == true
                  ? R.drawable.ic_mark
                  : R.drawable.ic_x,
              height: 26.h,
            ),
          ),
        ),
      ]);
    }));
    return Table(
      border: TableBorder(),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: {
        0: FlexColumnWidth(), // fixed to 100 width
        1: FixedColumnWidth(70.h),
        2: FixedColumnWidth(50.h), //fixed to 100 width
      },
      children: listRow,
    );
  }

  void showDescriptionPopup(FeaturesComparisonTable data) {
    showDialog(
      barrierColor: R.color.color0xff003F38.withOpacity(0.9),
      useSafeArea: true,
      barrierDismissible: true,
      context: context,
      builder: (_) => PopupWindowWidget(
          child: Container(
        width: double.infinity,
        // height: ScreenUtil().screenHeight - 150.h,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ImageWidget(
              url: data.image?.url ?? "",
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.name ?? "",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: R.color.textDark,
                          fontWeight: FontWeight.bold,
                          fontSize: 20.sp,
                          letterSpacing: 0.08,
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        data.description ?? "",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: R.color.textDark,
                          fontSize: 16.sp,
                          letterSpacing: 0.4,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 16.h),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      )),
    );
  }

  TableCell tableCell({required Widget child, double? height}) {
    return TableCell(
      child: SizedBox(height: height ?? 74.h, child: child),
    );
  }

  Widget rowInfoDescription(String title, String description) {
    return Container(
      margin: EdgeInsets.only(top: 16.h, left: 16.h, right: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            R.drawable.ic_pro,
            height: 20.h,
            fit: BoxFit.fill,
          ),
          SizedBox(
            width: 12.w,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      color: R.color.textDark,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 3),
                Text(
                  description,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: R.color.textDark,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          )
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
            itemBuilder: (context, index) => Row(
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
            separatorBuilder: (context, index) => SizedBox(
              height: 8.h,
            ),
          )
        ],
      ),
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
                .map((e) => CardWidget(
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
                                name: Utils.getImageUrl(e.image?.url) ?? "",
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
                                        color: R.color.grey_2,
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
        Utils.isEmpty(listStory)
            ? Container()
            : SmoothPageIndicator(
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

  void showModelSheet(BuildContext context) {
    showBarModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider<UpgradeAccountCubit>.value(
          value: _cubit,
          child:
              BlocBuilder<UpgradeAccountCubit, UpgradeAccountState>(builder: (
            BuildContext context,
            UpgradeAccountState state,
          ) {
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
                    rowOptionWidget(R.string.option_already_register.tr(), 0),
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
                                _cubit.sendInterestFeedback(
                                    _feedbackController.text.trim());
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
          controller: _feedbackController,
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
