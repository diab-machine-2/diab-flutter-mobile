import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/model/bcb_campaign/bcb_customer_appointment_model.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/medication_order_response.dart';
import 'package:medical/src/repo/bcb_campaign/bcb_campaign_client.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/date_utils.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/base/base_state.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/dsmes_appointment/dsmes_appointment_cubit.dart';
import 'package:medical/src/widget/dsmes_appointment/model/dsmes_appointment_model.dart';
import 'package:medical/src/widget/dsmes_appointment/widgets/dsmes_appointment_item.dart';
import 'package:medical/src/widget/dsmes_appointment/widgets/dsmes_empty_widget.dart';
import 'package:medical/src/widgets/gap_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sticky_headers/sticky_headers.dart';

/// Campaign booking statuses this page treats as "there's a real booking" —
/// see [BcbCustomerAppointmentModel.customerStatus]. 6/7 = booked (upcoming),
/// 8 = examined/đã khám (past), 9/10 = result delivered (past). Other values
/// (pre-booking, etc.) are skipped.
const _kCampaignBookedStatuses = {6, 7};
const _kCampaignExaminedStatuses = {8};
const _kCampaignResultStatuses = {9, 10};

/// A unified appointment + medication-order history screen for the Benefit flow.
class BenefitAppointmentHistoryPage extends StatefulWidget {
  const BenefitAppointmentHistoryPage({Key? key}) : super(key: key);

  @override
  _BenefitAppointmentHistoryPageState createState() =>
      _BenefitAppointmentHistoryPageState();
}

class _BenefitAppointmentHistoryPageState
    extends BaseState<BenefitAppointmentHistoryPage> {
  final RefreshController _refreshController = RefreshController();
  late DsmesAppointmentCubit _cubit;
  final AppRepository _repository = AppRepository();

  Map<String, bool> isProcessing = {'chooseService': false};
  bool isLoading = false;

  List<DsmesAppointment> sortedMyAppointments = [];
  List<MedicationOrderItem> medicationOrders = [];
  BcbCustomerAppointmentModel? campaignAppointment;

  @override
  void initState() {
    super.initState();
    _cubit = DsmesAppointmentCubit(_repository);
    _initData();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    // A pushed route (e.g. reschedule's "Về trang chủ" landing on a fresh
    // BcbDetailAppointmentScreen, or the DSMES/medication-order detail
    // pages) popped back to this page — refresh so it reflects any change.
    _initData(showLoadingIndicator: false);
    super.didPopNext();
  }

  Future<void> _initData({bool showLoadingIndicator = true}) async {
    if (showLoadingIndicator) setState(() => isLoading = true);

    final docosanToken = await AppSettings.getDocosanToken();
    if (!mounted) return;
    if (docosanToken == null || docosanToken.isEmpty) {
      final phoneNumber = AppSettings.userInfo?.phoneNumber;
      if (phoneNumber == null) {
        setState(() => isLoading = false);
        return;
      }
      await _cubit.registerDocosanUser(
          phoneNumber: Utils.formatPhoneNumber(phoneNumber));
      if (!mounted) return;
    }

    await Future.wait([
      _cubit.getDsmesAppointmentList(
          page: 1, isRefresh: true, showLoading: false),
      _loadMedicationOrders(),
      _loadCampaignAppointments(),
    ]);
    if (!mounted) return;

    sortedMyAppointments = _cubit.getSortedAppointments();
    setState(() => isLoading = false);
  }

  Future<void> _loadMedicationOrders() async {
    final result = await _repository.getMedicationOrders();
    result.when(
      success: (data) {
        medicationOrders = data.items ?? [];
      },
      failure: (_) {
        medicationOrders = [];
      },
    );
  }

  /// Fetches the user's registered BCB campaign appointment, if any.
  /// `App/BcbCustomerAppointment/my-registered` resolves the current user's
  /// booking without needing a campaignId. Only kept if it's an actual
  /// booking (`customerStatus` 6/7/8/9/10; see [_kCampaignBookedStatuses]).
  Future<void> _loadCampaignAppointments() async {
    try {
      final appt = await BcbCampaignClient().fetchMyRegisteredAppointment(null);
      final status = appt?.customerStatus;
      campaignAppointment = (_kCampaignBookedStatuses.contains(status) ||
              _kCampaignExaminedStatuses.contains(status) ||
              _kCampaignResultStatuses.contains(status))
          ? appt
          : null;
    } catch (_) {
      campaignAppointment = null;
    }
  }

  List<_MergedItem> _buildUpcomingItems(List<DsmesAppointment> appointments) {
    final items = <_MergedItem>[];

    for (final a in appointments) {
      final end = DateFormat('yyyy-MM-dd HH:mm:ss').parse(a.endTime);
      final isPast = end.isBefore(DateTime.now());
      if (a.status == DSMES_STATUS_REQUEST ||
          a.status == DSMES_STATUS_ON_HOLD ||
          (a.status == DSMES_STATUS_APPROVE && !isPast)) {
        items.add(_MergedItem.appointment(a));
      }
    }

    for (final order in medicationOrders) {
      items.add(_MergedItem.medicationOrder(order));
    }

    final campaignAppt = campaignAppointment;
    if (campaignAppt != null &&
        _kCampaignBookedStatuses.contains(campaignAppt.customerStatus)) {
      items.add(_MergedItem.campaign(campaignAppt));
    }

    items.sort((a, b) => b.sortTimestamp.compareTo(a.sortTimestamp));
    return items;
  }

  List<_MergedItem> _buildPastItems(List<DsmesAppointment> appointments) {
    final items = <_MergedItem>[];
    for (final a in appointments) {
      final end = DateFormat('yyyy-MM-dd HH:mm:ss').parse(a.endTime);
      final isPast = end.isBefore(DateTime.now());
      if (a.status == DSMES_STATUS_REJECT ||
          (a.status == DSMES_STATUS_APPROVE && isPast)) {
        items.add(_MergedItem.appointment(a));
      }
    }

    final campaignAppt = campaignAppointment;
    if (campaignAppt != null &&
        (_kCampaignExaminedStatuses.contains(campaignAppt.customerStatus) ||
            _kCampaignResultStatuses.contains(campaignAppt.customerStatus))) {
      items.add(_MergedItem.campaign(campaignAppt));
    }

    items.sort((a, b) => b.sortTimestamp.compareTo(a.sortTimestamp));
    return items;
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
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final upcomingItems = _buildUpcomingItems(sortedMyAppointments);
    final pastItems = _buildPastItems(sortedMyAppointments);
    final isEmpty = upcomingItems.isEmpty && pastItems.isEmpty;

    if (isEmpty) {
      return DsmesEmptyWidget(
        imagePath: R.drawable.dsmes_empty,
      title: R.string.empty_history_appointment.tr(),
        titleColor: R.color.color0xff636A6B,
        subtitle: '',
      );
    }

    return SmartRefresher(
      controller: _refreshController,
      enablePullUp: _cubit.hasMore,
      footer: _cubit.hasMore
          ? ClassicFooter(
              loadingText: R.string.loading.tr(),
              canLoadingText: R.string.pull_up_to_load_more.tr(),
            )
          : null,
      onRefresh: () async {
        await Future.wait([
          _cubit.getDsmesAppointmentList(
              isRefresh: true, page: 1, showLoading: false),
          _loadMedicationOrders(),
          _loadCampaignAppointments(),
        ]);
        if (!mounted) return;
        sortedMyAppointments = _cubit.getSortedAppointments();
        _refreshController.refreshCompleted();
        setState(() {});
      },
      onLoading: () async {
        await _cubit.getDsmesAppointmentList(
            page: _cubit.currentPage + 1, showLoading: false);
        if (!mounted) return;
        sortedMyAppointments = _cubit.getSortedAppointments();
        _refreshController.loadComplete();
        setState(() {});
      },
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        itemCount: 2,
        itemBuilder: (context, sectionIndex) {
          final sectionItems = sectionIndex == 0 ? upcomingItems : pastItems;
          final isExpanded = ValueNotifier<bool>(true);

          return StickyHeader(
            header: GestureDetector(
              onTap: () => isExpanded.value = !isExpanded.value,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
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
                      builder: (context, expanded, child) => Icon(
                        expanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: R.color.color0xff636A6B,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            content: ValueListenableBuilder<bool>(
              valueListenable: isExpanded,
              builder: (context, expanded, child) {
                if (!expanded) return const SizedBox.shrink();
                return ListView.separated(
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: sectionItems.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) =>
                      _buildMergedItem(context, sectionItems[index]),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildMergedItem(BuildContext context, _MergedItem item) {
    if (item.appointment != null) {
      final data = item.appointment!;
      final benefitBookingType =
          data.mode == DsmesAppointmentMode.telemedicine.toString()
              ? Const.BENEFIT_BOOKING_TELEMEDICINE
              : Const.BENEFIT_BOOKING_AT_CLINIC;
      return DsmesAppointmentItem(
        data: data,
        displayActionButtons: true,
        bookingType: '',
        joinButtonOnly: true,
        onChooseService: () async {
          if (isProcessing['chooseService']!) return;
          isProcessing['chooseService'] = true;
          try {
            final detailSuccess = await _cubit.getClinicDetail(
                id: data.branchId ?? data.clinicId);
            if (!detailSuccess || _cubit.selectedClinic == null) return;
            final appointment =
                await _cubit.getDsmesAppointmentDetail(appointmentId: data.id);
            final result =
                await Navigator.of(context, rootNavigator: true).pushNamed(
              NavigatorName.benefit_booking_detail,
              arguments: {
                'serviceType': appointment?.mode,
                'appointment': appointment,
                'previousRoute': NavigatorName.benefit_appointment_history,
                'bookingType': benefitBookingType,
                'branchAddress': _cubit.selectedClinic?.address,
              },
            );
            if (result == true) await _initData(showLoadingIndicator: false);
          } finally {
            isProcessing['chooseService'] = false;
          }
        },
        cubit: _cubit,
      );
    }

    if (item.campaignAppointment != null) {
      return _buildCampaignAppointmentItem(context, item.campaignAppointment!);
    }

    return _buildMedicationOrderItem(context, item.order!);
  }

  Widget _buildCampaignAppointmentItem(
    BuildContext context,
    BcbCustomerAppointmentModel appointment,
  ) {
    final String statusLabel;
    if (_kCampaignBookedStatuses.contains(appointment.customerStatus)) {
      statusLabel = R.string.benefit_campaign_booked.tr();
    } else if (_kCampaignExaminedStatuses.contains(appointment.customerStatus)) {
      statusLabel = R.string.da_kham.tr();
    } else {
      statusLabel = R.string.benefit_campaign_result_delivered.tr();
    }

    final examLocal = appointment.examDateLocal;
    final dateStr = examLocal != null
        ? '${DateUtil.weekDayToString(examLocal, isDisplayfull: true)}, ${DateFormat('dd/MM/yyyy').format(examLocal)}'
        : '';

    return GestureDetector(
      onTap: () async {
        await Navigator.of(context, rootNavigator: true).pushNamed(
          NavigatorName.bcb_detail_appointment,
          arguments: {
            'campaignId': appointment.campaignId,
            'fromBenefitHistory': true,
          },
        );
        await _initData(showLoadingIndicator: false);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [Utils.getBoxShadowDropCard()],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(R.drawable.ic_at_clinic, width: 20, height: 20),
                    const SizedBox(width: 10),
                    Text(
                      R.string.benefit_calendar.tr(),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF111515),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5F7F5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Text(
                    statusLabel,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF008479),
                    ),
                  ),
                ),
              ],
            ),
            const GapH(12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Image.asset(
                    R.drawable.diab_logo,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                ),
                const GapW(8),
                Flexible(
                  child: Text(
                    appointment.partnerName ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111515),
                    ),
                  ),
                ),
              ],
            ),
            if (dateStr.isNotEmpty) ...[
              const GapH(4),
              Row(
                children: [
                  const SizedBox(width: 48),
                  Text(
                    dateStr,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF111515),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child:
                        Image.asset(R.drawable.ic_ellipse, width: 6, height: 6),
                  ),
                  Text(
                    appointment.timeRange,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF111515),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationOrderItem(
      BuildContext context, MedicationOrderItem order) {
    final isMedicine = order.isMedicine;
    final typeLabel = isMedicine
        ? R.string.benefit_order_type_medicine.tr()
        : R.string.benefit_order_type_lab.tr();
    final subtitle =
        isMedicine ? (order.prescriptionName ?? '') : (order.diagnose ?? '');
    final dateStr = order.createDate != null
        ? DateFormat('dd/MM/yyyy').format(order.createDate!)
        : '';

    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(
        NavigatorName.benefit_medication_order_detail,
        arguments: {'order': order},
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [Utils.getBoxShadowDropCard()],
        ),
        child: Column(
          children: [
            // Header: icon + type label | status badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    isMedicine
                        ? SvgPicture.asset(
                            R.icons.ic_purchase_medicine,
                            width: 20,
                            height: 20,
                          )
                        : SvgPicture.asset(
                            R.icons.ic_paraclinical,
                            width: 20,
                            height: 20,
                          ),
                    const SizedBox(width: 10),
                    Text(
                      typeLabel,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF111515),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5F7F5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Text(
                    R.string.benefit_already_requested.tr(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF008479),
                    ),
                  ),
                ),
              ],
            ),
            const GapH(12),
            // Content: icon + name (matching _buildClinicInfo)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Image.asset(
                    R.drawable.diab_logo,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                ),
                const GapW(8),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subtitle.isNotEmpty ? subtitle : typeLabel,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111515),
                        ),
                      ),
                      // if (order.medications.isNotEmpty) ...[
                      //   const GapH(4),
                      //   ...order.medications.map(
                      //     (med) => Padding(
                      //       padding: const EdgeInsets.only(bottom: 2),
                      //       child: Text(
                      //         med.name,
                      //         maxLines: 1,
                      //         overflow: TextOverflow.ellipsis,
                      //         style: const TextStyle(
                      //           fontSize: 13,
                      //           color: Color(0xFF636A6B),
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ],
                    ],
                  ),
                ),
              ],
            ),
            if (dateStr.isNotEmpty) ...[
              const GapH(4),
              Row(
                children: [
                  const SizedBox(width: 48),
                  Text(
                    dateStr,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF111515),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Discriminated union: a DsmesAppointment, a MedicationOrderItem, or a BCB
/// campaign booking.
class _MergedItem {
  final DsmesAppointment? appointment;
  final MedicationOrderItem? order;
  final BcbCustomerAppointmentModel? campaignAppointment;
  final int sortTimestamp;

  _MergedItem.appointment(DsmesAppointment a)
      : appointment = a,
        order = null,
        campaignAppointment = null,
        sortTimestamp = DateFormat('yyyy-MM-dd HH:mm:ss')
            .parse(a.startTime)
            .millisecondsSinceEpoch;

  _MergedItem.medicationOrder(MedicationOrderItem o)
      : appointment = null,
        order = o,
        campaignAppointment = null,
        sortTimestamp = (o.createDatetime ?? 0) * 1000;

  _MergedItem.campaign(BcbCustomerAppointmentModel a)
      : appointment = null,
        order = null,
        campaignAppointment = a,
        sortTimestamp = _campaignSortTimestamp(a);

  static int _campaignSortTimestamp(BcbCustomerAppointmentModel a) {
    final examDate = a.examDateLocal;
    if (examDate == null) return 0;
    final parts = (a.startTime ?? '').split(':');
    final hour = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return DateTime(examDate.year, examDate.month, examDate.day, hour, minute)
        .millisecondsSinceEpoch;
  }
}
