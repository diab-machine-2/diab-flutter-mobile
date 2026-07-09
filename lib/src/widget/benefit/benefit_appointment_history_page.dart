import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/dsmes_appointment/dsmes_appointment_cubit.dart';
import 'package:medical/src/widget/dsmes_appointment/model/dsmes_appointment_model.dart';
import 'package:medical/src/widget/dsmes_appointment/widgets/dsmes_appointment_item.dart';
import 'package:medical/src/widget/dsmes_appointment/widgets/dsmes_empty_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sticky_headers/sticky_headers.dart';

/// A self-contained appointment history screen for the Benefit / "Lịch hẹn" flow.
///
/// Unlike [DsmesAppointmentHistoryPage], this widget owns its own
/// [DsmesAppointmentCubit] so it can be pushed from any context without
/// requiring a cubit ancestor in the widget tree.
class BenefitAppointmentHistoryPage extends StatefulWidget {
  const BenefitAppointmentHistoryPage({Key? key}) : super(key: key);

  @override
  _BenefitAppointmentHistoryPageState createState() =>
      _BenefitAppointmentHistoryPageState();
}

class _BenefitAppointmentHistoryPageState
    extends State<BenefitAppointmentHistoryPage> {
  final RefreshController _refreshController = RefreshController();
  late DsmesAppointmentCubit _cubit;
  Map<String, bool> isProcessing = {
    'chooseService': false,
  };
  bool isLoading = false;
  List<DsmesAppointment> sortedMyAppointments = [];

  @override
  void initState() {
    super.initState();
    _cubit = DsmesAppointmentCubit(AppRepository());
    _initData();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _initData() async {
    setState(() => isLoading = true);
    final docosanToken = await AppSettings.getDocosanToken();
    if (docosanToken == null || docosanToken.isEmpty) {
      setState(() => isLoading = false);
    } else {
      await _cubit.getDsmesAppointmentList(
          page: 1, isRefresh: true, showLoading: true);
      sortedMyAppointments = _cubit.getSortedAppointments();
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(color: R.color.backgroundColorNew),
          child: Column(
            children: [
              // App bar with green gradient (matches DSMES / Benefit style)
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      R.color.greenGradientTop02,
                      R.color.greenGradientBottom,
                    ],
                    stops: const [0.01, 0.99],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
                child: CustomAppBar(
                  backgroundColor: Colors.transparent,
                  title: Text(
                    R.string.benefit_calendar.tr(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: R.color.white,
                    ),
                  ),
                  leadingIcon: IconButton(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    icon: Icon(Icons.arrow_back, color: R.color.white),
                    onPressed: () =>
                        Navigator.of(context, rootNavigator: true).pop(),
                  ),
                ),
              ),

              // Content
              Expanded(
                child: isLoading
                    ? const SizedBox.shrink()
                    : sortedMyAppointments.isEmpty
                        ? DsmesEmptyWidget(
                            imagePath: R.drawable.dsmes_empty,
                            title: R.string.empty_history_appointment.tr(),
                            titleColor: R.color.color0xff636A6B,
                            subtitle: '',
                          )
                        : SmartRefresher(
                            controller: _refreshController,
                            enablePullUp: _cubit.hasMore,
                            footer: _cubit.hasMore
                                ? ClassicFooter(
                                    loadingText: 'Đang tải',
                                    canLoadingText:
                                        R.string.pull_up_to_load_more.tr(),
                                  )
                                : null,
                            onRefresh: () async {
                              await _cubit.getDsmesAppointmentList(
                                  isRefresh: true, page: 1, showLoading: false);
                              sortedMyAppointments =
                                  _cubit.getSortedAppointments();
                              _refreshController.refreshCompleted();
                              setState(() {});
                            },
                            onLoading: () async {
                              await _cubit.getDsmesAppointmentList(
                                  page: _cubit.currentPage + 1,
                                  showLoading: false);
                              sortedMyAppointments =
                                  _cubit.getSortedAppointments();
                              _refreshController.loadComplete();
                              setState(() {});
                            },
                            child: ListView.builder(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              itemCount: 2, // 2 sections: upcoming & past
                              itemBuilder: (context, sectionIndex) {
                                final incomingAppointments =
                                    sortedMyAppointments.where((a) {
                                  final end =
                                      DateFormat('yyyy-MM-dd HH:mm:ss')
                                          .parse(a.endTime);
                                  final isPast = end.isBefore(DateTime.now());
                                  return a.status == DSMES_STATUS_REQUEST ||
                                      a.status == DSMES_STATUS_ON_HOLD ||
                                      (a.status == DSMES_STATUS_APPROVE &&
                                          !isPast);
                                }).toList();

                                final doneAppointments =
                                    sortedMyAppointments.where((a) {
                                  final end =
                                      DateFormat('yyyy-MM-dd HH:mm:ss')
                                          .parse(a.endTime);
                                  final isPast = end.isBefore(DateTime.now());
                                  return a.status == DSMES_STATUS_REJECT ||
                                      (a.status == DSMES_STATUS_APPROVE &&
                                          isPast);
                                }).toList()
                                      ..sort((a, b) =>
                                          DateFormat('yyyy-MM-dd HH:mm:ss')
                                              .parse(b.startTime)
                                              .compareTo(
                                                  DateFormat(
                                                      'yyyy-MM-dd HH:mm:ss')
                                                  .parse(a.startTime)));

                                final isExpanded = ValueNotifier<bool>(true);

                                return StickyHeader(
                                  header: GestureDetector(
                                    onTap: () =>
                                        isExpanded.value = !isExpanded.value,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      color: R.color.backgroundColorNew,
                                      child: Row(
                                        children: [
                                          Text(
                                            sectionIndex == 0
                                                ? R.string.benefit_upcoming.tr()
                                                : R.string.benefit_past_schedule.tr(),
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const Spacer(),
                                          ValueListenableBuilder<bool>(
                                            valueListenable: isExpanded,
                                            builder:
                                                (context, expanded, child) {
                                              return Icon(
                                                expanded
                                                    ? Icons.keyboard_arrow_up
                                                    : Icons.keyboard_arrow_down,
                                                color: R.color.color0xff636A6B,
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  content: ValueListenableBuilder<bool>(
                                    valueListenable: isExpanded,
                                    builder: (context, expanded, child) {
                                      if (!expanded) {
                                        return const SizedBox.shrink();
                                      }

                                      final appointments = sectionIndex == 0
                                          ? incomingAppointments
                                          : doneAppointments;

                                      return ListView.separated(
                                        padding: EdgeInsets.zero,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: appointments.length,
                                        separatorBuilder: (_, __) =>
                                            const SizedBox(height: 16),
                                        itemBuilder: (context, index) {
                                          final data = appointments[index];
                                          final benefitBookingType = data.mode == DsmesAppointmentMode.telemedicine.toString()
                                              ? Const.BENEFIT_BOOKING_TELEMEDICINE
                                              : Const.BENEFIT_BOOKING_AT_CLINIC;
                                          return DsmesAppointmentItem(
                                            data: data,
                                            displayActionButtons: false,
                                            bookingType: '',
                                            onChooseService: () async {
                                              if (isProcessing[
                                                      'chooseService']!) {
                                                return;
                                              }
                                              isProcessing['chooseService'] =
                                                  true;
                                              try {
                                                final detailSuccess =
                                                    await _cubit.getClinicDetail(
                                                        id: data.clinicId);
                                                if (!detailSuccess ||
                                                    _cubit.selectedClinic ==
                                                        null) {
                                                  return;
                                                }
                                                final appointment =
                                                    await _cubit
                                                        .getDsmesAppointmentDetail(
                                                            appointmentId:
                                                                data.id);
                                                Navigator.of(context,
                                                        rootNavigator: true)
                                                    .pushNamed(
                                                  NavigatorName
                                                      .benefit_booking_detail,
                                                  arguments: {
                                                    'serviceType':
                                                        appointment?.mode,
                                                    'appointment': appointment,
                                                    'previousRoute': NavigatorName
                                                        .benefit_appointment_history,
                                                    'bookingType': benefitBookingType,
                                                  },
                                                );
                                              } finally {
                                                isProcessing['chooseService'] =
                                                    false;
                                              }
                                            },
                                            cubit: _cubit,
                                          );
                                        },
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}