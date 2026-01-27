import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/app_setting/branchio_link_config.dart';
import 'package:medical/src/modal/user/user_model.dart';
import 'package:medical/src/model/request/dsmes_reschedule_request.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/date_utils.dart';
import 'package:medical/src/utils/length_limit_text_field.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/booking_clinic/helper/vnpay_payment_service.dart';
import 'package:medical/src/widget/dsmes_appointment/dsmes_appointment_cubit.dart';
import 'package:medical/src/widget/dsmes_appointment/model/dsmes_appointment_model.dart';
import 'package:medical/src/widget/dsmes_appointment/pages/dsmes_navigation_mixin.dart';
import 'package:medical/src/widget/dsmes_appointment/widgets/section_add_symptom.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/profile/user_info.dart';
import 'package:medical/src/widget/profile/address.dart';
import 'package:medical/src/widget/subscription/phone_validation_manager.dart';
import 'package:medical/src/widgets/gap_widget.dart';
import 'package:medical/src/widget/subscription/phone_validation_helper.dart';

class DsmesConfirmCreateInformation extends StatefulWidget {
  final String serviceType;
  final String action;
  final int? appointmentId;
  final String bookingType; // 'clinic' or 'center' or 'doctor'

  const DsmesConfirmCreateInformation({
    Key? key,
    required this.serviceType,
    this.action = 'create',
    this.appointmentId,
    this.bookingType = Const.BOOKING_TYPE_CENTER,
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
  final GlobalKey<SectionAddSymptomState> _sectionAddSymptomKey =
      GlobalKey<SectionAddSymptomState>();
  List<dynamic> files = [];

  Map<String, bool> isProcessing = {
    'confirmBooking': false,
    'editPatientInfo': false,
    'editConsultInfo': false,
    'editServiceInfo': false,
    'recheckInfo': false,
    'backHome': false,
  };

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

    symptomFocusNode.addListener(() {
      if (symptomFocusNode.hasFocus) {
        Future.delayed(Duration(milliseconds: 300), () {
          Scrollable.ensureVisible(
            symptomFocusNode.context!,
            alignment: 0.5,
            duration: Duration(milliseconds: 300),
          );
        });
      }
    });

    files = currentCreateRequest?.symptomAttachment ?? [];

    // Pre-fill homeAddress from userInfo when examination so it displays at first time
    if (_cubit.isExamination &&
        (currentCreateRequest?.homeAddress == null ||
            currentCreateRequest!.homeAddress!.isEmpty)) {
      final homeAddressFromUser = _getHomeAddressFromUserInfo();
      if (homeAddressFromUser != null && homeAddressFromUser.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _cubit.updateCreateDsmesBookingRequestHomeExamination(
            isTest: _cubit.isExamination,
            homeAddress: homeAddressFromUser,
          );
          setState(() {});
        });
      }
    }
  }

  /// Returns formatted home address from [AppSettings.userInfo], or null if not available.
  String? _getHomeAddressFromUserInfo() {
    final userInfo = AppSettings.userInfo;
    if (userInfo?.address == null || userInfo!.address!.isEmpty) return null;
    return (userInfo.address ?? '') +
        (userInfo.address == null || userInfo.address!.isEmpty ? '' : ', ') +
        (userInfo.ward == null ? '' : userInfo.ward!.name ?? '') +
        (userInfo.ward == null || (userInfo.ward!.name?.isEmpty ?? true)
            ? ''
            : ', ') +
        (userInfo.district == null ? '' : userInfo.district!.name ?? '') +
        (userInfo.district == null ||
                (userInfo.district!.name?.isEmpty ?? true)
            ? ''
            : ', ') +
        (userInfo.province == null ? '' : userInfo.province!.name ?? '');
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    symptomController.dispose();
    nameFocusNode.dispose();
    phoneFocusNode.dispose();
    symptomFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(
          color: R.color.backgroundColorNew,
        ),
        child: _buildPage(context),
      ),
    );
  }

  Widget _buildPage(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              Utils.hideKeyboard(context);
            },
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
                      R.string.confirm_information.tr(),
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          // fontFamily: 'sfpro',
                          color: R.color.white),
                    ),
                    actions: [],
                    leadingIcon: IconButton(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      icon: Icon(
                        Icons.arrow_back,
                        color: R.color.white,
                      ),
                      onPressed: () {
                        DsmesNavigationMixin.getNavigationKey()
                            .currentState
                            ?.pop(context);
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        children: [
                          _buildPatientInformation(),
                          GapH(12),
                          _cubit.isExamination
                              ? _buildExaminationInformation()
                              : _buildConsultingInformation(),
                          if (widget.serviceType ==
                              DsmesAppointmentMode.telemedicine.toString())
                            GapH(12),
                          if (widget.serviceType ==
                              DsmesAppointmentMode.telemedicine.toString())
                            widget.bookingType == Const.BOOKING_TYPE_CENTER
                                ? _buildSelectedServiceInformation()
                                : _buildBookingClinicSelectedServicesInformation(),
                          GapH(12),
                          // _buildNoticeSymptom(),
                          _selectImageSection(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          height: 74,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            boxShadow: [Utils.getBoxShadowDropButton()],
            color: R.color.white,
          ),
          child: Row(
            children: [
              Expanded(
                child:
                    _buildButton(R.string.confirm_book_consult.tr(), () async {
                  if (isProcessing['confirmBooking']!) return;
                  setState(() => isProcessing['confirmBooking'] = true);

                  try {
                    // Check if it's telemedicine clinic booking
                    bool isTelemedicineClinic = widget.serviceType ==
                            DsmesAppointmentMode.telemedicine.toString() &&
                        widget.bookingType == Const.BOOKING_TYPE_CLINIC;

                    // Handle reschedule case
                    if (widget.action == 'reschedule' &&
                        widget.appointmentId != null) {
                      _handleRescheduleBooking();
                      return;
                    }

                    // Handle telemedicine clinic booking
                    if (isTelemedicineClinic) {
                      _handleTelemedicineClinicBooking();
                      return;
                    }

                    // Handle create/edit case
                    if (widget.action == 'create' || widget.action == 'edit') {
                      final phoneNumber = AppSettings.userInfo?.phoneNumber ??
                          phoneController.text;

                      if (PhoneValidationHelper.isValidPhoneNumber(
                              phoneNumber) ==
                          false) {
                        _showDialogUpdatePhone();
                        return;
                      }

                      _handleCreateBooking();
                    }

                    // Helper method to calculate total price
                  } finally {
                    setState(() => isProcessing['confirmBooking'] = false);
                  }
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleTelemedicineClinicBooking() async {
    setState(() => isProcessing['confirmBooking'] = true);

    try {
      final phoneNumber =
          AppSettings.userInfo?.phoneNumber ?? phoneController.text;

      final token = await AppSettings.getDocosanToken();
      if (token.isEmpty) {
        await _cubit.registerDocosanUser(phoneNumber: phoneNumber);
        await AppSettings.clearOrganizationApiKey();
      }

      // Update symptom and attachments
      final data = _sectionAddSymptomKey.currentState?.getNote();
      _cubit.updateCreateDsmesBookingRequestSymptom(symptom: data?.note ?? '');
      _cubit.updateCreateDsmesBookingRequestSymptomAttachments(
          symptomAttachments: data?.fileNetworkName ?? []);

      // // Calculate total price
      // int totalPrice = _calculateTotalPrice();

      // // Initialize VNPay service
      // VNPayService paymentService = VNPayService(
      //   context: context,
      //   totalPrice: totalPrice,
      //   bookingType: widget.bookingType,
      //   serviceType: widget.serviceType,
      //   cubit: _cubit,
      // );

      // bool initialized = await paymentService.initializePayment();

      // if (initialized) {
      //   // Process payment directly
      //   await paymentService.openVNPaySDK();
      // }
      _handleCreateBooking();
    } finally {
      setState(() => isProcessing['confirmBooking'] = false);
    }
  }

  int _calculateTotalPrice() {
    final services = _cubit.createDsmesBookingRequest!.paymentInfo!.services;
    int totalPrice = 0;
    for (var e in services) {
      final service = _cubit.selectedClinic?.serviceList.categories
          .expand((category) => category.data)
          .firstWhere((service) => service.id == e.id);
      totalPrice += service?.fromPrice ?? 0;
    }
    return totalPrice;
  }

  _handleCreateBooking() async {
    final data = _sectionAddSymptomKey.currentState?.getNote();

    _cubit.updateCreateDsmesBookingRequestSymptom(symptom: data?.note ?? '');

    _cubit.updateCreateDsmesBookingRequestSymptomAttachments(
        symptomAttachments: data?.fileNetworkName ?? []);

    final phoneNumber =
        AppSettings.userInfo?.phoneNumber ?? phoneController.text;

    // Handle home examination address when isExamination is true
    if (_cubit.isExamination) {
      String? homeAddress = _getHomeAddressFromUserInfo();

      // If address is empty or null, show dialog to update
      if (homeAddress == null || homeAddress.isEmpty) {
        final updatedAddress = await _showDialogUpdateAddress();
        if (updatedAddress == null || updatedAddress.isEmpty) {
          return; // User cancelled or didn't provide address
        }
        homeAddress = updatedAddress;
      }

      // Update the request with home examination data
      _cubit.updateCreateDsmesBookingRequestHomeExamination(
          isTest: _cubit.isExamination, homeAddress: homeAddress);
    }

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
      title: R.string.booking_success_dialog_title.tr(),
      subtitle: R.string.confirm_booking_subtitle.tr(namedArgs: {
        'time': startTime,
        'date': startDate,
      }),
      isShowImg: true,
      primaryButtonTitle: R.string.back_home_page.tr(),
      secondaryButtonTitle: R.string.recheck_information.tr(),
      onNavigateHome: () async {
        BranchioLinkConfig.instance.resetPageTracking();

        // Set flag to show phone validation after successful request booking
        await PhoneValidationManager.setShouldShowPhoneValidation();

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

        // Set flag to show phone validation after successful request booking
        await PhoneValidationManager.setShouldShowPhoneValidation();

        DsmesNavigationMixin.getNavigationKey().currentState?.pushNamed(
          NavigatorName.dsmes_booking_detail,
          arguments: {
            'serviceType': widget.serviceType,
            'appointment': myAppointment,
            'bookingType': widget.bookingType,
          },
        );
      },
    );
  }

  _handleRescheduleBooking() async {
    final resp = await _cubit.rescheduleDsmesBooking(
      request: RescheduleDsmesBookingRequest(
          appointmentId: AppointmentId(id: widget.appointmentId!),
          startTime: _cubit.ensureTimeWithSeconds(
              _cubit.createDsmesBookingRequest!.startTime)),
    );
    if (resp == null) return;

    final myAppointment =
        await _cubit.getDsmesAppointmentDetail(appointmentId: resp.id);

    if (myAppointment == null) return;

    DsmesNavigationMixin.getNavigationKey().currentState?.pushNamed(
      NavigatorName.dsmes_booking_detail,
      arguments: {
        'serviceType': widget.serviceType,
        'appointment': myAppointment,
        'bookingType': widget.bookingType,
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

  Widget _buildExaminationInformation() {
    if (_cubit.createDsmesBookingRequest == null) {
      return const SizedBox.shrink();
    }

    final isAtClinic = _cubit.examinationLocation == 'clinic';
    final examinationTitle = isAtClinic
        ? R.string.xet_nghiem_tai_co_so.tr()
        : R.string.xet_nghiem_tai_nha.tr();

    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: R.color.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          Utils.getBoxShadowDropCard(),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                examinationTitle,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: R.color.color0xff141416,
                ),
              ),
              InkWell(
                onTap: () {
                  // Navigate to edit examination details
                  // At home: navigate to datetime page
                  // At clinic: navigate to provider page
                  if (_cubit.examinationLocation == 'home') {
                    // Navigate to datetime selection page for editing
                    DsmesNavigationMixin.getNavigationKey()
                        .currentState
                        ?.pushNamed(NavigatorName.dsmes_booking_select_date,
                            arguments: {
                          'serviceType': widget.serviceType,
                          'action': widget.action,
                          'bookingType': widget.bookingType,
                          'isMergedSchedule': false,
                          'isEditing': true,
                          'previousRoute':
                              NavigatorName.dsmes_confirm_information,
                        });
                  } else {
                    // Navigate to provider page for editing clinic selection
                    DsmesNavigationMixin.getNavigationKey()
                        .currentState
                        ?.pushNamed(NavigatorName.clinic_providers, arguments: {
                      'specialtyId': 0,
                      'examinationType': _cubit.examinationType,
                      'isEditing': true,
                      'previousRoute': NavigatorName.dsmes_confirm_information,
                    });
                  }
                },
                child: Text(
                  R.string.chinh_sua.tr(),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: R.color.color0xff95682E,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                R.string.appointment_time.tr(),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: R.color.color0xff636A6B,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    getTimeRange(_cubit.createDsmesBookingRequest!.startTime,
                        _cubit.createDsmesBookingRequest!.endTime),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: R.color.greenGradientBottom,
                    ),
                  ),
                  Text(
                    getFormattedDate(
                        _cubit.createDsmesBookingRequest!.startTime),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: R.color.greenGradientBottom,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (isAtClinic && _cubit.selectedClinic != null) ...[
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Text(
                    R.string.centre_name.tr(),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: R.color.color0xff636A6B,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    _cubit.selectedClinic!.name ?? '',
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: R.color.color0xff141416,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  _buildPatientInformation() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: R.color.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          Utils.getBoxShadowDropCard(),
        ],
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
                  R.string.consult_information.tr(),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: R.color.color0xff141416,
                  ),
                ),
                InkWell(
                  onTap: () async {
                    final updatedAddress = await _showDialogUpdateAddress();
                    if (updatedAddress != null && updatedAddress.isNotEmpty) {
                      setState(() {
                        // UI will be updated automatically as it reads from _cubit.createDsmesBookingRequest!.homeAddress
                      });
                    }
                  },
                  child: Visibility(
                    visible: !isReschedule,
                    child: Container(
                      alignment: Alignment.center,
                      height: 20,
                      child: Text(
                        R.string.chinh_sua.tr(),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: R.color.color0xff95682E,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            GapH(16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  R.string.name.tr(),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: R.color.color0xff636A6B,
                  ),
                ),
                Text(
                  requesterName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: R.color.color0xff111515,
                  ),
                ),
              ],
            ),
            GapH(4),
            if (_cubit.createDsmesBookingRequest?.homeAddress?.isNotEmpty ??
                false)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    R.string.address.tr(),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: R.color.color0xff636A6B,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _cubit.createDsmesBookingRequest!.homeAddress!,
                      textAlign: TextAlign.right,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: R.color.color0xff111515,
                      ),
                    ),
                  ),
                ],
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  R.string.so_dien_thoai.tr(),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: R.color.color0xff636A6B,
                  ),
                ),
                Text(
                  requesterPhone,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: R.color.color0xff111515,
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
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: R.color.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          Utils.getBoxShadowDropCard(),
        ],
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
                      ? R.string.consult_at_clinic.tr()
                      : R.string.kham_tu_xa.tr(),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: R.color.color0xff111515,
                  ),
                ),
                Visibility(
                  visible: !isReschedule,
                  child: InkWell(
                    onTap: () async {
                      if (isProcessing['editConsultInfo']!) return;
                      setState(() => isProcessing['editConsultInfo'] = true);
                      try {
                        final data =
                            _sectionAddSymptomKey.currentState?.getNote();
                        _cubit.updateCreateDsmesBookingRequestSymptom(
                            symptom: data?.note ?? symptomController.text);
                        _cubit
                            .updateCreateDsmesBookingRequestSymptomAttachments(
                                symptomAttachments:
                                    data?.fileNetworkName ?? []);

                        final route = ModalRoute.of(context)?.settings;
                        final args = route?.arguments as Map<String, dynamic>?;
                        final isMergedSchedule =
                            args?['isMergedSchedule'] ?? false;
                        await DsmesNavigationMixin.getNavigationKey()
                            .currentState
                            ?.pushNamed(NavigatorName.dsmes_booking_select_date,
                                arguments: {
                              'serviceType': widget.serviceType,
                              'action': widget.action,
                              'isEditing': true,
                              'previousRoute':
                                  NavigatorName.dsmes_confirm_information,
                              'isMergedSchedule': isMergedSchedule,
                              'bookingType': widget.bookingType,
                            });
                      } finally {
                        setState(() => isProcessing['editConsultInfo'] = false);
                      }
                    },
                    child: Container(
                      height: 20,
                      alignment: Alignment.center,
                      child: Text(
                        R.string.chinh_sua.tr(),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: R.color.color0xff95682E,
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
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: R.color.color0xff636A6B,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      getTimeRange(_cubit.createDsmesBookingRequest!.startTime,
                          _cubit.createDsmesBookingRequest!.endTime),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: R.color.greenGradientBottom,
                      ),
                    ),
                    Text(
                      getFormattedDate(
                          _cubit.createDsmesBookingRequest!.startTime),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: R.color.greenGradientBottom,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (widget.serviceType !=
                    DsmesAppointmentMode.telemedicine.toString() ||
                widget.bookingType != Const.BOOKING_TYPE_CENTER)
              GapH(4),
            if (widget.serviceType !=
                    DsmesAppointmentMode.telemedicine.toString() ||
                widget.bookingType != Const.BOOKING_TYPE_CENTER)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    flex: 3,
                    child: Text(
                      R.string.center_name.tr(),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: R.color.color0xff636A6B,
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
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: R.color.color0xff111515,
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
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: R.color.color0xff636A6B,
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
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: R.color.color0xff111515,
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
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: R.color.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          Utils.getBoxShadowDropCard(),
        ],
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
                  R.string.consult_demand.tr(),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: R.color.color0xff141416,
                  ),
                ),
                InkWell(
                  onTap: () async {
                    if (isProcessing['editServiceInfo']!) return;
                    setState(() => isProcessing['editServiceInfo'] = true);
                    try {
                      final data =
                          _sectionAddSymptomKey.currentState?.getNote();
                      _cubit.updateCreateDsmesBookingRequestSymptom(
                          symptom: data?.note ?? symptomController.text);
                      _cubit.updateCreateDsmesBookingRequestSymptomAttachments(
                          symptomAttachments: data?.fileNetworkName ?? []);

                      await DsmesNavigationMixin.getNavigationKey()
                          .currentState
                          ?.pushNamed(NavigatorName.dsmes_select_service,
                              arguments: {
                            'serviceType': widget.serviceType,
                            'action': widget.action,
                            'clinic': _cubit.selectedClinic,
                            'isEditing': true,
                            'previousRoute':
                                NavigatorName.dsmes_confirm_information
                          });
                    } finally {
                      setState(() => isProcessing['editServiceInfo'] = false);
                    }
                  },
                  child: Visibility(
                    visible: !isReschedule,
                    child: Container(
                      alignment: Alignment.center,
                      height: 20,
                      child: Text(
                        R.string.chinh_sua.tr(),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: R.color.color0xff95682E,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            GapH(6),
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

  _buildBookingClinicSelectedServicesInformation() {
    if (_cubit.createDsmesBookingRequest == null) return SizedBox.shrink();
    if (_cubit.createDsmesBookingRequest!.paymentInfo == null) {
      return SizedBox.shrink();
    }

    final services = _cubit.createDsmesBookingRequest!.paymentInfo!.services;
    int totalPrice = 0;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: R.color.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          Utils.getBoxShadowDropCard(),
        ],
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
                  R.string.service_type.tr(),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: R.color.color0xff141416,
                  ),
                ),
                InkWell(
                  onTap: () async {
                    if (isProcessing['editServiceInfo']!) return;
                    setState(() => isProcessing['editServiceInfo'] = true);
                    try {
                      final data =
                          _sectionAddSymptomKey.currentState?.getNote();
                      _cubit.updateCreateDsmesBookingRequestSymptom(
                          symptom: data?.note ?? symptomController.text);
                      _cubit.updateCreateDsmesBookingRequestSymptomAttachments(
                          symptomAttachments: data?.fileNetworkName ?? []);

                      await DsmesNavigationMixin.getNavigationKey()
                          .currentState
                          ?.pushNamed(NavigatorName.clinic_select_service,
                              arguments: {
                            'serviceType': widget.serviceType,
                            'action': widget.action,
                            'clinic': _cubit.selectedClinic,
                            'isEditing': true,
                            'previousRoute':
                                NavigatorName.dsmes_confirm_information,
                            'bookingType': widget.bookingType,
                          });
                    } finally {
                      setState(() => isProcessing['editServiceInfo'] = false);
                    }
                  },
                  child: Visibility(
                    visible: !isReschedule,
                    child: Container(
                      alignment: Alignment.center,
                      height: 20,
                      child: Text(
                        R.string.chinh_sua.tr(),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: R.color.color0xff95682E,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            GapH(12),
            ...services.map((e) {
              final service = _cubit.selectedClinic?.serviceList.categories
                  .expand((category) => category.data)
                  .firstWhere((service) => service.id == e.id);

              totalPrice += service?.fromPrice ?? 0;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        service?.name ?? '',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: R.color.color0xff636A6B,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 8),
                      child: Text(
                        Utils.formatMoney(service?.fromPrice ?? 0) ?? '',
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
            Divider(color: R.color.color0xffE6E8EC),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    R.string.estimated_cost.tr(),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: R.color.color0xff636A6B,
                    ),
                  ),
                  Text(
                    Utils.formatMoney(totalPrice) ?? '',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: R.color.color0xff111515,
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

  _buildNoticeSymptom() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: R.color.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          Utils.getBoxShadowDropCard(),
        ],
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
                onChanged: (value) {
                  setState(() {
                    // This will trigger a rebuild and update the counter
                  });
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
                  hintText: R.string.symptom_hint_text.tr(),
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
        // width: 158,
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
        height: 270,
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
                maxLength: 30,
                inputFormatters: [
                  LengthLimitingTextFieldFormatterFixed(30),
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
            // GapH(16),
            // Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            //   Text(
            //     R.string.phone_number.tr(),
            //     style: TextStyle(
            //         color: R.color.textDark,
            //         fontSize: 16,
            //         fontWeight: FontWeight.w700),
            //   ),
            // ]),
            // GapH(8),
            // Container(
            //   height: 54,
            //   child: TextFormField(
            //     minLines: 1,
            //     maxLines: 1,
            //     maxLength: 12,
            //     inputFormatters: [
            //       LengthLimitingTextFieldFormatterFixed(12),
            //     ],
            //     obscureText: false,
            //     controller: phoneController,
            //     focusNode: phoneFocusNode,
            //     keyboardType: TextInputType.number,
            //     decoration: InputDecoration(
            //         fillColor: R.color.textDark,
            //         counterText: '',
            //         enabledBorder: OutlineInputBorder(
            //           borderSide: BorderSide(
            //               color: R.color.grayComponentBorder, width: 1.0),
            //           borderRadius: BorderRadius.circular(10),
            //         ),
            //         focusedBorder: OutlineInputBorder(
            //           borderSide:
            //               BorderSide(color: R.color.mainColor, width: 1.0),
            //           borderRadius: BorderRadius.circular(10),
            //         ),
            //         contentPadding:
            //             const EdgeInsets.only(top: 0, left: 16, right: 16),
            //         hintText: R.string.phone_number.tr()),
            //   ),
            // ),
            GapH(16),
            _buildButton(R.string.confirm.tr(), () {
              // const String pattern = r'(^(?:[+0]9)?[0-9]{9}|\d{10}$)';
              // final RegExp regExp = RegExp(pattern);
              // final isCorrect = regExp.hasMatch(phoneController.text);

              // if (phoneController.text.isEmpty) {
              //   Message.showToastMessage(
              //       context, R.string.please_enter_phone_number.tr());
              // }

              if (nameController.text.isEmpty) {
                Message.showToastMessage(
                    context, R.string.full_name_at_least_character.tr());
              }

              setState(() {
                requesterName = nameController.text.trim();
                // requesterPhone =
                //     Utils.formatPhoneNumber(phoneController.text.trim());
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
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              insetPadding: EdgeInsets.symmetric(horizontal: 12),
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            onShowInfo?.call();
                          },
                          child: Icon(
                            Icons.close,
                            color: R.color.textDark,
                            size: 24,
                          ),
                        )
                      ],
                    ),
                    GapH(16),
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
                    GapH(16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: GestureDetector(
                            onTap: () {
                              if (isProcessing['recheckInfo']!) return;
                              setState(
                                  () => isProcessing['recheckInfo'] = true);
                              try {
                                Navigator.pop(context);
                                onShowInfo?.call();
                              } finally {
                                setState(
                                    () => isProcessing['recheckInfo'] = false);
                              }
                            },
                            child: Container(
                              height: 43,
                              margin: EdgeInsets.only(right: 8),
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
                        ),
                        Flexible(
                          child: _buildButton(primaryButtonTitle, () {
                            if (isProcessing['backHome']!) return;
                            setState(() => isProcessing['backHome'] = true);
                            try {
                              onNavigateHome();
                            } finally {
                              setState(() => isProcessing['backHome'] = false);
                            }
                          }),
                        ),
                      ],
                    ),
                    GapH(16),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  _showDialogUpdatePhone() {
    PhoneValidationHelper.showBottomSheetUpdatePhone(context).then((phone) {
      if (phone.isEmpty) return;
      // final UserModel userInfo = AppSettings.userInfo!;
      // updateUserInfo(userInfo.copyWith(phoneNumber: phone));
      _cubit.updateCreateDsmesBookingRequestRequesterInfo(
          name: nameController.text, phone: phone);
      phoneController.text = phone;
      setState(() {
        requesterPhone = phone;
      });
    });
  }

  Future<String?> _showDialogUpdateAddress() async {
    final UserModel userInfo = AppSettings.userInfo!;
    final Completer<String?> completer = Completer<String?>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: AddressController(
          address: userInfo.address,
          province: userInfo.province,
          district: userInfo.district,
          ward: userInfo.ward,
          callback: (address, province, district, ward) {
            updateUserInfo(
              userInfo.copyWith(
                province: province,
                district: district,
                ward: ward,
                address: address,
              ),
            );
            // Format address similar to user_info.dart
            final formattedAddress = (address ?? '') +
                (address == null || address.isEmpty ? '' : ', ') +
                (ward == null ? '' : ward.name ?? '') +
                (ward == null || (ward.name?.isEmpty ?? true) ? '' : ', ') +
                (district == null ? '' : district.name ?? '') +
                (district == null || (district.name?.isEmpty ?? true)
                    ? ''
                    : ', ') +
                (province == null ? '' : province.name ?? '');
            _cubit.updateCreateDsmesBookingRequestHomeExamination(
                isTest: _cubit.isExamination, homeAddress: formattedAddress);
            // AddressController will handle Navigator.pop
            if (!completer.isCompleted) {
              completer.complete(formattedAddress);
            }
          },
        ),
      ),
    ).then((_) {
      // If dialog was dismissed without callback (e.g., by tapping outside)
      if (!completer.isCompleted) {
        completer.complete(null);
      }
    });

    return completer.future;
  }

  void updateUserInfo(UserModel user, {bool isUpdateDiabetes = false}) async {
    ProfileInfoController.updateUserInfo(context, user,
        isUpdateDiabetes: isUpdateDiabetes);
  }

  Widget _selectImageSection() {
    return SectionAddSymptom(
      focusNode: symptomFocusNode,
      controllerNote: symptomController,
      maxMedia: 5,
      key: _sectionAddSymptomKey,
      initialFiles: files,
      isDisplayRemove: isReschedule ? false : true,
      readOnly: isReschedule,
      isDisplayTextField: !(isReschedule && symptomController.text.isEmpty),
    );
  }
}
