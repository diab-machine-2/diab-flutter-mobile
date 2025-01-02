import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/modal/user/user_model.dart';
import 'package:medical/src/model/request/dsmes_reschedule_request.dart';
import 'package:medical/src/utils/date_utils.dart';
import 'package:medical/src/utils/length_limit_text_field.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/dsmes_appointment/dsmes_appointment_cubit.dart';
import 'package:medical/src/widget/dsmes_appointment/model/dsmes_appointment_model.dart';
import 'package:medical/src/widget/dsmes_appointment/pages/dsmes_navigation_mixin.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/profile/user_info.dart';
import 'package:medical/src/widgets/gap_widget.dart';

class DsmesConfirmCreateInformation extends StatefulWidget {
  final String serviceType;
  final String action;
  final int? appointmentId;

  const DsmesConfirmCreateInformation({
    Key? key,
    required this.serviceType,
    this.action = 'create',
    this.appointmentId,
  }) : super(key: key);

  @override
  _DsmesConfirmCreateInformationState createState() =>
      _DsmesConfirmCreateInformationState();
}

class _DsmesConfirmCreateInformationState
    extends State<DsmesConfirmCreateInformation> {
  late DsmesAppointmentCubit _cubit;
  late String requesterName;
  late String requesterPhone;
  late String requesterSymptom;

  FocusNode nameFocusNode = FocusNode();
  FocusNode phoneFocusNode = FocusNode();
  FocusNode symptomFocusNode = FocusNode();
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController symptomController;

  late bool isReschedule = false;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<DsmesAppointmentCubit>();
    final currentCreateRequest = _cubit.createDsmesBookingRequest;
    requesterName = currentCreateRequest?.patientName ??
        AppSettings.userInfo?.fullName ??
        '';
    requesterPhone = currentCreateRequest?.patientPhoneNumber ??
        AppSettings.userInfo?.phoneNumber ??
        '';

    requesterSymptom = currentCreateRequest?.symptom ?? '';

    nameController = TextEditingController(text: requesterName);
    phoneController = TextEditingController(text: requesterPhone);
    symptomController = TextEditingController(text: requesterSymptom);

    isReschedule = widget.action == 'reschedule';
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
        GestureDetector(
          onTap: () {
            Utils.hideKeyboard(context);
          },
          child: Column(
            children: [
              CustomAppBar(
                backgroundColor: Colors.transparent,
                title: Text(
                  R.string.confirm_information.tr(),
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
                    DsmesNavigationMixin.navigationKey.currentState
                        ?.pop(context);
                  },
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildPatientInformation(),
                        GapH(12),
                        _buildConsultingInformation(),
                        if (widget.serviceType ==
                            DsmesAppointmentMode.telemedicine.toString())
                          GapH(12),
                        if (widget.serviceType ==
                            DsmesAppointmentMode.telemedicine.toString())
                          _buildSelectedServiceInformation(),
                        GapH(12),
                        _buildNoticeSymptom(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            color: R.color.white,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: _buildButton(R.string.confirm_book_consult.tr(),
                      () async {
                    if (widget.action == 'reschedule' &&
                        widget.appointmentId != null) {
                      _handleRescheduleBooking();
                    }

                    if (widget.action == 'create' || widget.action == 'edit') {
                      final phoneNumber = AppSettings.userInfo?.phoneNumber ??
                          phoneController.text;

                      if (phoneNumber.isEmpty) {
                        await _showDialogUpdatePhone();
                        return;
                      }

                      _handleCreateBooking();
                    }
                  }),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  _handleCreateBooking() async {
    _cubit.updateCreateDsmesBookingRequestSymptom(
        symptom: symptomController.text);
    final phoneNumber =
        AppSettings.userInfo?.phoneNumber ?? phoneController.text;

    final token = await AppSettings.getDocosanToken();
    if (token.isEmpty) {
      await _cubit.registerDocosanUser(phoneNumber: phoneNumber);
      await AppSettings.clearOrganizationApiKey();
    }

    DsmesAppointment? resp;

    if (widget.serviceType == DsmesAppointmentMode.atClinic.toString()) {
      resp = await _cubit.createDsmesBooking();
    } else {
      resp = await _cubit.createDsmesBookingOnline();
    }

    if (resp == null) return;

    final startTime = DateFormat('HH:mm')
        .format(DateFormat('yyyy-MM-dd HH:mm').parse(resp.startTime));
    final startDate = DateFormat('dd/MM/yyyy')
        .format(DateFormat('yyyy-MM-dd HH:mm').parse(resp.startTime));

    _showPopupBookingSuccess(
      title2: R.string.congratulation_on.tr(),
      title: R.string.booking_success_dialog_title.tr(),
      subtitle: R.string.confirm_booking_subtitle.tr(namedArgs: {
        'time': startTime,
        'date': startDate,
      }),
      isShowImg: true,
      primaryButtonTitle: R.string.back_home_page.tr(),
      secondaryButtonTitle: R.string.recheck_information.tr(),
      onNavigateHome: () {
        // Back to homepage
        Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
          NavigatorName.tabbar,
          (route) => false, // This removes all routes from stack
        );
      },
      onShowInfo: () async {
        // Navigate to booking detail
        final myAppointment =
            await _cubit.getDsmesAppointmentDetail(appointmentId: resp!.id);

        if (myAppointment == null) return;

        DsmesNavigationMixin.navigationKey.currentState?.pushNamed(
          NavigatorName.dsmes_booking_detail,
          arguments: {
            'serviceType': widget.serviceType,
            'appointment': myAppointment,
          },
        );
      },
    );
  }

  _handleRescheduleBooking() async {
    final resp = await _cubit.rescheduleDsmesBooking(
      request: RescheduleDsmesBookingRequest(
          appointmentId: AppointmentId(id: widget.appointmentId!),
          startTime: _cubit.createDsmesBookingRequest!.startTime),
    );
    if (resp == null) return;

    final myAppointment =
        await _cubit.getDsmesAppointmentDetail(appointmentId: resp.id);

    if (myAppointment == null) return;

    DsmesNavigationMixin.navigationKey.currentState?.pushNamed(
      NavigatorName.dsmes_booking_detail,
      arguments: {
        'serviceType': widget.serviceType,
        'appointment': myAppointment,
      },
    );
  }

  String getTimeRange(String startTime, String endTime) {
    final start = DateFormat('HH:mm')
        .format(DateFormat('yyyy-MM-dd HH:mm').parse(startTime));
    final end = DateFormat('HH:mm')
        .format(DateFormat('yyyy-MM-dd HH:mm').parse(endTime));
    return '$start-$end';
  }

  String getFormattedDate(String startTime) {
    final date = DateFormat('yyyy-MM-dd HH:mm').parse(startTime);
    final weekDay = DateUtil.weekDayToString(date, isDisplayfull: true);
    return '$weekDay, ${DateFormat('dd/MM/yyyy').format(date)}';
  }

  _buildPatientInformation() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: R.color.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  R.string.consult_information.tr().toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: R.color.color0xff141416,
                  ),
                ),
                InkWell(
                  onTap: () {
                    _cubit.updateCreateDsmesBookingRequestSymptom(
                        symptom: symptomController.text);
                    _showEditRequesterInformationBottomSheet();
                  },
                  child: Visibility(
                    visible: !isReschedule,
                    child: Container(
                      alignment: Alignment.center,
                      height: 20,
                      child: Text(
                        R.string.chinh_sua.tr(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: R.color.color0xff239A90,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            GapH(12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  R.string.name.tr(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: R.color.color0xff777E90,
                  ),
                ),
                Text(
                  requesterName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: R.color.color0xff141416,
                  ),
                ),
              ],
            ),
            GapH(4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  R.string.so_dien_thoai.tr(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: R.color.color0xff777E90,
                  ),
                ),
                Text(
                  requesterPhone,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: R.color.color0xff141416,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _buildConsultingInformation() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: R.color.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.serviceType == DsmesAppointmentMode.atClinic.toString()
                      ? R.string.consult_at_clinic.tr().toUpperCase()
                      : R.string.consult_online.tr().toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: R.color.color0xff141416,
                  ),
                ),
                Visibility(
                  visible: !isReschedule,
                  child: InkWell(
                    onTap: () async {
                      _cubit.updateCreateDsmesBookingRequestSymptom(
                          symptom: symptomController.text);
                      await DsmesNavigationMixin.navigationKey.currentState
                          ?.pushNamed(NavigatorName.dsmes_booking_select_date,
                              arguments: {
                            'serviceType': widget.serviceType,
                            'action': 'edit',
                            'isEditing': true,
                            'previousRoute':
                                NavigatorName.dsmes_confirm_information
                          });
                    },
                    child: Container(
                      height: 20,
                      alignment: Alignment.center,
                      child: Text(
                        R.string.chinh_sua.tr(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: R.color.color0xff239A90,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            GapH(12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  R.string.consult_time.tr(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: R.color.color0xff777E90,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      getTimeRange(_cubit.createDsmesBookingRequest!.startTime,
                          _cubit.createDsmesBookingRequest!.endTime),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: R.color.color0xffA36E2A,
                      ),
                    ),
                    Text(
                      getFormattedDate(
                          _cubit.createDsmesBookingRequest!.startTime),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: R.color.color0xffA36E2A,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (widget.serviceType == DsmesAppointmentMode.atClinic.toString())
              GapH(4),
            if (widget.serviceType == DsmesAppointmentMode.atClinic.toString())
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    flex: 3,
                    child: Text(
                      R.string.center_name.tr(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: R.color.color0xff777E90,
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 7,
                    child: Text(
                      _cubit.selectedClinic?.name ?? '',
                      maxLines: 2,
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: R.color.color0xff141416,
                      ),
                    ),
                  ),
                ],
              ),
            if (widget.serviceType == DsmesAppointmentMode.atClinic.toString())
              GapH(4),
            if (widget.serviceType == DsmesAppointmentMode.atClinic.toString())
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    flex: 3,
                    child: Text(
                      R.string.address.tr(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: R.color.color0xff777E90,
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 7,
                    child: Text(
                      _cubit.selectedClinic?.address ?? '',
                      maxLines: 2,
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: R.color.color0xff141416,
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

  _buildSelectedServiceInformation() {
    if (_cubit.createDsmesBookingRequest == null) return SizedBox.shrink();
    if (_cubit.createDsmesBookingRequest!.paymentInfo == null) {
      return SizedBox.shrink();
    }
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: R.color.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  R.string.consult_demand.tr().toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: R.color.color0xff141416,
                  ),
                ),
                InkWell(
                  onTap: () async {
                    _cubit.updateCreateDsmesBookingRequestSymptom(
                        symptom: symptomController.text);
                    await DsmesNavigationMixin.navigationKey.currentState
                        ?.pushNamed(NavigatorName.dsmes_select_service,
                            arguments: {
                          'serviceType': widget.serviceType,
                          'clinic': _cubit.selectedClinic,
                          'isEditing': true,
                          'previousRoute':
                              NavigatorName.dsmes_confirm_information
                        });

                    // DsmesNavigationMixin.navigationKey.currentState?.popUntil(
                    //     (route) =>
                    //         route.settings.name ==
                    //         NavigatorName.dsmes_select_service);
                    // // Push new arguments to existing select service page
                    // DsmesNavigationMixin.navigationKey.currentState
                    //     ?.pushReplacementNamed(
                    //         NavigatorName.dsmes_select_service,
                    //         arguments: {
                    //       'serviceType': widget.serviceType,
                    //       'clinic': _cubit.selectedClinic,
                    //     });
                  },
                  child: Visibility(
                    visible: !isReschedule,
                    child: Container(
                      alignment: Alignment.center,
                      height: 20,
                      child: Text(
                        R.string.chinh_sua.tr(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: R.color.color0xff239A90,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            GapH(12),
            Column(
              children: [
                ..._cubit.createDsmesBookingRequest!.paymentInfo!.services
                    .map((e) {
                  final service = _cubit.selectedClinic?.serviceList.categories
                      .expand((category) => category.data)
                      .firstWhere((service) => service.id == e.id);

                  final isLastItem = e ==
                      _cubit.createDsmesBookingRequest!.paymentInfo!.services
                          .last;

                  return Column(
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                service?.name ?? '',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  color: R.color.color0xff111515,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (!isLastItem) Divider(color: R.color.color0xffE6E8EC)
                    ],
                  );
                }),
              ],
            )
          ],
        ),
      ),
    );
  }

  _buildNoticeSymptom() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: R.color.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  R.string.notice_symptom.tr(),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: R.color.color0xff111515,
                  ),
                ),
              ],
            ),
            GapH(12),
            Container(
              child: TextFormField(
                minLines: 2,
                maxLines: null, // Allows auto-expansion
                maxLength: 250,
                obscureText: false,
                readOnly: isReschedule ? true : false,
                textInputAction: TextInputAction.done,
                onEditingComplete: () {
                  // Update counter when done button is pressed
                  setState(() {});
                  FocusScope.of(context).unfocus();
                },
                // buildCounter: (context,
                //         {required currentLength,
                //         required isFocused,
                //         maxLength}) =>
                //     isReschedule ? null : SizedBox(),
                controller: symptomController,
                focusNode: symptomFocusNode,
                decoration: InputDecoration(
                  fillColor: R.color.textDark,
                  counterText: isReschedule
                      ? ""
                      : "${symptomController.text.length}/250",
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: R.color.grayComponentBorder, width: 1.0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: R.color.mainColor, width: 1.0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  hintText: R.string.symptom.tr(),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        width: 158,
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
            text,
            style: TextStyle(
              color: R.color.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  _showEditRequesterInformationBottomSheet() {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: 370,
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              R.string.change_consult_info.tr(),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Divider(
                color: R.color.color0xffE6E8EC,
              ),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(
                R.string.last_name_and_first_name.tr(),
                style: TextStyle(
                    color: R.color.textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
            ]),
            GapH(8),
            Container(
              height: 54,
              child: TextFormField(
                minLines: 1,
                maxLines: 1,
                maxLength: 20,
                inputFormatters: [
                  LengthLimitingTextFieldFormatterFixed(20),
                ],
                obscureText: false,
                controller: nameController,
                focusNode: nameFocusNode,
                decoration: InputDecoration(
                    fillColor: R.color.textDark,
                    counterText: '',
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: R.color.grayComponentBorder, width: 1.0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: R.color.mainColor, width: 1.0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding:
                        const EdgeInsets.only(top: 0, left: 16, right: 16),
                    hintText: R.string.name.tr()),
              ),
            ),
            GapH(16),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(
                R.string.phone_number.tr(),
                style: TextStyle(
                    color: R.color.textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
            ]),
            GapH(8),
            Container(
              height: 54,
              child: TextFormField(
                minLines: 1,
                maxLines: 1,
                maxLength: 12,
                inputFormatters: [
                  LengthLimitingTextFieldFormatterFixed(12),
                ],
                obscureText: false,
                controller: phoneController,
                focusNode: phoneFocusNode,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    fillColor: R.color.textDark,
                    counterText: '',
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: R.color.grayComponentBorder, width: 1.0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: R.color.mainColor, width: 1.0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding:
                        const EdgeInsets.only(top: 0, left: 16, right: 16),
                    hintText: R.string.phone_number.tr()),
              ),
            ),
            GapH(16),
            _buildButton(R.string.confirm.tr(), () {
              const String pattern = r'(^(?:[+0]9)?[0-9]{9}|\d{10}$)';
              final RegExp regExp = RegExp(pattern);
              final isCorrect = regExp.hasMatch(phoneController.text);
              if (phoneController.text.length > 0 &&
                  phoneController.text.length != 9 &&
                  phoneController.text.length != 10 &&
                  !isCorrect) {
                Message.showToastMessage(
                    context, R.string.phone_not_valid.tr());
              }

              if (phoneController.text.isEmpty) {
                Message.showToastMessage(
                    context, R.string.please_enter_phone_number.tr());
              }

              if (nameController.text.isEmpty) {
                Message.showToastMessage(
                    context, R.string.full_name_at_least_character.tr());
              }

              setState(() {
                requesterName = nameController.text;
                requesterPhone = phoneController.text;
              });

              _cubit.updateCreateDsmesBookingRequestRequesterInfo(
                  name: requesterName, phone: requesterPhone);

              Navigator.of(context).pop();
            })
          ],
        ),
      ),
    );
  }

  _showPopupBookingSuccess({
    required Function onNavigateHome,
    Function? onShowInfo,
    bool isShowImg = false,
    String? subtitle,
    String? title,
    String? title2,
    String primaryButtonTitle = 'Xác nhận',
    String secondaryButtonTitle = 'Huỷ',
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async {
            Navigator.pop(context);
            onShowInfo?.call();
            return false;
          },
          child: Container(
            child: AlertDialog(
              contentPadding: EdgeInsets.all(10),
              content: Stack(
                children: [
                  Container(
                    width: 351,
                    padding: EdgeInsets.all(12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: Icon(
                                Icons.close,
                                color: R.color.textDark,
                                size: 24,
                              ),
                            )
                          ],
                        ),
                        GapH(30),
                        if (isShowImg)
                          Image.asset(R.drawable.ic_dialog_success,
                              width: 43, height: 43),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (title2 != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 14.0),
                                child: Text(
                                  title2,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: R.color.color0xff636A6B,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: Text(
                                title ?? "",
                                maxLines: 2,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: R.color.greenGradientBottom,
                                  fontSize: 40,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Text(
                            subtitle ?? "",
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: R.color.color0xff777E90,
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                onShowInfo?.call();
                              },
                              child: Container(
                                height: 43,
                                width: 158,
                                decoration: BoxDecoration(
                                  color: R.color.white,
                                  borderRadius: BorderRadius.circular(200),
                                  border: Border.all(
                                    color: R.color.greenGradientBottom,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    secondaryButtonTitle,
                                    style: TextStyle(
                                      color: R.color.greenGradientBottom,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            _buildButton(
                              primaryButtonTitle,
                              () => onNavigateHome(),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  _showDialogUpdatePhone() {
    final width = MediaQuery.of(context).size.width;
    final TextEditingController textEditingController = TextEditingController();
    final FocusNode phoneDialogFocusNode = FocusNode();

    textEditingController.text = AppSettings.userInfo?.phoneNumber ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(R.string.phone_number.tr(),
                  style: TextStyle(
                      color: R.color.textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
              GestureDetector(
                  child: Icon(Icons.close, color: R.color.color0xffBEC0C8),
                  onTap: () {
                    Navigator.of(context).pop(false);
                  })
            ]),
            const SizedBox(height: 16),
            Container(
                height: 54,
                width: width - 36,
                child: TextField(
                    controller: textEditingController,
                    focusNode: phoneDialogFocusNode,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    minLines: 1,
                    maxLines: 1,
                    obscureText: false,
                    decoration: InputDecoration(
                      fillColor: R.color.textDark,
                      counterText: '',
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: R.color.grayComponentBorder, width: 1.0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: R.color.mainColor, width: 1.0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding:
                          const EdgeInsets.only(top: 0, left: 16, right: 16),
                    ),
                    onChanged: (value) {})),
            Container(
              margin: const EdgeInsets.only(top: 16),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                            height: 48,
                            width: 119,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(200),
                                color: R.color.grayBorder),
                            child: Center(
                              child: Text(R.string.cancel.tr(),
                                  style: TextStyle(
                                      color: R.color.textDark,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                            )),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () {
                          String phone = textEditingController.text;
                          if (phone.isEmpty) {
                            Message.showToastMessage(context,
                                R.string.ban_chua_nhap_so_dien_thoai.tr());
                            return;
                          } else {
                            final UserModel userInfo = AppSettings.userInfo!;

                            if (phone.startsWith('0')) {
                              final formattedNumber =
                                  '+84${phone.substring(1)}';
                              phone = formattedNumber;
                            }

                            updateUserInfo(
                              userInfo.copyWith(
                                phoneNumber: phone,
                              ),
                            );

                            _cubit.updateCreateDsmesBookingRequestRequesterInfo(
                                name: nameController.text, phone: phone);

                            phoneController.text = phone;
                            setState(() {
                              requesterPhone = phone;
                            });

                            Navigator.pop(context);
                          }
                        },
                        child: Container(
                          height: 48,
                          width: 119,
                          decoration: BoxDecoration(
                              color: R.color.red,
                              borderRadius: BorderRadius.circular(200),
                              gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    R.color.greenGradientTop,
                                    R.color.greenGradientBottom
                                  ])),
                          child: Center(
                            child: Text(
                              R.string.save.tr(),
                              style: TextStyle(
                                color: R.color.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ]),
            ),
          ],
        ),
      ),
    );
  }

  void updateUserInfo(UserModel user, {bool isUpdateDiabetes = false}) async {
    ProfileInfoController.updateUserInfo(context, user,
        isUpdateDiabetes: isUpdateDiabetes);
  }
}
