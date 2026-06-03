import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/response/dsmes_clinic_rating_response.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/dsmes_appointment/dsmes_appointment_cubit.dart';
import 'package:medical/src/widget/dsmes_appointment/model/dsmes_appointment_model.dart';
import 'package:medical/src/widget/dsmes_appointment/model/dsmes_clinic_model.dart';
import 'package:medical/src/widget/dsmes_appointment/pages/dsmes_navigation_mixin.dart';
import 'package:medical/src/widget/dsmes_appointment/widgets/dsmes_appointment_item.dart';
import 'package:medical/src/widget/dsmes_appointment/widgets/dsmes_empty_widget.dart';
import 'package:medical/src/widgets/gap_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class DsmesClinicDetailPage extends StatefulWidget {
  final int clinicId;
  final String bookingType; // 'clinic' or 'center'
  const DsmesClinicDetailPage({
    Key? key,
    required this.clinicId,
    this.bookingType = Const.BOOKING_TYPE_CENTER,
  }) : super(key: key);

  @override
  _DsmesClinicDetailPageState createState() => _DsmesClinicDetailPageState();
}

class _DsmesClinicDetailPageState extends State<DsmesClinicDetailPage> {
  late DsmesAppointmentCubit _cubit;
  int _visibleComments = 3;
  bool _showingAll = false;
  Map<String, bool> isProcessing = {
    'onlineConsult': false,
    'clinicConsult': false,
    'clinicBooking': false,
  };

  @override
  void initState() {
    super.initState();
    _cubit = context.read<DsmesAppointmentCubit>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: R.color.backgroundColorNew,
        ),
        child: _buildPage(context),
      ),
    );
  }

  Widget _buildPage(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            CustomAppBar(
              backgroundColor: R.color.transparent,
              title: Text(
                R.string.center_information.tr(),
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    // fontFamily: 'sfpro',
                    color: R.color.textDark),
              ),
              actions: [],
              leadingIcon: IconButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                icon: Icon(
                  Icons.arrow_back,
                  color: R.color.textDark,
                ),
                onPressed: () {
                  DsmesNavigationMixin.getNavigationKey().currentState?.pop(context);
                },
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    children: [
                      _cubit.selectedClinic != null
                          ? _buildClinicItem(_cubit.selectedClinic!)
                          : Center(
                              child: DsmesEmptyWidget(
                                imagePath: R.drawable.bg_empty_clinic,
                                title: R.string.not_exist_clinic.tr(),
                                titleColor: R.color.color0xff636A6B,
                                subtitle: "",
                              ),
                            ),
                      GapH(24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        if (_cubit.selectedClinic != null)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: widget.bookingType == Const.BOOKING_TYPE_CENTER
                ? _buildAppointmentActionButtons()
                : _buildBookingClinicActionButtons(),
          ),
      ],
    );
  }

  _buildClinicItem(DsmesClinicModel data) {
    final locale = context.locale.languageCode;
    final goodAtList = data.getGoodAtByLocale(locale);
    final recentBooking = _cubit.myAppointments
        .where(
          (element) => element.clinicId == data.id,
        )
        .firstOrNull;

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
              crossAxisAlignment: CrossAxisAlignment.start,
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
                      GapH(8),
                      Container(
                        width: double.infinity,
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: data.specialty.take(3).map((e) {
                            return Container(
                                // height: 20,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
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
                    ],
                  ),
                ),
              ],
            ),
            GapH(12),
            Container(
              // height: 70,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(R.drawable.map_location_bg),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 6,
                    child: Text(
                      data.address,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: R.color.color0xff111515,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Flexible(
                    flex: 4,
                    child: GestureDetector(
                      onTap: data.extraAvatar.isNotEmpty
                          ? () {
                              if (widget.bookingType ==
                                  Const.BOOKING_TYPE_CENTER) {
                                showDialog(
                                  context: context,
                                  builder: (context) => Dialog(
                                    child: Image.network(
                                        "${Utils.getHostDocosanUrl()}${data.extraAvatar.first.path}"),
                                  ),
                                );
                              } else {
                                final lat = data.lat;
                                final lng = data.lng;
                                if (lat.isNotEmpty && lng.isNotEmpty) {
                                  launchUrl(
                                      Uri.parse(
                                          'https://www.google.com/maps/search/?api=1&query=$lat,$lng'),
                                      mode: LaunchMode.externalApplication);
                                }
                              }
                            }
                          : null,
                      child: Container(
                        // width: 120,
                        decoration: BoxDecoration(
                          color: R.color.color0xff00B83D,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: EdgeInsets.all(8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: Image.asset(R.drawable.ic_map_direction),
                            ),
                            GapW(5),
                            Text(
                              R.string.view_map.tr(),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: R.color.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (goodAtList.isNotEmpty) GapH(24),
            if (goodAtList.isNotEmpty)
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          goodAtList.first.name,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: R.color.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        Utils.getBoxShadowDropCard(),
                      ],
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    child: Column(
                      children: [
                        ...goodAtList.sublist(1).map((e) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: Image.asset(R.drawable.ic_star),
                                ),
                                GapW(8),
                                Flexible(
                                  child: Text(
                                    e.name,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                      color: R.color.color0xff111515,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ],
              ),
            if (recentBooking != null)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GapH(24),
                  Row(
                    children: [
                      Text(R.string.recent_booking.tr(),
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  GapH(12),
                  DsmesAppointmentItem(
                    data: recentBooking,
                    onChooseService: () async {
                      final recentAppointment = await _cubit
                          .getDsmesAppointmentDetail(appointmentId: recentBooking.id);

                      DsmesNavigationMixin.getNavigationKey().currentState
                          ?.pushNamed(
                        NavigatorName.dsmes_booking_detail,
                        arguments: {
                          'serviceType': recentAppointment?.mode,
                          'appointment': recentAppointment,
                          'previousRoute': NavigatorName.dsmes_clinic_detail,
                        },
                      );
                    },
                    cubit: _cubit,
                    displayActionButtons: false,
                  ),
                ],
              ),
            Visibility(
              visible: _cubit.listClinicReview.isNotEmpty,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GapH(24),
                  Row(
                    children: [
                      Text(
                        R.string.customer_rating.tr(),
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  GapH(12),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(
                      color: R.color.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        Utils.getBoxShadowDropCard(),
                      ],
                    ),
                    child: Column(
                      children: [
                        ..._cubit.listClinicReview
                            .take(_visibleComments)
                            .map((e) {
                          return Column(
                            children: [
                              _buildCommentItem(e),
                              if (e.id !=
                                  _cubit.listClinicReview
                                      .take(_visibleComments)
                                      .last
                                      .id)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14.0, horizontal: 12),
                                  child: Divider(
                                    color: R.color.color0xffDFE4E4,
                                  ),
                                )
                            ],
                          );
                        }).toList(),
                        if (_cubit.listClinicReview.length > 3)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: TextButton(
                                onPressed: () {
                                  setState(() {
                                    if (_showingAll) {
                                      _visibleComments = 3;
                                      _showingAll = false;
                                    } else {
                                      _visibleComments += 3;
                                      if (_visibleComments >=
                                          _cubit.listClinicReview.length) {
                                        _visibleComments =
                                            _cubit.listClinicReview.length;
                                        _showingAll = true;
                                      }
                                    }
                                  });
                                },
                                child: Text(
                                  _showingAll
                                      ? R.string.show_less.tr()
                                      : R.string.show_more.tr(),
                                  style: TextStyle(
                                    color: R.color.color0xff95682E,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildCommentItem(ClinicReview data) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 32,
          child: Image.asset(R.drawable.ic_avatar),
        ),
        GapW(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    data.ratingName,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  GapW(4),
                  Row(
                    children: List.generate(
                      int.tryParse(data.rating) ?? 0,
                      (index) {
                        return Container(
                          height: 16,
                          width: 16,
                          margin: EdgeInsets.only(right: 4),
                          child: Image.asset(R.drawable.ic_star),
                        );
                      },
                    ),
                  ),
                ],
              ),
              if (data.suggestion.isNotEmpty) GapH(12),
              if (data.suggestion.isNotEmpty)
                Container(
                  width: double.infinity,
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: data.suggestion.map((e) {
                      return Container(
                          // height: 20,
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: R.color.color0xffEDEEEE,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            ClinicReview.getSuggestionText(
                                e, context.locale.languageCode),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: R.color.color0xff636A6B,
                            ),
                          ));
                    }).toList(),
                  ),
                ),
              GapH(12),
              Text(
                data.comment,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: R.color.color0xff141416,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  _buildAppointmentActionButtons() {
    final bool hasTelemedicine = _cubit.selectedClinic!
        .hasServiceAvailable(DsmesAppointmentMode.telemedicine);
    final bool hasAtClinic = _cubit.selectedClinic!
        .hasServiceAvailable(DsmesAppointmentMode.atClinic);
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: R.color.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          Utils.getBoxShadowDropButton(),
        ],
      ),
      child: Row(
        children: [
          if (hasTelemedicine)
            Flexible(
              flex: 1,
              child: GestureDetector(
                onTap: () async {
                  if (isProcessing['onlineConsult']!) return;
                  isProcessing['onlineConsult'] = true;
                  try {
                    final detailSuccess =
                        await _cubit.getClinicDetail(id: widget.clinicId);

                    if (!detailSuccess || _cubit.selectedClinic == null) {
                      return;
                    }
                    await _cubit.initCreateDsmesBookingRequest(
                        locale: context.locale.languageCode);

                    DsmesNavigationMixin.getNavigationKey().currentState?.pushNamed(
                        NavigatorName.dsmes_select_service,
                        arguments: {
                          'clinic': _cubit.selectedClinic,
                          'action': 'create',
                          'serviceType':
                              DsmesAppointmentMode.telemedicine.toString()
                        });
                  } finally {
                    isProcessing['onlineConsult'] = false;
                  }
                },
                child: Container(
                  height: 43,
                  decoration: BoxDecoration(
                    color: R.color.white,
                    borderRadius: BorderRadius.circular(200),
                    border: Border.all(
                      color: R.color.greenGradientBottom,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      R.string.consult_online.tr(),
                      style: TextStyle(
                        color: R.color.greenGradientBottom,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (hasAtClinic && hasTelemedicine) GapW(12),
          if (hasAtClinic)
            Flexible(
              flex: 1,
              child: GestureDetector(
                onTap: () async {
                  if (isProcessing['clinicConsult']!) return;
                  isProcessing['clinicConsult'] = true;
                  try {
                    final detailSuccess =
                        await _cubit.getClinicDetail(id: widget.clinicId);

                    if (!detailSuccess || _cubit.selectedClinic == null) {
                      return;
                    }
                    if (_cubit.selectedClinic == null) return;
                    _cubit.initCreateDsmesBookingRequest(
                        locale: context.locale.languageCode);
                    await DsmesNavigationMixin.getNavigationKey().currentState
                        ?.pushNamed(NavigatorName.dsmes_booking_select_date,
                            arguments: {
                          'serviceType':
                              DsmesAppointmentMode.atClinic.toString(),
                          'action': 'create',
                        });
                  } finally {
                    isProcessing['clinicConsult'] = false;
                  }
                },
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: R.color.mainColor,
                    borderRadius: BorderRadius.circular(200),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.centerRight,
                      colors: [
                        R.color.greenGradientTop,
                        R.color.greenGradientMid,
                        R.color.greenGradientBottom,
                      ],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      R.string.consult_at_clinic.tr(),
                      style: TextStyle(
                        color: R.color.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  _buildBookingClinicActionButtons() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 12),
      decoration: BoxDecoration(
        color: R.color.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          Utils.getBoxShadowDropButton(),
        ],
      ),
      child: Row(
        children: [
          Flexible(
            flex: 1,
            child: GestureDetector(
              onTap: () async {
                if (isProcessing['clinicBooking']!) return;
                isProcessing['clinicBooking'] = true;
                try {
                  await _cubit.getClinicDetail(id: widget.clinicId);
                  if (_cubit.selectedClinic == null) return;
                  _cubit.initCreateDsmesBookingRequest(
                      locale: context.locale.languageCode);
                  await DsmesNavigationMixin.getNavigationKey().currentState
                      ?.pushNamed(NavigatorName.dsmes_booking_select_date,
                          arguments: {
                        // 'serviceType': widget.serviceType,
                        'action': 'create',
                        'bookingType': Const.BOOKING_TYPE_CLINIC,
                      });
                } finally {
                  isProcessing['clinicBooking'] = false;
                }
              },
              child: Container(
                height: 44,
                margin: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                decoration: BoxDecoration(
                  color: R.color.mainColor,
                  borderRadius: BorderRadius.circular(200),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.centerRight,
                    colors: [
                      R.color.greenGradientTop,
                      R.color.greenGradientMid,
                      R.color.greenGradientBottom,
                    ],
                  ),
                ),
                child: Center(
                  child: Text(
                    R.string.submit_booking.tr(),
                    style: TextStyle(
                      color: R.color.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
