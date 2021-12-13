import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widgets/common_page.dart';
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
  final StreamController<bool> _messageController =
      StreamController<bool>.broadcast();

  @override
  void initState() {
    super.initState();
    final AppRepository appRepository = AppRepository();
    _cubit = MyProgressCubit(appRepository);
    _cubit.initData();
  }

  @override
  void dispose() {
    super.dispose();
    _messageController.close();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _cubit,
      child: GestureDetector(
        onTap: () {
          _messageController.sink.add(true);
        },
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
                              _messageController.sink.add(true);
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
                              _messageController.sink.add(true);
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
                                        FilterType.week2.title,
                                        FilterType.week4.title,
                                        FilterType.week6.title,
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
                          : SmartRefresher(
                              controller: _controller,
                              onRefresh: () {
                                _messageController.sink.add(true);
                                _cubit.getMyProgress(isRefresh: true);
                              },
                              child: SingleChildScrollView(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 24),
                                  child: Column(
                                    children: [
                                      _buildCustomCardLayout(
                                        title: R.string.hoat_dong.tr(),
                                        onTapShowDetail: () {
                                          _messageController.sink.add(true);
                                          NavigationUtil.pop(context,
                                              result: 0);
                                        },
                                        child: Column(
                                          children: [
                                            CustomProgressChart(
                                              title: R.string.goal.tr(),
                                              mark1: _cubit.myProgressData?.data
                                                  ?.target?.completed,
                                              mark2: _cubit.myProgressData?.data
                                                  ?.target?.unlocked,
                                              mark3: _cubit.myProgressData?.data
                                                  ?.target?.total,
                                              messageStream:
                                                  _messageController.stream,
                                              onTap: () {
                                                _messageController.sink
                                                    .add(true);
                                              },
                                            ),
                                            CustomProgressChart(
                                              title: R.string.coach11.tr(),
                                              mark1: _cubit.myProgressData?.data
                                                  ?.coach11?.completed,
                                              mark2: _cubit.myProgressData?.data
                                                  ?.coach11?.unlocked,
                                              mark3: _cubit.myProgressData?.data
                                                  ?.coach11?.total,
                                              messageStream:
                                                  _messageController.stream,
                                              onTap: () {
                                                _messageController.sink
                                                    .add(true);
                                              },
                                            ),
                                            CustomProgressChart(
                                              title: R.string.coach1n.tr(),
                                              mark1: _cubit.myProgressData?.data
                                                  ?.coach1N?.completed,
                                              mark2: _cubit.myProgressData?.data
                                                  ?.coach1N?.unlocked,
                                              mark3: _cubit.myProgressData?.data
                                                  ?.coach1N?.total,
                                              messageStream:
                                                  _messageController.stream,
                                              onTap: () {
                                                _messageController.sink
                                                    .add(true);
                                              },
                                            ),
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
                                          _messageController.sink.add(true);
                                          NavigationUtil.pop(context,
                                              result: 1);
                                        },
                                        child: CustomProgressChart(
                                          mark1: _cubit.myProgressData?.data
                                                  ?.lesson?.completed ??
                                              0,
                                          mark2: _cubit.myProgressData?.data
                                                  ?.lesson?.unlocked ??
                                              0,
                                          mark3: _cubit.myProgressData?.data
                                                  ?.lesson?.total ??
                                              0,
                                          messageStream:
                                              _messageController.stream,
                                          onTap: () {
                                            _messageController.sink.add(true);
                                          },
                                        ),
                                      ),
                                      _buildCustomCardLayout(
                                        title: R.string.title_exercise.tr(),
                                        onTapShowDetail: () {
                                          NavigationUtil.pop(context,
                                              result: 2);
                                        },
                                        child: CustomProgressChart(
                                          mark1: _cubit
                                                  .myProgressData
                                                  ?.data
                                                  ?.exerciseMovement
                                                  ?.completed ??
                                              0,
                                          mark2: _cubit
                                                  .myProgressData
                                                  ?.data
                                                  ?.exerciseMovement
                                                  ?.unlocked ??
                                              0,
                                          mark3: _cubit.myProgressData?.data
                                                  ?.exerciseMovement?.total ??
                                              0,
                                          messageStream:
                                              _messageController.stream,
                                          onTap: () {
                                            _messageController.sink.add(true);
                                          },
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
      ),
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
