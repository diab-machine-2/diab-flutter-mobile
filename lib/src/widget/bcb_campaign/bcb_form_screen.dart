import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/bcb_campaign/bcb_partner_schedule_model.dart';
import 'package:medical/src/repo/bcb_campaign/bcb_campaign_client.dart';
import 'package:medical/src/widget/bcb_campaign/bcb_select_wish_slots_screen.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';

/// Điền form thông tin; chọn 3 khung giờ ở [BcbSelectWishSlotsScreen].
class BcbFormScreen extends StatefulWidget {
  final String bcbCampaignId;

  /// Label from Branch (`\$campaignName`), e.g. campaign date text shown in app bar.
  final String? bcbCampaignName;

  const BcbFormScreen({
    Key? key,
    required this.bcbCampaignId,
    this.bcbCampaignName,
  }) : super(key: key);

  @override
  State<BcbFormScreen> createState() => _BcbFormScreenState();
}

class _BcbFormScreenState extends State<BcbFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _doctorNoteController = TextEditingController();
  final _medicalHistoryController = TextEditingController();

  bool _loadingSchedule = false;
  List<BcbPartnerScheduleDay> _scheduleDays = const [];

  static const _radius = BorderRadius.all(Radius.circular(10));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      // BotToast.showLoading();
      await _prefetchScheduleDays();
    });
  }

  String _defaultCampaignTitle() => R.string.bcb_register_health_check.tr();

  String _branchCampaignLabel() {
    final n = widget.bcbCampaignName?.trim();
    if (n != null && n.isNotEmpty) return n;
    return _defaultCampaignTitle();
  }

  List<BcbPartnerScheduleDay> _activeScheduleDays(
      List<BcbPartnerScheduleDay> days) {
    final active = days
        .where((d) =>
            d.isActive &&
            d.examDateLocal != null &&
            d.slots.any((s) => s.isActive && !s.isFull))
        .toList();
    active.sort((a, b) => (a.examDateUnix ?? 0).compareTo(b.examDateUnix ?? 0));
    return active;
  }

  Future<List<BcbPartnerScheduleDay>> _fetchActiveScheduleDays() async {
    final client = BcbCampaignClient();
    final days = await client.fetchPartnerScheduleDays(widget.bcbCampaignId);
    // TODO: Apply filter isActive and isFull when BE ready _activeScheduleDays
    return days;
  }

  Future<void> _prefetchScheduleDays() async {
    try {
      final activeDays = await _fetchActiveScheduleDays();
      if (!mounted) return;
      if (activeDays.isEmpty) {
        BotToast.closeAllLoading();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(R.string.bcb_no_schedule_available.tr()),
            padding: EdgeInsets.fromLTRB(16, 16, 16, 28),
          ),
        );
        // Back to home when no schedule available
        Navigator.of(context).pop();
        return;
      }
      setState(() {
        _scheduleDays = activeDays;
      });
    } catch (_) {
      // Keep screen usable; we'll show actionable message when user continues.
    } finally {
      BotToast.closeAllLoading();
    }
  }

  @override
  void dispose() {
    _doctorNoteController.dispose();
    _medicalHistoryController.dispose();
    super.dispose();
  }

  Future<void> _continueToSlotSelection() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loadingSchedule = true);
    BotToast.showLoading();
    try {
      var activeDays = _scheduleDays;
      if (activeDays.isEmpty) {
        activeDays = await _fetchActiveScheduleDays();
        if (!mounted) return;
        setState(() {
          _scheduleDays = activeDays;
        });
      }
      if (!mounted) return;
      if (activeDays.isEmpty) {
        BotToast.closeAllLoading();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(R.string.bcb_no_schedule_available.tr()),
          ),
        );
        return;
      }
      BotToast.closeAllLoading();
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => BcbSelectWishSlotsScreen(
            bcbCampaignId: widget.bcbCampaignId,
            scheduleDays: activeDays,
            doctorNote: _doctorNoteController.text.trim().isEmpty
                ? null
                : _doctorNoteController.text.trim(),
            medicalHistory: _medicalHistoryController.text.trim().isEmpty
                ? null
                : _medicalHistoryController.text.trim(),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    } finally {
      BotToast.closeAllLoading();
      if (mounted) setState(() => _loadingSchedule = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: R.color.backgroundColorNew,
      body: Column(
        children: [
          _buildCustomAppBar(),
          Expanded(
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          R.string.bcb_note_for_doctor.tr(),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xff111515),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _doctorNoteController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: R.string.bcb_note_for_doctor_hint.tr(),
                            hintStyle: TextStyle(
                                color: R.color.captionColorGray,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                fontFamily: R.font.sfpro),
                            filled: true,
                            fillColor: R.color.white,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: _radius,
                              borderSide:
                                  BorderSide(color: const Color(0xffE5E7EB)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: _radius,
                              borderSide: BorderSide(
                                  color: R.color.greenGradientBottom),
                            ),
                            contentPadding: const EdgeInsets.all(12),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          R.string.bcb_medical_condition.tr(),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xff111515),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _medicalHistoryController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: R.string.bcb_medical_condition_hint.tr(),
                            hintStyle: TextStyle(
                                color: R.color.captionColorGray,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                fontFamily: R.font.sfpro),
                            filled: true,
                            fillColor: R.color.white,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: _radius,
                              borderSide:
                                  BorderSide(color: const Color(0xffE5E7EB)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: _radius,
                              borderSide: BorderSide(
                                  color: R.color.greenGradientBottom),
                            ),
                            contentPadding: const EdgeInsets.all(12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Material(
                    elevation: 8,
                    color: R.color.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: double.infinity,
                        child: InkWell(
                          onTap: _loadingSchedule
                              ? null
                              : _continueToSlotSelection,
                          borderRadius: BorderRadius.circular(200),
                          child: Ink(
                            height: 44,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(200),
                              gradient: _loadingSchedule
                                  ? null
                                  : LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        R.color.greenGradientTop02,
                                        R.color.greenGradientBottom,
                                      ],
                                    ),
                              color: _loadingSchedule
                                  ? R.color.color0xffC2C2C2
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                R.string.tiep_tuc.tr(),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xffFFFFFF),
                                ),
                              ),
                            ),
                          ),
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
    );
  }

  Widget _buildCustomAppBar() {
    return SizedBox(
      height: kToolbarHeight + MediaQuery.of(context).padding.top,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [R.color.greenGradientTop02, R.color.greenGradientBottom],
            stops: const [0.01, 0.99],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: CustomAppBar(
          backgroundColor: R.color.transparent,
          centerTitle: false,
          title: Text(
            _branchCampaignLabel(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: R.color.white,
            ),
          ),
          leadingIcon: IconButton(
            splashColor: R.color.transparent,
            highlightColor: R.color.transparent,
            icon: Icon(Icons.arrow_back, color: R.color.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
    );
  }
}
