import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widgets/common_page.dart';
import 'package:medical/src/widgets/custom_circle_chart.dart';
import 'package:medical/src/widgets/custom_progress_chart.dart';
import 'package:medical/src/widgets/pdf_viewer_widget.dart';
import 'package:medical/src/widgets/select_bottom_sheet_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'models/filter_type.dart';
import 'models/report_data.dart';
import 'my_progress.dart';
import 'widgets/report_list_widget.dart';

class MyProgressPage extends StatefulWidget {
  const MyProgressPage();

  @override
  _MyProgressPageState createState() => _MyProgressPageState();
}

class _MyProgressPageState extends State<MyProgressPage> {
  late MyProgressCubit _cubit;
  final RefreshController _controller = RefreshController();

  @override
  void initState() {
    super.initState();
    final AppRepository appRepository = AppRepository();
    _cubit = MyProgressCubit(appRepository);
    _cubit.initData();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _cubit,
      child: Scaffold(
        body: CommonPage(
          background: R.drawable.bg_lesson_detail,
          title: R.string.my_progress.tr(),
          appbarColor: R.color.white,
          showCloseBackButton: true,
          child: BlocConsumer<MyProgressCubit, MyProgressState>(
            listener: (context, state) {
              if (state is MyProgressLoading) {
                BotToast.showLoading();
              } else {
                BotToast.closeAllLoading();
                _controller.refreshCompleted();
              }
              if (state is MyProgressFailure) {
                Message.showToastMessage(context, state.error);
              }
            },
            builder: (context, state) {
              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    decoration: BoxDecoration(
                      color: R.color.white,
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () {
                            showActionFilter(
                                context: context,
                                builder: (context) {
                                  return ReportListWidget(
                                    title: R.string.report.tr(),
                                    reportList: [
                                      ReportData(
                                        title: 'Báo cáo đầu vào',
                                        dateTime: DateTime.now(),
                                        url:
                                            'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
                                      ),
                                      ReportData(
                                        title: 'Báo cáo tiến độ chung',
                                        dateTime: DateTime.now().subtract(
                                          const Duration(days: 1, hours: 2),
                                        ),
                                        url:
                                            'http://www.africau.edu/images/default/sample.pdf',
                                      ),
                                      ReportData(
                                        title:
                                            'Báo cáo tiến độ 6 tháng gần đây',
                                        dateTime: DateTime.now().subtract(
                                          const Duration(days: 1, hours: 7),
                                        ),
                                        url:
                                            'https://www.clickdimensions.com/links/TestPDFfile.pdf',
                                      ),
                                    ],
                                    onSelected: (url) {
                                      NavigationUtil.navigatePage(
                                          context, PDFViewerWidget(url: url));
                                    },
                                  );
                                });
                          },
                          child: Row(
                            children: [
                              Image.asset(
                                R.drawable.ic_report,
                                width: 20,
                                height: 20,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                R.string.report.tr(),
                                style: TextStyle(
                                  color: R.color.textDark,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        InkWell(
                          onTap: () {
                            showActionFilter(
                                context: context,
                                builder: (context) {
                                  return SelectBottomSheetWidget(
                                    title: R.string.loc_theo_thoi_gian.tr(),
                                    isMultipleChoice: false,
                                    selectedList: [
                                      if (_cubit.filterType?.title != null)
                                        _cubit.filterType!.title
                                    ],
                                    elementList: [
                                      FilterType.day14.title,
                                      FilterType.day30.title,
                                      FilterType.all.title,
                                    ],
                                    onSelected: (filter) {
                                      if (filter.isNotEmpty)
                                        _cubit.onChangeFilter(filter.first);
                                    },
                                  );
                                });
                          },
                          child: Row(
                            children: [
                              Stack(
                                children: [
                                  Column(
                                    children: [
                                      const SizedBox(height: 3, width: 24),
                                      Image.asset(
                                        R.drawable.ic_filter_lesson,
                                        width: 20,
                                        height: 20,
                                      ),
                                    ],
                                  ),
                                  Visibility(
                                    visible: _cubit.isFiltering,
                                    child: Positioned(
                                      top: 0,
                                      right: 0,
                                      child: Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: R.color.greenGradientTop,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              width: 2, color: R.color.white),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              Text(_cubit.filterType?.title ?? '',
                                  style: R.style.normalTextStyle),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _cubit.myProgressData == null
                        ? const SizedBox()
                        : Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 24),
                            child: SmartRefresher(
                              controller: _controller,
                              onRefresh: () =>
                                  _cubit.getMyProgress(isRefresh: true),
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    _buildCustomCardLayout(
                                      title: R.string.hoat_dong.tr(),
                                      onTapShowDetail: () {
                                        NavigationUtil.pop(context, result: 0);
                                      },
                                      child: Column(
                                        children: [
                                          CustomProgressChart(
                                            title: R.string.goal.tr(),
                                            mark_1: _cubit.myProgressData?.data
                                                    ?.target?.completed ??
                                                0,
                                            mark_2: _cubit.myProgressData?.data
                                                    ?.target?.unlocked ??
                                                0,
                                            mark_3: _cubit.myProgressData?.data
                                                    ?.target?.total ??
                                                0,
                                          ),
                                          CustomProgressChart(
                                            title: R.string.coach11.tr(),
                                            mark_1: _cubit.myProgressData?.data
                                                    ?.coach11?.completed ??
                                                0,
                                            mark_2: _cubit.myProgressData?.data
                                                    ?.coach11?.unlocked ??
                                                0,
                                            mark_3: _cubit.myProgressData?.data
                                                    ?.coach11?.total ??
                                                0,
                                          ),
                                          CustomProgressChart(
                                            title: R.string.coach1n.tr(),
                                            mark_1: _cubit.myProgressData?.data
                                                    ?.coach1N?.completed ??
                                                0,
                                            mark_2: _cubit.myProgressData?.data
                                                    ?.coach1N?.unlocked ??
                                                0,
                                            mark_3: _cubit.myProgressData?.data
                                                    ?.coach1N?.total ??
                                                0,
                                          ),
                                          // CustomProgressChart(
                                          //   title: 'Livestream',
                                          //   mark_1: _cubit.myProgressData?.data?.coach1N?.completed ?? 0,
                                          //   mark_2: _cubit.myProgressData?.data?.coach1N?.unlocked ?? 0,
                                          //   mark_3: _cubit.myProgressData?.data?.coach1N?.total ?? 0,
                                          // ),
                                        ],
                                      ),
                                      gradient: LinearGradient(
                                        begin: Alignment.bottomLeft,
                                        end: Alignment.topRight,
                                        colors: <Color>[
                                          const Color(0xffF7F0C0)
                                              .withOpacity(0.8),
                                          const Color(0xffFEDABA)
                                              .withOpacity(0.8),
                                        ],
                                      ),
                                    ),
                                    _buildCustomCardLayout(
                                      title: R.string.title_lesson.tr(),
                                      onTapShowDetail: () {
                                        NavigationUtil.pop(context, result: 1);
                                      },
                                      child: _buildCircleChartCard(
                                        mark1: _cubit.myProgressData?.data
                                                ?.lesson?.completed ??
                                            0,
                                        mark2: _cubit.myProgressData?.data
                                                ?.lesson?.unlocked ??
                                            0,
                                        mark3: _cubit.myProgressData?.data
                                                ?.lesson?.total ??
                                            0,
                                      ),
                                    ),
                                    _buildCustomCardLayout(
                                      title: R.string.title_exercise.tr(),
                                      onTapShowDetail: () {
                                        NavigationUtil.pop(context, result: 2);
                                      },
                                      child: _buildCircleChartCard(
                                        mark1: _cubit.myProgressData?.data
                                                ?.exerciseMovement?.completed ??
                                            0,
                                        mark2: _cubit.myProgressData?.data
                                                ?.exerciseMovement?.unlocked ??
                                            0,
                                        mark3: _cubit.myProgressData?.data
                                                ?.exerciseMovement?.total ??
                                            0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCircleChartCard({
    required int mark1,
    required int mark2,
    required int mark3,
  }) {
    final double mark1Percent = mark3 == 0 ? 0 : (mark1 / mark3) * 100;
    final double mark2Percent = mark3 == 0 ? 0 : (mark2 / mark3) * 100;
    final double mark3Percent = 100 - mark1Percent - mark2Percent;
    return Column(
      children: [
        const SizedBox(height: 30),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 20, 30, 20),
                child: CustomCircleChart(
                  mark1: mark1Percent,
                  mark2: mark2Percent,
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    R.string.note.tr(),
                    style: R.style.normalTextStyle,
                  ),
                  const SizedBox(height: 10),
                  _buildSingle(
                      percent: mark1Percent.toInt(),
                      title: R.string.lesson_learned.tr(),
                      backgroundColor: R.color.greenGradientBottom,
                      textColor: R.color.white),
                  const SizedBox(height: 8),
                  _buildSingle(
                      percent: mark2Percent.toInt(),
                      title: R.string.lesson_unlocked.tr(),
                      backgroundColor: R.color.orange_1,
                      textColor: R.color.white),
                  const SizedBox(height: 8),
                  _buildSingle(
                      percent: mark3Percent.toInt(),
                      title: R.string.lesson_not_learned.tr(),
                      backgroundColor: R.color.white,
                      textColor: R.color.textDark),
                ],
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget _buildSingle({
    required int percent,
    required String title,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '$percent%',
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: R.style.normalTextStyle,
          ),
        ),
      ],
    );
  }

  Widget _buildCustomCardLayout({
    required Widget child,
    required String title,
    Gradient? gradient,
    required VoidCallback onTapShowDetail,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: gradient ??
            LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              colors: <Color>[
                const Color(0xffFFF296).withOpacity(0.4),
                const Color(0xffB1DDDB).withOpacity(0.4),
              ],
            ),
        boxShadow: [
          BoxShadow(
              color: R.color.greenGradientBottom.withOpacity(0.08),
              blurRadius: 5.0,
              offset: const Offset(0, 8.0))
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: R.color.textDark,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              InkWell(
                onTap: onTapShowDetail,
                child: Text(
                  R.string.xem_chi_tiet.tr(),
                  style: TextStyle(
                    color: R.color.mainColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
            ],
          ),
          child,
        ],
      ),
    );
  }

  showActionFilter(
      {required BuildContext context,
      required Widget Function(BuildContext) builder}) {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(15),
        ),
      ),
      backgroundColor: R.color.white,
      context: context,
      isScrollControlled: true,
      builder: builder,
    );
  }
}
