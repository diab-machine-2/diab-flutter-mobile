import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/dsmes_appointment/dsmes_appointment_cubit.dart';
import 'package:medical/src/widget/dsmes_appointment/model/dsmes_appointment_model.dart';
import 'package:medical/src/widget/dsmes_appointment/model/dsmes_clinic_model.dart';
import 'package:medical/src/widget/dsmes_appointment/pages/dsmes_navigation_mixin.dart';
import 'package:medical/src/widgets/gap_widget.dart';

class DsmesBookingOfflinePage extends StatefulWidget {
  final String serviceType;
  const DsmesBookingOfflinePage({
    Key? key,
    required this.serviceType,
  }) : super(key: key);

  @override
  _DsmesBookingOfflinePageState createState() =>
      _DsmesBookingOfflinePageState();
}

class _DsmesBookingOfflinePageState extends State<DsmesBookingOfflinePage> {
  late DsmesAppointmentCubit _cubit;
  Map<String, bool> isProcessing = {
    'clinicDetail': false,
    'onlineConsult': false,
    'clinicConsult': false,
  };

  @override
  void initState() {
    super.initState();
    _cubit = context.read<DsmesAppointmentCubit>();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        print('[POP] offline clinics pop');
        DsmesNavigationMixin.navigationKey.currentState?.pop(context);
        return false;
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            color: R.color.backgroundColorNew,
          ),
          child: _buildPage(context),
        ),
      ),
    );
  }

  Widget _buildPage(BuildContext context) {
    return Column(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [R.color.greenGradientTop02, R.color.greenGradientBottom],
              stops: [0.01, 0.99],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
          child: CustomAppBar(
            backgroundColor: Colors.transparent,
            title: Text(
              R.string.choose_center.tr(),
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  // fontFamily: 'sfpro',
                  color: R.color.white),
            ),
            actions: [
              // GestureDetector(
              //   onTap: () async {
              //     DsmesNavigationMixin.navigationKey.currentState
              //         ?.pushNamed(NavigatorName.dsmes_booking_history);
              //   },
              //   child: Container(
              //     width: 90,
              //     height: 33,
              //     padding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
              //     margin: EdgeInsets.fromLTRB(0, 12, 16, 12),
              //     decoration: BoxDecoration(
              //       borderRadius: BorderRadius.circular(8),
              //       color: R.color.color0xffECFFFD,
              //       border: Border.all(
              //         color: R.color.color0xffA4E3DD,
              //       ),
              //     ),
              //     child: Row(
              //       mainAxisSize: MainAxisSize.min,
              //       mainAxisAlignment: MainAxisAlignment.center,
              //       children: [
              //         SvgPicture.asset(
              //           R.icons.ic_clock,
              //           width: 16,
              //           height: 16,
              //           color: R.color.color0xff239A90,
              //           fit: BoxFit.scaleDown,
              //         ),
              //         GapW(4),
              //         Text(
              //           R.string.consulting_history.tr(),
              //           style: TextStyle(
              //             fontSize: 14,
              //             // fontFamily: 'sfpro',
              //             fontWeight: FontWeight.w700,
              //             color: R.color.color0xff239A90,
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
            ],
            leadingIcon: IconButton(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              icon: Icon(
                Icons.arrow_back,
                color: R.color.white,
              ),
              onPressed: () {
                DsmesNavigationMixin.navigationKey.currentState?.pop(context);
              },
            ),
          ),
        ),
        Expanded(
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
      ],
    );
  }

  _buildClinicItem(DsmesClinicModel data) {
    final bool hasTelemedicine =
        data.hasServiceAvailable(DsmesAppointmentMode.telemedicine);
    final bool hasAtClinic =
        data.hasServiceAvailable(DsmesAppointmentMode.atClinic);
    return GestureDetector(
      onTap: () async {
        if (isProcessing['clinicDetail']!) return;
        isProcessing['clinicDetail'] = true;
        try {
          final detailSuccess = await _cubit.getClinicDetail(id: data.id);

          if (!detailSuccess || _cubit.selectedClinic == null) {
            return;
          }
          await _cubit.getClinicRate(id: data.id);
          DsmesNavigationMixin.navigationKey.currentState?.pushNamed(
              NavigatorName.dsmes_clinic_detail,
              arguments: {'clinicId': data.id});
        } finally {
          isProcessing['clinicDetail'] = false;
        }
      },
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: R.color.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [Utils.getBoxShadowDropCard()],
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
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Image.network(
                            "${Utils.getHostDocosanUrl()}${data.avatar}"),
                      )),
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
                  children: data.specialty.take(3).map((e) {
                    return Container(
                        height: 21,
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: R.color.color0xffFAF0D2,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          e.info.name,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: R.color.color0xffA36E2A,
                          ),
                        ));
                  }).toList(),
                ),
              ),
              GapH(16),
              Row(
                children: [
                  if (hasTelemedicine)
                    Expanded(
                      child: Container(
                        height: 40,
                        child: Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  if (isProcessing['onlineConsult']!) return;
                                  isProcessing['onlineConsult'] = true;
                                  try {
                                    final detailSuccess = await _cubit
                                        .getClinicDetail(id: data.id);

                                    if (!detailSuccess ||
                                        _cubit.selectedClinic == null) {
                                      return;
                                    }
                                    await _cubit.initCreateDsmesBookingRequest(
                                        locale: context.locale.languageCode);

                                    DsmesNavigationMixin
                                        .navigationKey.currentState
                                        ?.pushNamed(
                                            NavigatorName.dsmes_select_service,
                                            arguments: {
                                          'action': 'create',
                                          'clinic': _cubit.selectedClinic,
                                          'serviceType': DsmesAppointmentMode
                                              .telemedicine
                                              .toString(),
                                        });
                                  } finally {
                                    isProcessing['onlineConsult'] = false;
                                  }
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: R.color.color0xffE7FDFB,
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
                  if (hasTelemedicine && hasAtClinic) GapW(12),
                  if (hasAtClinic)
                    Expanded(
                      child: Container(
                        height: 40,
                        child: Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  if (isProcessing['clinicConsult']!) return;
                                  isProcessing['clinicConsult'] = true;
                                  try {
                                    final detailSuccess = await _cubit
                                        .getClinicDetail(id: data.id);

                                    if (!detailSuccess ||
                                        _cubit.selectedClinic == null) {
                                      return;
                                    }
                                    _cubit.initCreateDsmesBookingRequest(
                                        locale: context.locale.languageCode);
                                    await DsmesNavigationMixin
                                        .navigationKey.currentState
                                        ?.pushNamed(
                                            NavigatorName
                                                .dsmes_booking_select_date,
                                            arguments: {
                                          'serviceType': widget.serviceType,
                                          'action': 'create',
                                        });
                                  } finally {
                                    isProcessing['clinicConsult'] = false;
                                  }
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        R.color.greenGradientTop02,
                                        R.color.greenGradientBottom
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
      ),
    );
  }
}
