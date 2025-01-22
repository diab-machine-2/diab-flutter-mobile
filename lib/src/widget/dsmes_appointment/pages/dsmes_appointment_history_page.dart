import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/dsmes_appointment/dsmes_appointment_cubit.dart';
import 'package:medical/src/widget/dsmes_appointment/model/dsmes_appointment_model.dart';
import 'package:medical/src/widget/dsmes_appointment/pages/dsmes_navigation_mixin.dart';
import 'package:medical/src/widget/dsmes_appointment/widgets/dsmes_appointment_item.dart';
import 'package:medical/src/widget/dsmes_appointment/widgets/dsmes_empty_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sticky_headers/sticky_headers.dart';

class DsmesAppointmentHistoryPage extends StatefulWidget {
  @override
  _DsmesAppointmentHistoryPageState createState() =>
      _DsmesAppointmentHistoryPageState();
}

class _DsmesAppointmentHistoryPageState
    extends State<DsmesAppointmentHistoryPage> {
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
    _cubit = context.read<DsmesAppointmentCubit>();
    _initData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _initData() async {
    isLoading = true;
    final docosanToken = await AppSettings.getDocosanToken();
    if (docosanToken == null || docosanToken.isEmpty) {
      setState(() {
        isLoading = false;
      });
    } else {
      await _cubit.getDsmesAppointmentList(
          page: 1, isRefresh: true, showLoading: true);
      sortedMyAppointments = _cubit.getSortedAppointments();
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: R.color.backgroundColorNew,
        ),
        child: BlocProvider(
          create: (context) => _cubit,
          child: Column(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      R.color.greenGradientTop02,
                      R.color.greenGradientBottom
                    ],
                    stops: [0.01, 0.99],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
                child: CustomAppBar(
                  backgroundColor: Colors.transparent,
                  title: Text(
                    R.string.consulting_history.tr(),
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        // fontFamily: 'sfpro',
                        color: R.color.white),
                  ),
                  leadingIcon: IconButton(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    icon: Icon(
                      Icons.arrow_back,
                      color: R.color.white,
                    ),
                    onPressed: () {
                      DsmesNavigationMixin.navigationKey.currentState
                          ?.pop(context);
                    },
                  ),
                ),
              ),
              Expanded(
                child: isLoading
                    ? Container()
                    : sortedMyAppointments.isEmpty
                        ? DsmesEmptyWidget(
                            imagePath: R.drawable.dsmes_empty,
                            title: R.string.empty_history_appointment.tr(),
                            titleColor: R.color.color0xff636A6B,
                            subtitle: "",
                          )
                        : SmartRefresher(
                            controller: _refreshController,
                            enablePullUp: _cubit.hasMore,
                            footer: _cubit.hasMore
                                ? ClassicFooter(
                                    loadingText: "Đang tải",
                                    canLoadingText:
                                        R.string.pull_up_to_load_more.tr(),
                                    // idleText: R.string.pull_up_to_load_more.tr(),
                                  )
                                : null,
                            onRefresh: () async {
                              await _cubit.getDsmesAppointmentList(
                                  isRefresh: true, page: 1, showLoading: false);
                              _refreshController.refreshCompleted();
                              setState(() {});
                            },
                            onLoading: () async {
                              await _cubit.getDsmesAppointmentList(
                                  page: _cubit.currentPage + 1);
                              _refreshController.loadComplete();
                              setState(() {});
                            },
                            child: ListView.builder(
                              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                              itemCount: 2, // 2 sections: Incoming and Done
                              itemBuilder: (context, sectionIndex) {
                                // Split appointments into incoming and done
                                final incomingAppointments =
                                    sortedMyAppointments.where((appointment) {
                                  final endDateTime =
                                      DateFormat('yyyy-MM-dd HH:mm:ss')
                                          .parse(appointment.endTime);
                                  final isPast =
                                      endDateTime.isBefore(DateTime.now());
                                  return appointment.status ==
                                          DSMES_STATUS_REQUEST ||
                                      (appointment.status ==
                                              DSMES_STATUS_APPROVE &&
                                          !isPast);
                                }).toList();

                                final doneAppointments =
                                    sortedMyAppointments.where((appointment) {
                                  final endDateTime =
                                      DateFormat('yyyy-MM-dd HH:mm:ss')
                                          .parse(appointment.endTime);
                                  final isPast =
                                      endDateTime.isBefore(DateTime.now());
                                  return appointment.status ==
                                          DSMES_STATUS_REJECT ||
                                      (appointment.status ==
                                              DSMES_STATUS_APPROVE &&
                                          isPast);
                                }).toList();

                                // Manage expansion state
                                final isExpanded = ValueNotifier<bool>(true);

                                return StickyHeader(
                                  header: GestureDetector(
                                    onTap: () =>
                                        isExpanded.value = !isExpanded.value,
                                    child: Container(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 12),
                                      color: R.color.backgroundColorNew,
                                      child: Row(
                                        children: [
                                          Text(
                                            sectionIndex == 0
                                                ? 'Sắp diễn ra'
                                                : 'Lịch trước đó',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          Spacer(),
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
                                      if (!expanded) return SizedBox.shrink();

                                      final appointments = sectionIndex == 0
                                          ? incomingAppointments
                                          : doneAppointments;

                                      return ListView.separated(
                                        padding: EdgeInsets.zero,
                                        physics: NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: appointments.length,
                                        separatorBuilder: (context, index) =>
                                            SizedBox(height: 16),
                                        itemBuilder: (context, index) {
                                          DsmesAppointment data =
                                              appointments[index];
                                          return DsmesAppointmentItem(
                                            data: data,
                                            displayActionButtons: false,
                                            onChooseService: () async {
                                              if (isProcessing[
                                                  'chooseService']!) return;
                                              isProcessing['chooseService'] =
                                                  true;
                                              try {
                                                await _cubit.getClinicDetail(
                                                    id: data.clinicId);
                                                final appointment = await _cubit
                                                    .getDsmesAppointmentDetail(
                                                        appointmentId: data.id);

                                                DsmesNavigationMixin
                                                    .navigationKey.currentState
                                                    ?.pushNamed(
                                                  NavigatorName
                                                      .dsmes_booking_detail,
                                                  arguments: {
                                                    'serviceType':
                                                        appointment?.mode,
                                                    'appointment': appointment,
                                                    'previousRoute': NavigatorName
                                                        .dsmes_booking_history,
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
