import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/bloc/bcb_campaign/bcb_campaign_bloc.dart';
import 'package:medical/src/model/bcb_campaign/bcb_partner_schedule_model.dart';
import 'package:medical/src/model/bcb_campaign/bcb_selected_wish_slot.dart';
import 'package:medical/src/utils/date_utils.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/BloodSugar/widget/section_add_note.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/bcb_campaign/bcb_select_wish_slots_screen.dart';
import 'package:medical/src/widget/home/widget/home_support_functions.dart';
import 'package:medical/src/widgets/gap_widget.dart';

class BcbCampaignConfirmationScreen extends StatefulWidget {
  final String bcbCampaignId;
  final String? bcbCampaignName;
  final List<BcbPartnerScheduleDay> scheduleDays;
  final BcbSelectedWishSlot selectedWishSlot;
  final String? initialDoctorNote;

  const BcbCampaignConfirmationScreen({
    Key? key,
    required this.bcbCampaignId,
    this.bcbCampaignName,
    required this.scheduleDays,
    required this.selectedWishSlot,
    this.initialDoctorNote,
  }) : super(key: key);

  @override
  State<BcbCampaignConfirmationScreen> createState() =>
      _BcbCampaignConfirmationScreenState();
}

class _BcbCampaignConfirmationScreenState
    extends State<BcbCampaignConfirmationScreen> {
  late final BcbCampaignBloc _bloc;
  final _noteFocusNode = FocusNode();
  late final TextEditingController _noteController;
  final GlobalKey<SectionAddNoteState> _sectionAddNoteKey =
      GlobalKey<SectionAddNoteState>();

  @override
  void initState() {
    super.initState();
    _bloc = BcbCampaignBloc();
    _noteController =
        TextEditingController(text: widget.initialDoctorNote ?? '');
  }

  @override
  void dispose() {
    _bloc.close();
    _noteFocusNode.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String _slotLabel(BcbPartnerScheduleDay day, BcbPartnerScheduleSlot slot) {
    String short(String? value) {
      final text = value ?? '';
      final parts = text.split(':');
      if (parts.length >= 2) return '${parts[0]}:${parts[1]}';
      return text;
    }

    return '${short(slot.startTime)}-${short(slot.endTime)}';
  }

  String _formattedDate(BcbPartnerScheduleDay day) {
    final date = day.examDateLocal;
    if (date == null) return '';
    final weekDay = DateUtil.weekDayToString(date, isDisplayfull: true);
    return '$weekDay, ${DateFormat('dd/MM/yyyy').format(date)}';
  }

  String? get _partnerHotline {
    final hotline = widget.selectedWishSlot.day.partnerHotline?.trim();
    if (hotline != null && hotline.isNotEmpty) return hotline;
    for (final day in widget.scheduleDays) {
      final value = day.partnerHotline?.trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }

  void _editService() {
    final note =
        _sectionAddNoteKey.currentState?.getNote().note ?? _noteController.text;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => BcbSelectWishSlotsScreen(
          bcbCampaignId: widget.bcbCampaignId,
          bcbCampaignName: widget.bcbCampaignName,
          scheduleDays: widget.scheduleDays,
          selectedWishSlot: widget.selectedWishSlot,
          initialDoctorNote: note,
        ),
      ),
    );
  }

  void _submit() {
    final note = (_sectionAddNoteKey.currentState?.getNote().note ?? '').trim();
    final slotId = widget.selectedWishSlot.slot.id ?? '';
    if (slotId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(R.string.bcb_slot_id_missing.tr())),
      );
      return;
    }
    _bloc.add(
      SubmitBcbRegistrationEvent(
        bcbCampaignId: widget.bcbCampaignId,
        doctorNote: note.isEmpty ? null : note,
        slotId: slotId,
      ),
    );
  }

  void _showSuccessAndGoHome() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 16),
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
                        Navigator.pop(dialogContext);
                        navigatorKey.currentState?.pushNamedAndRemoveUntil(
                          NavigatorName.tabbar,
                          (route) => false,
                        );
                      },
                      child: Icon(
                        Icons.close,
                        color: R.color.textDark,
                        size: 24,
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                Image.asset(R.drawable.ic_dialog_success,
                    width: 43, height: 43),
                Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Text(
                    R.string.congratulation_on.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: R.color.color0xff636A6B,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    R.string.booking_success_dialog_title.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: R.color.greenGradientBottom,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    R.string.bcb_success_contact_subtitle.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: R.color.color0xff777E90,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(dialogContext);
                          navigatorKey.currentState?.pushNamedAndRemoveUntil(
                            NavigatorName.bcb_detail_appointment,
                            (route) =>
                                route.settings.name == NavigatorName.tabbar ||
                                !Navigator.of(context).canPop(),
                            arguments: {'campaignId': widget.bcbCampaignId},
                          );
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
                              R.string.recheck_information.tr(),
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
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(dialogContext);
                          navigatorKey.currentState?.pushNamedAndRemoveUntil(
                            NavigatorName.tabbar,
                            (route) => false,
                          );
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
                              R.string.back_home_page.tr(),
                              style: TextStyle(
                                color: R.color.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: R.color.backgroundColorNew,
        body: BlocConsumer<BcbCampaignBloc, BcbCampaignState>(
          listener: (context, state) {
            if (state is BcbCampaignLoading) {
              BotToast.showLoading();
            } else {
              BotToast.closeAllLoading();
            }

            if (state is BcbRegistrationSubmitted) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) _showSuccessAndGoHome();
              });
            } else if (state is BcbCampaignError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: const Color(0xffEF4444),
                ),
              );
            }
          },
          builder: (context, state) {
            final submitting = state is BcbCampaignLoading;
            return Column(
              children: [
                _buildCustomAppBar(),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Utils.hideKeyboard(context),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          _buildCustomerInformation(),
                          GapH(12),
                          _buildServiceInformation(),
                          GapH(12),
                          _buildClinicInformation(),
                          GapH(12),
                          _buildNoteSection(),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 74,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    boxShadow: [Utils.getBoxShadowDropButton()],
                    color: R.color.white,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Opacity(
                          opacity: submitting ? 0.6 : 1,
                          child: _buildButton(
                            R.string.submit_booking.tr(),
                            submitting ? null : _submit,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCustomerInformation() {
    final user = AppSettings.userInfo;
    return _buildCard(
      child: Column(
        children: [
          _buildSectionHeader(R.string.customer_information.tr()),
          GapH(16),
          _buildInfoRow(R.string.name.tr(), user?.fullName ?? ''),
          GapH(4),
          _buildInfoRow(R.string.so_dien_thoai.tr(), user?.phoneNumber ?? ''),
        ],
      ),
    );
  }

  Widget _buildServiceInformation() {
    return _buildCard(
      child: Column(
        children: [
          _buildSectionHeader(
            R.string.service.tr(),
            action: InkWell(
              onTap: _editService,
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
          GapH(12),
          _buildInfoRow(
            R.string.thoi_gian.tr(),
            _slotLabel(
                widget.selectedWishSlot.day, widget.selectedWishSlot.slot),
            valueColor: R.color.greenGradientBottom,
            valueWeight: FontWeight.w700,
          ),
          GapH(4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              _formattedDate(widget.selectedWishSlot.day),
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: R.color.greenGradientBottom,
              ),
            ),
          ),
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

  Widget _buildClinicInformation() {
    final day = widget.selectedWishSlot.day;
    return _buildCard(
      child: Column(
        children: [
          _buildSectionHeader(R.string.kham_tai_phong_kham.tr()),
          GapH(16),
          _buildInfoRow(
            R.string.centre_name.tr(),
            (day.partnerName ?? '').toUpperCase(),
          ),
          GapH(4),
          _buildInfoRow(R.string.address.tr(), day.partnerAddress ?? ''),
          GapH(4),
          _buildInfoRow(
            'Hotline',
            day.partnerHotline ?? '',
          ),
        ],
      ),
    );
  }

  Widget _buildNoteSection() {
    return SectionAddNote(
      key: _sectionAddNoteKey,
      focusNode: _noteFocusNode,
      controllerNote: _noteController,
      maxMedia: 0,
      showCameraIcons: false,
      noteTitle: R.string.ghi_chu.tr(),
      horizontalPadding: 12,
    );
  }

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

  Widget _buildSectionHeader(String title, {Widget? action}) {
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
        if (action != null) action,
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
          flex: 5,
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
          flex: 8,
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

  Widget _buildButton(String text, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: R.color.mainColor,
          borderRadius: BorderRadius.circular(200),
          gradient: onTap == null
              ? null
              : LinearGradient(
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
            R.string.confirm_information.tr(),
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
