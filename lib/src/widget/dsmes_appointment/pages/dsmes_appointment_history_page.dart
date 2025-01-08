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

  @override
  void initState() {
    super.initState();
    _cubit = context.read<DsmesAppointmentCubit>();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sortedMyAppointments = _cubit.myAppointments;
    sortedMyAppointments.sort((a, b) {
      final aTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(a.startTime);
      final bTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(b.startTime);
      return bTime.compareTo(aTime);
    });
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
                child: sortedMyAppointments.isEmpty
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
                                    R.string.release_to_load_more.tr(),
                                idleText: R.string.pull_up_to_load_more.tr(),
                              )
                            : null,
                        onRefresh: () async {
                          await _cubit.getDsmesAppointmentList(
                              isRefresh: true, page: 1);
                          _refreshController.refreshCompleted();
                          setState(() {});
                        },
                        onLoading: () async {
                          await _cubit.getDsmesAppointmentList(
                              page: _cubit.currentPage + 1);
                          _refreshController.loadComplete();
                          setState(() {});
                        },
                        child: ListView.separated(
                          padding: EdgeInsets.all(16),
                          itemCount: sortedMyAppointments.length,
                          separatorBuilder: (context, index) =>
                              SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            DsmesAppointment data = sortedMyAppointments[index];
                            return DsmesAppointmentItem(
                              data: data,
                              onChooseService: () async {
                                if (isProcessing['chooseService']!) return;
                                isProcessing['chooseService'] = true;
                                try {
                                  await _cubit.getClinicDetail(
                                      id: data.clinicId);
                                  final appointment =
                                      await _cubit.getDsmesAppointmentDetail(
                                          appointmentId: data.id);

                                  DsmesNavigationMixin
                                      .navigationKey.currentState
                                      ?.pushNamed(
                                    NavigatorName.dsmes_booking_detail,
                                    arguments: {
                                      'serviceType': appointment?.mode,
                                      'appointment': appointment
                                    },
                                  );
                                } finally {
                                  isProcessing['chooseService'] = false;
                                }
                              },
                              cubit: _cubit,
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
