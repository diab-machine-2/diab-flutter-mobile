import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app.dart';
import 'package:medical/src/bloc/bcb_campaign/bcb_campaign_bloc.dart';
import 'package:medical/src/model/bcb_campaign/bcb_partner_schedule_model.dart';
import 'package:medical/src/utils/date_utils.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';

class _SelectedWishSlot {
  final BcbPartnerScheduleDay day;
  final BcbPartnerScheduleSlot slot;

  const _SelectedWishSlot({required this.day, required this.slot});

  String get key => '${day.id}_${slot.id}';
}

/// Chọn tối đa 3 khung giờ khám mong muốn (theo lịch partner), rồi gửi đăng ký.
class BcbSelectWishSlotsScreen extends StatefulWidget {
  final String bcbCampaignId;
  final List<BcbPartnerScheduleDay> scheduleDays;
  final String? doctorNote;
  final String? medicalHistory;

  const BcbSelectWishSlotsScreen({
    Key? key,
    required this.bcbCampaignId,
    required this.scheduleDays,
    this.doctorNote,
    this.medicalHistory,
  }) : super(key: key);

  @override
  State<BcbSelectWishSlotsScreen> createState() =>
      _BcbSelectWishSlotsScreenState();
}

class _BcbSelectWishSlotsScreenState extends State<BcbSelectWishSlotsScreen> {
  late final BcbCampaignBloc _bloc;
  List<BcbPartnerScheduleDay> _days = [];

  BcbPartnerScheduleDay? _selectedDay;
  bool _morning = true;
  final List<_SelectedWishSlot> _selectionOrder = [];

  void _runAfterBuild(VoidCallback action) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      action();
    });
  }

  @override
  void initState() {
    super.initState();
    _bloc = BcbCampaignBloc();
    _applySchedule(widget.scheduleDays);
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  void _applySchedule(List<BcbPartnerScheduleDay> list) {
    // final activeDays = list
    //     .where((d) =>
    //         d.isActive &&
    //         d.examDateLocal != null &&
    //         d.slots.any((s) => s.isActive && !s.isFull))
    //     .toList();
    final activeDays = list;
    activeDays
        .sort((a, b) => (a.examDateUnix ?? 0).compareTo(b.examDateUnix ?? 0));
    setState(() {
      _days = activeDays;
      _selectedDay = activeDays.isNotEmpty ? activeDays.first : null;
      _morning = _defaultMorningForDay(_selectedDay);
      _selectionOrder.clear();
    });
  }

  bool _defaultMorningForDay(BcbPartnerScheduleDay? day) {
    if (day == null) return true;
    final morningSlots = _slotsForPeriod(day, true);
    final afternoonSlots = _slotsForPeriod(day, false);
    if (morningSlots.isNotEmpty) return true;
    if (afternoonSlots.isNotEmpty) return false;
    return true;
  }

  List<BcbPartnerScheduleSlot> _slotsForPeriod(
      BcbPartnerScheduleDay day, bool morning) {
    final slots = day.slots.where((s) {
      if (s.startTime == null) return false;
      final t = _parseTimeOnDay(day, s.startTime!);
      if (t == null) return false;
      return morning ? t.hour < 12 : t.hour >= 12;
    }).toList();
    slots.sort((a, b) {
      final at =
          a.startTime == null ? null : _parseTimeOnDay(day, a.startTime!);
      final bt =
          b.startTime == null ? null : _parseTimeOnDay(day, b.startTime!);
      if (at == null && bt == null) return 0;
      if (at == null) return 1;
      if (bt == null) return -1;
      return at.compareTo(bt);
    });
    return slots;
  }

  DateTime? _parseTimeOnDay(BcbPartnerScheduleDay day, String hms) {
    final base = day.examDateLocal;
    if (base == null) return null;
    final parts = hms.split(':');
    if (parts.isEmpty) return null;
    final h = int.tryParse(parts[0]) ?? 0;
    final m = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    final sec = parts.length > 2 ? int.tryParse(parts[2]) ?? 0 : 0;
    return DateTime(base.year, base.month, base.day, h, m, sec);
  }

  String _slotLabel(BcbPartnerScheduleDay day, BcbPartnerScheduleSlot slot) {
    final a = slot.startTime ?? '';
    final b = slot.endTime ?? '';
    String short(String t) {
      final p = t.split(':');
      if (p.length >= 2) return '${p[0]}:${p[1]}';
      return t;
    }

    return '${short(a)}-${short(b)}';
  }

  int? _orderForSlot(BcbPartnerScheduleDay day, BcbPartnerScheduleSlot slot) {
    final k = '${day.id}_${slot.id}';
    for (var i = 0; i < _selectionOrder.length; i++) {
      if (_selectionOrder[i].key == k) return i + 1;
    }
    return null;
  }

  void _onSlotTap(BcbPartnerScheduleDay day, BcbPartnerScheduleSlot slot) {
    final sel = _SelectedWishSlot(day: day, slot: slot);
    final existing = _selectionOrder.indexWhere((e) => e.key == sel.key);
    if (existing >= 0) {
      setState(() => _selectionOrder.removeAt(existing));
      return;
    }
    if (_selectionOrder.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(R.string.bcb_max_3_wish_slots.tr()),
        ),
      );
      return;
    }
    setState(() => _selectionOrder.add(sel));
  }

  void _confirmRegistration() {
    if (_selectionOrder.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(R.string.ban_chua_chon_khung_gio.tr()),
        ),
      );
      return;
    }

    final slotIds = _selectionOrder
        .map((s) => s.slot.id ?? '')
        .where((id) => id.isNotEmpty)
        .toList();
    if (slotIds.isEmpty || slotIds.length != _selectionOrder.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(R.string.bcb_slot_id_missing.tr()),
        ),
      );
      return;
    }

    _bloc.add(SubmitBcbRegistrationEvent(
      bcbCampaignId: widget.bcbCampaignId,
      doctorNote: widget.doctorNote,
      medicalHistory: widget.medicalHistory,
      slotIds: slotIds,
    ));
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
    final primary = R.color.greenGradientBottom;

    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: R.color.backgroundColorNew,
        body: Column(
          children: [
            _buildCustomAppBar(),
            Expanded(
              child: BlocConsumer<BcbCampaignBloc, BcbCampaignState>(
                listener: (context, state) {
                  if (state is BcbCampaignLoading) {
                    BotToast.showLoading();
                  } else {
                    BotToast.closeAllLoading();
                  }
                  if (state is BcbRegistrationSubmitted) {
                    _runAfterBuild(_showSuccessAndGoHome);
                  } else if (state is BcbCampaignError) {
                    _runAfterBuild(() {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: const Color(0xffEF4444),
                        ),
                      );
                    });
                  }
                },
                builder: (context, state) {
                  final submitting = state is BcbCampaignLoading;
                  final canSubmit = _selectionOrder.isNotEmpty && !submitting;

                  if (_days.isEmpty || _selectedDay == null) {
                    return Center(
                      child: Text(
                        R.string.bcb_no_schedule_available.tr(),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  final daySlots = _slotsForPeriod(_selectedDay!, _morning);

                  return Stack(
                    children: [
                      SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
                        child: Container(
                          decoration: BoxDecoration(
                            color: R.color.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: R.color.color0xff111515
                                    .withValues(alpha: 0.06),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 16, 16, 8),
                                child: Text(
                                  R.string.pick_date.tr(),
                                  style: TextStyle(
                                    fontSize: 36 / 2,
                                    fontWeight: FontWeight.w700,
                                    color: R.color.color0xff111515,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 76,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  itemCount: _days.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(width: 8),
                                  itemBuilder: (context, index) {
                                    final d = _days[index];
                                    final dt = d.examDateLocal!;
                                    final selected = d.id == _selectedDay!.id;
                                    final wd = DateUtil.weekDayToString(dt);
                                    final ds = DateFormat('dd/MM').format(dt);
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedDay = d;
                                          _morning = _defaultMorningForDay(d);
                                        });
                                      },
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        width: 72,
                                        decoration: BoxDecoration(
                                          color: R.color.white,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                            color: selected
                                                ? primary
                                                : const Color(0xffE5E7EB),
                                            width: selected ? 2 : 1,
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              wd,
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w400,
                                                color: selected
                                                    ? primary
                                                    : R.color.color0xff111515,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              ds,
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: selected
                                                    ? primary
                                                    : R.color.color0xff111515,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 20, 16, 8),
                                child: Text(
                                  R.string.select_hour.tr(),
                                  style: TextStyle(
                                    fontSize: 36 / 2,
                                    fontWeight: FontWeight.w700,
                                    color: R.color.color0xff111515,
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Container(
                                  height: 43,
                                  decoration: BoxDecoration(
                                    color: R.color.color0xffEDEEEE,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: _PeriodChip(
                                          label: R.string.the_morning.tr(),
                                          selected: _morning,
                                          primary: primary,
                                          onTap: () =>
                                              setState(() => _morning = true),
                                        ),
                                      ),
                                      Expanded(
                                        child: _PeriodChip(
                                          label: R.string.the_afternoon.tr(),
                                          selected: !_morning,
                                          primary: primary,
                                          onTap: () =>
                                              setState(() => _morning = false),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              daySlots.isEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          16, 0, 16, 16),
                                      child: Text(
                                        _morning
                                            ? R.string.bcb_no_slots_morning.tr()
                                            : R.string.bcb_no_slots_afternoon.tr(),
                                        style: TextStyle(
                                          color: R.color.color0xff111515
                                              .withValues(alpha: 0.7),
                                        ),
                                      ),
                                    )
                                  : GridView.builder(
                                      padding: const EdgeInsets.fromLTRB(
                                          16, 0, 16, 16),
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        mainAxisSpacing: 10,
                                        crossAxisSpacing: 10,
                                        childAspectRatio: 2.4,
                                      ),
                                      itemCount: daySlots.length,
                                      itemBuilder: (context, i) {
                                        final slot = daySlots[i];
                                        final order =
                                            _orderForSlot(_selectedDay!, slot);
                                        final isOn = order != null;
                                        return GestureDetector(
                                          onTap: () =>
                                              _onSlotTap(_selectedDay!, slot),
                                          child: Stack(
                                            clipBehavior: Clip.none,
                                            children: [
                                              Container(
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  color: R.color.white,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  border: Border.all(
                                                    color: isOn
                                                        ? primary
                                                        : const Color(
                                                            0xffE5E7EB),
                                                    width: isOn ? 2 : 1,
                                                  ),
                                                ),
                                                child: Text(
                                                  _slotLabel(
                                                      _selectedDay!, slot),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: isOn
                                                        ? FontWeight.w700
                                                        : FontWeight.w400,
                                                    color: isOn
                                                        ? primary
                                                        : R.color
                                                            .color0xff111515,
                                                  ),
                                                ),
                                              ),
                                              if (isOn)
                                                Positioned(
                                                  right: -4,
                                                  top: -4,
                                                  child: CircleAvatar(
                                                    radius: 10,
                                                    backgroundColor: primary,
                                                    child: Text(
                                                      '$order',
                                                      style: TextStyle(
                                                        color: R.color.white,
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        );
                                      },
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
                                onTap: canSubmit ? _confirmRegistration : null,
                                borderRadius: BorderRadius.circular(200),
                                child: Ink(
                                  height: 44,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(200),
                                    gradient: canSubmit
                                        ? LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              R.color.greenGradientTop02,
                                              R.color.greenGradientBottom,
                                            ],
                                          )
                                        : null,
                                    color: canSubmit
                                        ? null
                                        : R.color.color0xffEDEEEE,
                                  ),
                                  child: Center(
                                    child: Text(
                                      R.string.sign_up.tr(),
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return SizedBox(
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
            R.string.pick_time.tr(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xffFFFFFF),
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

class _PeriodChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color primary;
  final VoidCallback onTap;

  const _PeriodChip({
    Key? key,
    required this.label,
    required this.selected,
    required this.primary,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 35,
        alignment: Alignment.center,
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: selected ? R.color.white : R.color.color0xffEDEEEE,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? primary : R.color.color0xff111515,
          ),
        ),
      ),
    );
  }
}
