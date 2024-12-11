import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/dsmes_appointment/dsmes_appointment_cubit.dart';
import 'package:medical/src/widget/dsmes_appointment/dsmes_appointment_state.dart';
import 'package:medical/src/widget/dsmes_appointment/model/dsmes_clinic_model.dart';
import 'package:medical/src/widget/dsmes_appointment/pages/dsmes_navigation_mixin.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widgets/gap_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class DsmesBookingOfflinePage extends StatefulWidget {
  const DsmesBookingOfflinePage({Key? key}) : super(key: key);

  @override
  _DsmesBookingOfflinePageState createState() =>
      _DsmesBookingOfflinePageState();
}

class _DsmesBookingOfflinePageState extends State<DsmesBookingOfflinePage> {
  final RefreshController _controller = RefreshController();
  late DsmesAppointmentCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<DsmesAppointmentCubit>();
    _cubit.getClinicList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              R.color.color0xFFFDC798.withOpacity(0.3),
              R.color.greenbg.withOpacity(0.9),
            ],
            begin: FractionalOffset(1, 1),
            end: FractionalOffset(0.9, 0.5),
            stops: [0.0, 1.0],
          ),
        ),
        child: BlocProvider(
          create: (context) => _cubit,
          child: BlocConsumer<DsmesAppointmentCubit, DsmesAppointmentState>(
            listener: (context, state) {
              if (state is DsmesAppointmentFailure) {
                Message.showToastMessage(context, state.error);
              }
            },
            builder: (
              BuildContext context,
              DsmesAppointmentState state,
            ) {
              if (state is DsmesAppointmentLoading) {
                BotToast.showLoading();
              } else {
                BotToast.closeAllLoading();
                _controller.refreshCompleted();
              }
              return _buildPage(context, state);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPage(BuildContext context, DsmesAppointmentState state) {
    return Column(
      children: [
        CustomAppBar(
          backgroundColor: Colors.transparent,
          title: Text(
            R.string.choose_center.tr(),
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                // fontFamily: 'sfpro',
                color: R.color.textDark),
          ),
          actions: [
            GestureDetector(
              onTap: () async {
                DsmesNavigationMixin.navigationKey.currentState
                    ?.pushNamed(NavigatorName.dsmes_booking_history);
              },
              child: Container(
                width: 130,
                height: 33,
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                margin: EdgeInsets.fromLTRB(0, 8, 16, 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: R.color.color0xffECFFFD,
                  border: Border.all(
                    color: R.color.color0xffA4E3DD,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      R.icons.ic_clock,
                      width: 16,
                      height: 16,
                      color: R.color.color0xff239A90,
                      fit: BoxFit.scaleDown,
                    ),
                    GapW(4),
                    Text(
                      R.string.consulting_history.tr(),
                      style: TextStyle(
                        fontSize: 14,
                        // fontFamily: 'sfpro',
                        fontWeight: FontWeight.w700,
                        color: R.color.color0xff239A90,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          leadingIcon: IconButton(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            icon: Icon(
              Icons.arrow_back,
              color: R.color.textDark,
            ),
            onPressed: () {
              DsmesNavigationMixin.navigationKey.currentState?.pop(context);
            },
          ),
        ),
        Expanded(
          child: SmartRefresher(
            controller: _controller,
            onRefresh: () => _cubit.getClinicList(),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ListView.separated(
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: _cubit.listClinic.length,
                      separatorBuilder: (context, index) => GapH(16),
                      itemBuilder: (context, index) {
                        DsmesClinicModel data = _cubit.listClinic[index];
                        return _buildClinicItem(data);
                      },
                    ),
                    GapH(20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  _buildClinicItem(DsmesClinicModel data) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: R.color.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(
                    width: 72,
                    child: Image.network(
                        "${Utils.getHostDocosanUrl()}${data.avatar}")),
                GapW(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      GapH(10),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(R.drawable.ic_map_marker,
                              width: 12, height: 12),
                          GapW(5),
                          Flexible(
                            child: Text(
                              data.address,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                                color: R.color.color0xff777E90,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            GapH(12),
            Container(
              width: double.infinity,
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: data.specialty.map((e) {
                  return Container(
                      height: 20,
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: R.color.color0xffFAF0D2,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        e.info.name,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: R.color.color0xffA36E2A,
                        ),
                      ));
                }).toList(),
              ),
            ),
            GapH(16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 40,
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              //TODO: handle navigate to create online booking page
                            },
                            child: Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(200),
                              ),
                              child: Text(
                                R.string.consult_online.tr(),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: R.color.greenGradientBottom,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 40,
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              await _cubit.getClinicDetail(id: data.id);
                              if (_cubit.selectedClinic == null) return;
                              _cubit.initCreateDsmesBookingRequest();
                              await DsmesNavigationMixin
                                  .navigationKey.currentState
                                  ?.pushNamed(
                                      NavigatorName.dsmes_booking_select_date,
                                      arguments: {
                                    'serviceType': 'offline',
                                  });
                            },
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    R.color.greenGradientTop02,
                                    R.color.color0xff008479
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(200),
                              ),
                              padding: EdgeInsets.all(10),
                              child: Text(
                                R.string.consult_at_clinic.tr(),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: R.color.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
