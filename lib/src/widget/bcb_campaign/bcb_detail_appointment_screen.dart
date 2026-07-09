import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app.dart';
import 'package:medical/src/model/bcb_campaign/bcb_customer_appointment_model.dart';
import 'package:medical/src/model/bcb_campaign/bcb_partner_info_model.dart';
import 'package:medical/src/model/bcb_campaign/bcb_selected_wish_slot.dart';
import 'package:medical/src/repo/bcb_campaign/bcb_campaign_client.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/date_utils.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/bcb_campaign/bcb_select_wish_slots_screen.dart';
import 'package:medical/src/widget/home/widget/home_support_functions.dart';
import 'package:medical/src/widgets/gap_widget.dart';

class BcbDetailAppointmentScreen extends StatefulWidget {
  final String campaignId;

  const BcbDetailAppointmentScreen({
    Key? key,
    required this.campaignId,
  }) : super(key: key);

  @override
  State<BcbDetailAppointmentScreen> createState() =>
      _BcbDetailAppointmentScreenState();
}

class _BcbDetailAppointmentScreenState
    extends State<BcbDetailAppointmentScreen> {
  BcbCustomerAppointmentModel? _appointment;
  bool _loading = true;
  bool _reschedulingLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchAppointment();
  }

  Future<void> _fetchAppointment() async {
    try {
      final client = BcbCampaignClient();
      final result =
          await client.fetchMyRegisteredAppointment(widget.campaignId);
      if (!mounted) return;
      setState(() {
        _appointment = result;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _loading = false;
      });
    }
  }

  String? get _partnerHotline {
    final hotline = _appointment?.partnerHotline?.trim();
    if (hotline != null && hotline.isNotEmpty) return hotline;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: R.color.backgroundColorNew,
      body: Column(
        children: [
          _buildCustomAppBar(),
          Expanded(
            child: _loading
                ? Center(
                    child: CircularProgressIndicator(
                      color: R.color.greenGradientBottom,
                    ),
                  )
                : _errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: R.color.color0xff636A6B,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      )
                    : _appointment == null
                        ? Center(
                            child: Text(
                              R.string.error_can_not_connect_to_server.tr(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: R.color.color0xff636A6B,
                                fontSize: 15,
                              ),
                            ),
                          )
                        : _buildContent(),
          ),
          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _buildCustomerInformation(),
          GapH(12),
          _buildServiceInformation(),
          GapH(12),
          _buildClinicInformation(),
          if (_appointment?.doctorNote != null &&
              _appointment!.doctorNote!.trim().isNotEmpty) ...[
            GapH(12),
            _buildNoteSection(),
          ],
        ],
      ),
    );
  }

  // ─── Customer Section ───────────────────────────────────────────────

  Widget _buildCustomerInformation() {
    final a = _appointment!;
    return _buildCard(
      child: Column(
        children: [
          _buildSectionHeader(R.string.customer_information.tr()),
          GapH(16),
          _buildInfoRow(R.string.name.tr(), a.fullName ?? ''),
          GapH(4),
          _buildInfoRow(R.string.so_dien_thoai.tr(), a.phone ?? ''),
          if (a.email != null && a.email!.trim().isNotEmpty) ...[
            GapH(4),
            _buildInfoRow('Email', a.email!),
          ],
        ],
      ),
    );
  }

  // ─── Service Section ────────────────────────────────────────────────

  Widget _buildServiceInformation() {
    final a = _appointment!;
    final examLocal = a.examDateLocal;
    String formattedDate = '';
    if (examLocal != null) {
      final weekDay = DateUtil.weekDayToString(examLocal, isDisplayfull: true);
      formattedDate = '$weekDay, ${DateFormat('dd/MM/yyyy').format(examLocal)}';
    }

    return _buildCard(
      child: Column(
        children: [
          _buildSectionHeader(R.string.service.tr()),
          GapH(12),
          _buildInfoRow(
            R.string.thoi_gian.tr(),
            a.timeRange,
            valueColor: R.color.greenGradientBottom,
            valueWeight: FontWeight.w700,
          ),
          if (formattedDate.isNotEmpty) ...[
            GapH(4),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                formattedDate,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: R.color.greenGradientBottom,
                ),
              ),
            ),
          ],
          GapH(12),
          _buildInfoRow(
            R.string.appointment_details.tr(),
            R.string.corporate_health_checkup.tr(),
            valueColor: R.color.greenGradientBottom,
            valueWeight: FontWeight.w700,
          ),
        ],
      ),
    );
  }

  // ─── Clinic Info Section ────────────────────────────────────────────

  Widget _buildClinicInformation() {
    final a = _appointment!;
    return _buildCard(
      child: Column(
        children: [
          _buildSectionHeader(R.string.kham_tai_phong_kham.tr()),
          GapH(16),
          _buildInfoRow(
            R.string.centre_name.tr(),
            (a.partnerName ?? '').toUpperCase(),
          ),
          GapH(4),
          _buildInfoRow(R.string.address.tr(), a.partnerAddress ?? ''),
          GapH(4),
          _buildInfoRow('Hotline', a.partnerHotline ?? ''),
        ],
      ),
    );
  }

  // ─── Note Section (read-only) ───────────────────────────────────────

  Widget _buildNoteSection() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(R.string.ghi_chu.tr()),
          GapH(12),
          Text(
            _appointment!.doctorNote ?? '',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: R.color.color0xff111515,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Bottom Button ──────────────────────────────────────────────────

  Widget _buildBottomButton() {
    return Container(
      height: 74,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        boxShadow: [Utils.getBoxShadowDropButton()],
        color: R.color.white,
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildOutlineButton(
              R.string.bcb_doi_lich.tr(),
              _reschedulingLoading || _appointment == null
                  ? null
                  : _onRescheduleTap,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildGradientButton(
              R.string.back_home_page.tr(),
              () {
                navigatorKey.currentState?.pushNamedAndRemoveUntil(
                  NavigatorName.tabbar,
                  (route) => false,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onRescheduleTap() async {
    final appt = _appointment;
    if (appt == null) return;
    setState(() => _reschedulingLoading = true);
    try {
      final partners =
          await BcbCampaignClient().fetchPartnerInfos(widget.campaignId);
      BcbPartnerInfo? partner;
      if (appt.partnerId != null) {
        try {
          partner =
              partners.firstWhere((p) => p.partnerId == appt.partnerId);
        } catch (_) {}
      }
      final scheduleDays =
          (partner ?? (partners.isNotEmpty ? partners.first : null))
                  ?.toScheduleDays() ??
              [];
      BcbSelectedWishSlot? currentSelection;
      for (final day in scheduleDays) {
        for (final slot in day.slots) {
          if (slot.id == appt.slotId) {
            currentSelection = BcbSelectedWishSlot(day: day, slot: slot);
            break;
          }
        }
        if (currentSelection != null) break;
      }
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => BcbSelectWishSlotsScreen(
            bcbCampaignId: widget.campaignId,
            scheduleDays: scheduleDays,
            selectedWishSlot: currentSelection,
            isReschedule: true,
            appointmentId: appt.appointmentId,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _reschedulingLoading = false);
    }
  }

  // ─── Shared Widgets ─────────────────────────────────────────────────

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: R.color.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [Utils.getBoxShadowDropCard()],
      ),
      child: child,
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: R.color.color0xff141416,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    Color? valueColor,
    FontWeight valueWeight = FontWeight.w400,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          flex: 3,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: R.color.color0xff636A6B,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          flex: 7,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 15,
              fontWeight: valueWeight,
              color: valueColor ?? R.color.color0xff111515,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOutlineButton(String text, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.5 : 1.0,
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: R.color.white,
            borderRadius: BorderRadius.circular(200),
            border: Border.all(color: R.color.greenGradientBottom),
          ),
          child: Center(
            child: _reschedulingLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: R.color.greenGradientBottom,
                    ),
                  )
                : Text(
                    text,
                    style: TextStyle(
                      color: R.color.greenGradientBottom,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildGradientButton(String text, VoidCallback onTap) {
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

  // ─── App Bar ────────────────────────────────────────────────────────

  Widget _buildCustomAppBar() {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [R.color.greenGradientTop02, R.color.greenGradientBottom],
          stops: const [0.01, 0.99],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
      ),
      child: CustomAppBar(
        backgroundColor: Colors.transparent,
        centerTitle: false,
        title: MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: MediaQuery.of(context)
                .textScaler
                .clamp(minScaleFactor: 1.0, maxScaleFactor: 1.3),
          ),
          child: Text(
            R.string.schedule_information.tr(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: R.color.white,
            ),
          ),
        ),
        leadingIcon: IconButton(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          icon: Icon(Icons.arrow_back, color: R.color.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [_buildContactAction()],
      ),
    );
  }

  Widget _buildContactAction() {
    return InkWell(
      onTap: () async {
        await HomeSupportFunctions.showModalAddData(
          context,
          hotline: _partnerHotline,
        );
      },
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
        margin: const EdgeInsets.fromLTRB(0, 12, 16, 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: R.color.color0xffCAFAF5,
          border: Border.all(
            color: R.color.color0xff8FEBE0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              R.icons.ic_telephone,
              width: 16,
              height: 16,
              color: R.color.greenGradientBottom,
              fit: BoxFit.scaleDown,
            ),
            GapW(4),
            MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: MediaQuery.of(context)
                    .textScaler
                    .clamp(minScaleFactor: 1.0, maxScaleFactor: 1.3),
              ),
              child: Text(
                R.string.contact.tr(),
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'sfpro',
                  fontWeight: FontWeight.w700,
                  color: R.color.greenGradientBottom,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
