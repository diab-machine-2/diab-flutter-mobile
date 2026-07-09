import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/app_setting/branchio_link_config.dart';
import 'package:medical/src/model/request/create_dsmes_booking_request.dart';
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
import 'package:medical/src/widget/dsmes_appointment/model/dsmes_clinic_model.dart';
import 'package:medical/src/widget/dsmes_appointment/widgets/section_add_symptom.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/subscription/phone_validation_helper.dart';
import 'package:medical/src/widget/subscription/phone_validation_manager.dart';
import 'package:medical/src/widgets/gap_widget.dart';

/// Confirm booking page for the Benefit flow.
///
/// When [isBypassPayment] is true (telemedicine benefit), the VNPay flow is
/// skipped and the booking is created directly via `createDsmesBookingOnline`.
/// [branchName] and [branchAddress] are appended to the booking note at confirm time.
/// For at-clinic benefit flow, [branchId] is sent to
/// `api/doctors/patient-appointments-partner-diab`.
class BenefitConfirmPage extends StatefulWidget {
  final String serviceType;
  final String action;
  final int? appointmentId;
  final String bookingType;
  final bool isBypassPayment;
  final String? branchName;
  final String? branchAddress;
  final int? branchId;
  final String? specialtyName;

  const BenefitConfirmPage({
    Key? key,
    required this.serviceType,
    this.action = 'create',
    this.appointmentId,
    this.bookingType = Const.BOOKING_TYPE_CLINIC,
    this.isBypassPayment = false,
    this.branchName,
    this.branchAddress,
    this.branchId,
    this.specialtyName,
  }) : super(key: key);

  @override
  _BenefitConfirmPageState createState() => _BenefitConfirmPageState();
}

class _BenefitConfirmPageState extends State<BenefitConfirmPage> {
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

  final GlobalKey<SectionAddSymptomState> _sectionAddSymptomKey =
      GlobalKey<SectionAddSymptomState>();
  List<dynamic> files = [];

  Map<String, bool> isProcessing = {
    'confirmBooking': false,
    'editConsultInfo': false,
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

    files = currentCreateRequest?.symptomAttachment ?? [];
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

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(color: R.color.backgroundColorNew),
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
            onTap: () => Utils.hideKeyboard(context),
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
                        color: R.color.white,
                      ),
                    ),
                    actions: [],
                    leadingIcon: IconButton(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      icon: Icon(Icons.arrow_back, color: R.color.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          _buildPatientInformation(),
                          GapH(12),
                          _buildConsultingInformation(),
                          _buildVoucherAndPaymentSection(),
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
        // Confirm button
        Container(
          height: 74,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            boxShadow: [Utils.getBoxShadowDropButton()],
            color: R.color.white,
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildButton(
                  R.string.confirm.tr(),
                  () async {
                    if (isProcessing['confirmBooking']!) return;
                    setState(() => isProcessing['confirmBooking'] = true);
                    try {
                      final phoneNumber = AppSettings.userInfo?.phoneNumber ??
                          phoneController.text;
                      if (PhoneValidationHelper.isValidPhoneNumber(
                              phoneNumber) ==
                          false) {
                        _showDialogUpdatePhone();
                        return;
                      }
                      await _handleCreateBooking();
                    } finally {
                      setState(() => isProcessing['confirmBooking'] = false);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Booking ──────────────────────────────────────────────────────────────

  Future<void> _handleCreateBooking() async {
    // Handle reschedule case
    if (widget.action == 'reschedule' && widget.appointmentId != null) {
      await _handleRescheduleBooking();
      return;
    }

    final data = _sectionAddSymptomKey.currentState?.getNote();
    String symptom = data?.note ?? '';

    // Append specialty name
    if (widget.specialtyName != null && widget.specialtyName!.isNotEmpty) {
      symptom +=
          '${symptom.isNotEmpty ? '\n' : ''} - ${R.string.chuyen_khoa.tr()}: ${widget.specialtyName}';
    }

    // Append branch info for at-clinic benefit flow
    if (widget.branchName != null || widget.branchAddress != null) {
      if (widget.branchName != null) {
        symptom += '\n${widget.branchName}';
      }
      if (widget.branchAddress != null) {
        symptom += ' - ${widget.branchAddress}';
      }
    }

    _cubit.updateCreateDsmesBookingRequestSymptom(symptom: symptom);
    _cubit.updateCreateDsmesBookingRequestSymptomAttachments(
        symptomAttachments: data?.fileNetworkName ?? []);

    final phoneNumber =
        AppSettings.userInfo?.phoneNumber ?? phoneController.text;

    final token = await AppSettings.getDocosanToken();
    if (token.isEmpty) {
      await _cubit.registerDocosanUser(phoneNumber: phoneNumber);
      await AppSettings.clearOrganizationApiKey();
    }

    DsmesAppointment? resp;

    // For at-clinic benefit flow, set branchId on the request
    if (widget.branchId != null) {
      _cubit.createDsmesBookingRequest =
          _cubit.createDsmesBookingRequest?.copyWith(
        branchId: widget.branchId,
      );
    }

    if (widget.serviceType == DsmesAppointmentMode.atClinic.toString()) {
      // ── At-clinic: book directly ──
      resp = await _cubit.createDsmesPartnerDiabBooking();
    } else {
      // ── Telemedicine: smart payment routing ──────────────────────────────────
      // Check whether any selected service has a non-zero price_discount
      // (from saleServiceList) or a non-zero fromPrice (normal flow).
      // price_discount == 0 (voucher covers 100%) => free, skip VNPay.
      final saleServiceList = _cubit.selectedClinic?.saleServiceList;
      final selectedServiceItems =
          _cubit.createDsmesBookingRequest?.paymentInfo?.services ?? [];

      final hasPrice = selectedServiceItems.any((item) {
        if (saleServiceList != null) {
          // Voucher flow: check priceDiscount
          final saleItem = saleServiceList.findByServiceId(item.id);
          if (saleItem != null) return saleItem.priceDiscount > 0;
        }
        // Normal flow: check fromPrice
        final service = _findSelectedClinicServiceById(item.id);
        if (service == null) return false;
        return !_isServiceFree(service);
      });

      if (hasPrice) {
        // ── Paid service: open VNPay SDK ──
        final totalPrice = _calculateTotalPrice();
        final paymentService = VNPayService(
          context: context,
          totalPrice: totalPrice,
          bookingType: widget.bookingType,
          serviceType: widget.serviceType,
          cubit: _cubit,
        );
        final initialized = await paymentService.initializePayment();
        if (initialized) {
          await paymentService.openVNPaySDK();
        }
        return; // VNPayService handles success/failure navigation
      }

      // ── Free / benefit-covered: book directly ──
      // If there are saleServices in paymentInfo (voucher flow), they are
      // already set; just ensure paymentType is 'local_banking'.
      final paymentInfo = _cubit.createDsmesBookingRequest?.paymentInfo;
      if (paymentInfo?.saleServices != null) {
        // Voucher flow: saleServices already populated in calendar step
        _cubit.createDsmesBookingRequest =
            _cubit.createDsmesBookingRequest?.copyWith(
          paymentInfo: PaymentInfo(
            paymentType: 'local_banking',
            services: [],
            saleServices: paymentInfo!.saleServices,
          ),
        );
      } else {
        // Normal flow
        _cubit.updateCreateDsmesBookingRequestServiceList(
          paymentType: 'local_banking',
          selectedServices: selectedServiceItems,
        );
      }

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
        await PhoneValidationManager.setShouldShowPhoneValidation();
        Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
          NavigatorName.tabbar,
          (route) => false,
        );
      },
      onShowInfo: () async {
        final myAppointment =
            await _cubit.getDsmesAppointmentDetail(appointmentId: resp!.id);
        if (myAppointment == null) return;
        await PhoneValidationManager.setShouldShowPhoneValidation();
        Navigator.of(context, rootNavigator: true).pushNamed(
          NavigatorName.benefit_booking_detail,
          arguments: {
            'serviceType': widget.serviceType,
            'appointment': myAppointment,
            'bookingType': widget.bookingType,
          },
        );
      },
    );
  }

  // ─── UI sections ──────────────────────────────────────────────────────────

  Widget _buildPatientInformation() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: R.color.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [Utils.getBoxShadowDropCard()],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                R.string.consult_information.tr(),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: R.color.color0xff141416,
                ),
              ),
              // InkWell(
              //   onTap: _showEditRequesterInformationBottomSheet,
              //   child: Container(
              //     height: 20,
              //     alignment: Alignment.center,
              //     child: Text(
              //       R.string.chinh_sua.tr(),
              //       style: TextStyle(
              //         fontSize: 15,
              //         fontWeight: FontWeight.w400,
              //         color: R.color.color0xff95682E,
              //       ),
              //     ),
              //   ),
              // ),
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
    );
  }

  Widget _buildConsultingInformation() {
    if (_cubit.createDsmesBookingRequest == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: R.color.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [Utils.getBoxShadowDropCard()],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.serviceType == DsmesAppointmentMode.atClinic.toString()
                    ? R.string.kham_tai_phong_kham.tr()
                    : R.string.kham_tu_xa.tr(),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: R.color.color0xff111515,
                ),
              ),
              InkWell(
                onTap: () async {
                  if (isProcessing['editConsultInfo']!) return;
                  setState(() => isProcessing['editConsultInfo'] = true);
                  try {
                    await Navigator.of(context, rootNavigator: true)
                        .pushNamed(NavigatorName.dsmes_booking_select_date,
                            arguments: {
                          'serviceType': widget.serviceType,
                          'action': widget.action,
                          'isEditing': true,
                          'previousRoute':
                              NavigatorName.benefit_confirm_information,
                          'isMergedSchedule': false,
                          'bookingType': widget.bookingType,
                        });
                  } finally {
                    setState(() => isProcessing['editConsultInfo'] = false);
                  }
                },
                child: SvgPicture.asset(
                  R.icons.ic_benefit_edit,
                  width: 20,
                  height: 20,
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
                R.string.thoi_gian_kham.tr(),
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
                    _getTimeRange(_cubit.createDsmesBookingRequest!.startTime,
                        _cubit.createDsmesBookingRequest!.endTime),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: R.color.greenGradientBottom,
                    ),
                  ),
                  Text(
                    _getFormattedDate(
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
          GapH(8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                flex: 3,
                child: Text(
                  R.string.phong_kham.tr(),
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
                  maxLines: 3,
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
          // Show address for at-clinic / service name for telemedicine
          if (widget.serviceType ==
              DsmesAppointmentMode.atClinic.toString()) ...[
            GapH(8),
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
          if (widget.serviceType ==
              DsmesAppointmentMode.telemedicine.toString()) ...[
            GapH(8),
            _buildTelemedicineServiceRow(),
          ],
        ],
      ),
    );
  }

  Widget _selectImageSection() {
    return SectionAddSymptom(
      focusNode: symptomFocusNode,
      controllerNote: symptomController,
      maxMedia: 5,
      key: _sectionAddSymptomKey,
      initialFiles: files,
      isDisplayRemove: true,
      readOnly: false,
      isDisplayTextField: true,
      hintText: R.string.booking_note_text_hint.tr(),
    );
  }

  // ─── Payment helpers ──────────────────────────────────────────────────────

  /// Returns true when a service is free: priceType == 'free' OR both prices are zero.
  bool _isServiceFree(ServiceData service) {
    return service.priceType == 'free' ||
        (service.fromPrice == 0 && service.toPrice == 0);
  }

  /// Sums up fromPrice for all selected services.
  int _calculateTotalPrice() {
    final services =
        _cubit.createDsmesBookingRequest!.paymentInfo!.services;
    int total = 0;
    for (final item in services) {
      final service = _findSelectedClinicServiceById(item.id);
      total += ((service?.fromPrice ?? 0) as num).toInt();
    }
    return total;
  }

  /// Finds a [ServiceData] by ID from the currently selected clinic.
  ServiceData? _findSelectedClinicServiceById(dynamic id) {
    if (id == null) return null;
    final allServices = _cubit.selectedClinic?.serviceList.categories
            .expand((c) => c.data)
            .toList() ??
        [];
    for (final service in allServices) {
      if (service.id == id) return service;
    }
    return null;
  }

  /// Builds the telemedicine service row: service name label + value.
  Widget _buildTelemedicineServiceRow() {
    final clinic = _cubit.selectedClinic;
    final paymentInfo = _cubit.createDsmesBookingRequest?.paymentInfo;

    final allServices = clinic?.serviceList.categories
            .expand((c) => c.data)
            .toList() ??
        [];

    ServiceData? serviceData;

    // Try regular services first
    final regularItems = paymentInfo?.services ?? [];
    if (regularItems.isNotEmpty) {
      serviceData = _findSelectedClinicServiceById(regularItems.first.id);
    }

    // Try saleServices fallback
    if (serviceData == null) {
      final saleItems = paymentInfo?.saleServices ?? [];
      if (saleItems.isNotEmpty && clinic?.saleServiceList != null) {
        final matched = clinic!.saleServiceList!.services
            .where((s) => s.serviceItemId == saleItems.first.id)
            .toList();
        if (matched.isNotEmpty) {
          serviceData = _findSelectedClinicServiceById(matched.first.serviceItemId);
          serviceData ??= allServices.isNotEmpty ? allServices.first : null;
        }
      }
    }

    serviceData ??= allServices.isNotEmpty ? allServices.first : null;
    final serviceName = serviceData?.name ?? '';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          flex: 3,
          child: Text(
            R.string.service.tr(),
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
            serviceName,
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
    );
  }

  /// Combined voucher + payment section. Returns empty when no voucher applies
  /// (no GapH spacers left behind).
  Widget _buildVoucherAndPaymentSection() {
    final hasVoucher = _resolveSaleItem() != null;
    if (!hasVoucher) return const SizedBox.shrink();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GapH(12),
        _buildVoucherSection(),
        GapH(12),
        _buildPaymentDetailSection(),
        GapH(12),
      ],
    );
  }

  /// Builds the "Ưu đãi" section: title + white card with voucher code in gold.
  Widget _buildVoucherSection() {
    final voucherCode = _resolveSaleItem()?.voucherCode;
    if (voucherCode == null || voucherCode.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 12,
      children: [
        SizedBox(
          width: double.infinity,
          child: Text(
            R.string.promotion.tr(),
            style: TextStyle(
              color: R.color.color0xff111515,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              height: 1.32,
              letterSpacing: 0.04,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(
              top: 16, left: 10, right: 4, bottom: 16),
          decoration: ShapeDecoration(
            color: R.color.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            shadows: [Utils.getBoxShadowDropCard()],
          ),
          child: Text(
            voucherCode,
            style: TextStyle(
              color: R.color.color0xffB4802D,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              height: 1.46,
              letterSpacing: 0.40,
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the "Chi tiết thanh toán" section: title + white card with
  /// service price, discount, and total rows.
  Widget _buildPaymentDetailSection() {
    final saleItem = _resolveSaleItem();
    if (saleItem == null) return const SizedBox.shrink();

    final serviceName = _resolveServiceName() ?? '';
    final originalPrice = saleItem.price;
    final discountPercent = saleItem.discount;
    final discountAmount = originalPrice - saleItem.priceDiscount;
    final totalAmount = saleItem.priceDiscount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 12,
      children: [
        SizedBox(
          width: double.infinity,
          child: Text(
            R.string.payment_detail.tr(),
            style: TextStyle(
              color: R.color.color0xff111515,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              height: 1.32,
              letterSpacing: 0.04,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: ShapeDecoration(
            color: R.color.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            shadows: [Utils.getBoxShadowDropCard()],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 12,
            children: [
              // Service name → original price
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    serviceName,
                    style: TextStyle(
                      color: R.color.color0xff111515,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      height: 1.46,
                      letterSpacing: 0.40,
                    ),
                  ),
                  Text(
                    _formatPrice(originalPrice),
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: R.color.color0xff111515,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      height: 1.46,
                      letterSpacing: 0.40,
                    ),
                  ),
                ],
              ),
              // Ưu đãi (X%) → discount amount in gold
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    R.string.promotion_percent.tr(namedArgs: {
                      'percent': discountPercent.toString(),
                    }),
                    style: TextStyle(
                      color: R.color.color0xffB4802D,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      height: 1.46,
                      letterSpacing: 0.40,
                    ),
                  ),
                  Text(
                    _formatPrice(discountAmount),
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: R.color.color0xffB4802D,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 1.46,
                      letterSpacing: 0.40,
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Divider(height: 2, color: R.color.color0xffDFE4E4),
              ),

              // Tổng thanh toán → final price (bold)
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    R.string.total_payment.tr(),
                    style: TextStyle(
                      color: R.color.color0xff111515,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      height: 1.46,
                      letterSpacing: 0.40,
                    ),
                  ),
                  Text(
                    _formatPrice(totalAmount),
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: R.color.color0xff111515,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 1.46,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Resolves the [SaleServiceItem] if a voucher applies to the current booking.
  SaleServiceItem? _resolveSaleItem() {
    final clinic = _cubit.selectedClinic;
    final saleServiceList = clinic?.saleServiceList;
    if (saleServiceList == null) return null;

    final paymentInfo = _cubit.createDsmesBookingRequest?.paymentInfo;
    if (paymentInfo == null) return null;

    // Try saleServices first (voucher flow)
    final saleItems = paymentInfo.saleServices ?? [];
    if (saleItems.isNotEmpty) {
      try {
        return saleServiceList.services
            .firstWhere((s) => s.serviceItemId == saleItems.first.id);
      } catch (_) {}
    }

    // Try regular services
    if (paymentInfo.services.isNotEmpty) {
      return saleServiceList.findByServiceId(paymentInfo.services.first.id);
    }

    return null;
  }

  /// Resolves the service display name for the current booking.
  String? _resolveServiceName() {
    final clinic = _cubit.selectedClinic;
    final paymentInfo = _cubit.createDsmesBookingRequest?.paymentInfo;
    if (paymentInfo == null || clinic == null) return null;

    // Try regular services first
    if (paymentInfo.services.isNotEmpty) {
      final service =
          _findSelectedClinicServiceById(paymentInfo.services.first.id);
      if (service != null) return service.name;
    }

    // Try saleServices (find via serviceItemId → SaleServiceItem → then use its nameVi)
    final saleItems = paymentInfo.saleServices;
    if (saleItems != null && saleItems.isNotEmpty && clinic.saleServiceList != null) {
      try {
        final matched = clinic.saleServiceList!.services
            .firstWhere((s) => s.serviceItemId == saleItems.first.id);
        if (matched.nameVi.isNotEmpty) return matched.nameVi;
      } catch (_) {}
    }

    // Fallback: first available service
    final allServices = clinic.serviceList.categories
        .expand((c) => c.data)
        .toList();
    return allServices.isNotEmpty ? allServices.first.name : null;
  }

  static String _formatPrice(int price) {
    // if (price == 0) return 'Miễn phí';
    final buffer = StringBuffer();
    final s = price.toString();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buffer.write('.');
      buffer.write(s[i]);
    }
    return '${buffer}đ';
  }


  Future<void> _handleRescheduleBooking() async {
    final resp = await _cubit.rescheduleDsmesBooking(
      request: RescheduleDsmesBookingRequest(
        appointmentId: AppointmentId(id: widget.appointmentId!),
        startTime: _cubit.ensureTimeWithSeconds(
            _cubit.createDsmesBookingRequest!.startTime),
      ),
    );
    if (resp == null) return;

    final myAppointment =
        await _cubit.getDsmesAppointmentDetail(appointmentId: resp.id);

    if (myAppointment == null) return;

    Navigator.of(context, rootNavigator: true).pushNamed(
      NavigatorName.benefit_booking_detail,
      arguments: {
        'serviceType': widget.serviceType,
        'appointment': myAppointment,
        'bookingType': widget.bookingType,
      },
    );
  }

  void _showPopupBookingSuccess({
    required Function onNavigateHome,
    Function? onShowInfo,
    bool isShowImg = false,
    String? subtitle,
    String? title,
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
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            insetPadding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(12),
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
                        child: Icon(Icons.close,
                            color: R.color.textDark, size: 24),
                      ),
                    ],
                  ),
                  GapH(16),
                  if (isShowImg)
                    Image.asset(R.drawable.ic_dialog_success,
                        width: 43, height: 43),
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      title ?? '',
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: R.color.greenGradientBottom,
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      subtitle ?? '',
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
                            setState(() => isProcessing['recheckInfo'] = true);
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
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: R.color.white,
                              borderRadius: BorderRadius.circular(200),
                              border: Border.all(
                                  color: R.color.greenGradientBottom),
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
        );
      },
    );
  }

  void _showDialogUpdatePhone() {
    PhoneValidationHelper.showBottomSheetUpdatePhone(context).then((phone) {
      if (phone.isEmpty) return;
      _cubit.updateCreateDsmesBookingRequestRequesterInfo(
          name: nameController.text, phone: phone);
      phoneController.text = phone;
      setState(() => requesterPhone = phone);
    });
  }

  void _showEditRequesterInformationBottomSheet() {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: 270,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              R.string.change_consult_info.tr(),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Divider(color: R.color.color0xffE6E8EC),
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
            SizedBox(
              height: 54,
              child: TextFormField(
                minLines: 1,
                maxLines: 1,
                maxLength: 30,
                inputFormatters: [LengthLimitingTextFieldFormatterFixed(30)],
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
                  hintText: R.string.name.tr(),
                ),
              ),
            ),
            GapH(16),
            _buildButton(R.string.confirm.tr(), () {
              if (nameController.text.isEmpty) {
                Message.showToastMessage(
                    context, R.string.full_name_at_least_character.tr());
              }
              setState(() => requesterName = nameController.text.trim());
              _cubit.updateCreateDsmesBookingRequestRequesterInfo(
                  name: requesterName, phone: requesterPhone);
              Navigator.of(context).pop();
            }),
          ],
        ),
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  String _getTimeRange(String startTime, String endTime) {
    final start = DateFormat('HH:mm')
        .format(DateFormat('yyyy-MM-dd HH:mm').parse(startTime));
    final end = DateFormat('HH:mm')
        .format(DateFormat('yyyy-MM-dd HH:mm').parse(endTime));
    return '$start-$end';
  }

  String _getFormattedDate(String startTime) {
    final date = DateFormat('yyyy-MM-dd HH:mm').parse(startTime);
    final weekDay = DateUtil.weekDayToString(date, isDisplayfull: true);
    return '$weekDay, ${DateFormat('dd/MM/yyyy').format(date)}';
  }

  Widget _buildButton(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
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
}
