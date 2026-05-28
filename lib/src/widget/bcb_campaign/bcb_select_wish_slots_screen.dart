import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/bcb_campaign/bcb_partner_schedule_model.dart';
import 'package:medical/src/model/bcb_campaign/bcb_selected_wish_slot.dart';
import 'package:medical/src/repo/bcb_campaign/bcb_campaign_client.dart';
import 'package:medical/src/utils/date_utils.dart';
import 'package:medical/src/widget/bcb_campaign/bcb_campaign_confirmation_screen.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';

/// Chọn 1 khung giờ khám mong muốn (theo lịch partner), rồi xác nhận đăng ký.
class BcbSelectWishSlotsScreen extends StatefulWidget {
  final String bcbCampaignId;
  final String? bcbCampaignName;
  final List<BcbPartnerScheduleDay>? scheduleDays;
  final BcbSelectedWishSlot? selectedWishSlot;
  final String? initialDoctorNote;

  const BcbSelectWishSlotsScreen({
    Key? key,
    required this.bcbCampaignId,
    this.bcbCampaignName,
    this.scheduleDays,
    this.selectedWishSlot,
    this.initialDoctorNote,
  }) : super(key: key);

  @override
  State<BcbSelectWishSlotsScreen> createState() =>
      _BcbSelectWishSlotsScreenState();
}

class _BcbSelectWishSlotsScreenState extends State<BcbSelectWishSlotsScreen> {
  List<BcbPartnerScheduleDay> _days = [];

  BcbPartnerScheduleDay? _selectedDay;
  bool _morning = true;
  BcbSelectedWishSlot? _selectedWishSlot;
  bool _loadingSchedule = false;

  @override
  void initState() {
    super.initState();
    _selectedWishSlot = widget.selectedWishSlot;
    if (widget.scheduleDays != null && widget.scheduleDays!.isNotEmpty) {
      _applySchedule(widget.scheduleDays!, preserveSelection: true);
    }
    _fetchScheduleDays();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _fetchScheduleDays() async {
    setState(() => _loadingSchedule = true);
    try {
      final client = BcbCampaignClient();
      final days = await client.fetchPartnerScheduleDays(widget.bcbCampaignId);
      if (!mounted) return;
      _applySchedule(days, preserveSelection: true);
      if (days.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(R.string.bcb_no_schedule_available.tr()),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _loadingSchedule = false);
    }
  }

  void _applySchedule(List<BcbPartnerScheduleDay> list,
      {bool preserveSelection = false}) {
    // final activeDays = list
    //     .where((d) =>
    //         d.isActive &&
    //         d.examDateLocal != null &&
    //         d.slots.any((s) => s.isActive && !s.isFull))
    //     .toList();
    final activeDays = list;
    activeDays
        .sort((a, b) => (a.examDateUnix ?? 0).compareTo(b.examDateUnix ?? 0));
    final selected =
        preserveSelection ? _findSelectionInDays(activeDays) : null;
    final selectedDay =
        selected?.day ?? (activeDays.isNotEmpty ? activeDays.first : null);
    setState(() {
      _days = activeDays;
      _selectedDay = selectedDay;
      _morning = selected == null
          ? _defaultMorningForDay(_selectedDay)
          : _isMorningSlot(selected.day, selected.slot);
      _selectedWishSlot = selected;
    });
  }

  BcbSelectedWishSlot? _findSelectionInDays(List<BcbPartnerScheduleDay> days) {
    final current = _selectedWishSlot;
    if (current == null) return null;
    for (final day in days) {
      for (final slot in day.slots) {
        if ('${day.id}_${slot.id}' == current.key) {
          return BcbSelectedWishSlot(day: day, slot: slot);
        }
      }
    }
    return current;
  }

  bool _defaultMorningForDay(BcbPartnerScheduleDay? day) {
    if (day == null) return true;
    final morningSlots = _slotsForPeriod(day, true);
    final afternoonSlots = _slotsForPeriod(day, false);
    if (morningSlots.isNotEmpty) return true;
    if (afternoonSlots.isNotEmpty) return false;
    return true;
  }

  bool _isMorningSlot(BcbPartnerScheduleDay day, BcbPartnerScheduleSlot slot) {
    if (slot.startTime == null) return true;
    final time = _parseTimeOnDay(day, slot.startTime!);
    return time == null || time.hour < 12;
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

  bool _isSelectedSlot(BcbPartnerScheduleDay day, BcbPartnerScheduleSlot slot) {
    final k = '${day.id}_${slot.id}';
    return _selectedWishSlot?.key == k;
  }

  void _onSlotTap(BcbPartnerScheduleDay day, BcbPartnerScheduleSlot slot) {
    final sel = BcbSelectedWishSlot(day: day, slot: slot);
    if (_selectedWishSlot?.key == sel.key) {
      setState(() => _selectedWishSlot = null);
      return;
    }
    setState(() => _selectedWishSlot = sel);
  }

  void _confirmRegistration() {
    final selected = _selectedWishSlot;
    if (selected == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(R.string.ban_chua_chon_khung_gio.tr()),
        ),
      );
      return;
    }

    final slotId = selected.slot.id ?? '';
    if (slotId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(R.string.bcb_slot_id_missing.tr()),
        ),
      );
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => BcbCampaignConfirmationScreen(
          bcbCampaignId: widget.bcbCampaignId,
          bcbCampaignName: widget.bcbCampaignName,
          scheduleDays: _days,
          selectedWishSlot: selected,
          initialDoctorNote: widget.initialDoctorNote,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = R.color.greenGradientBottom;

    final canSubmit = _selectedWishSlot != null && !_loadingSchedule;

    return Scaffold(
      backgroundColor: R.color.backgroundColorNew,
      body: Column(
        children: [
          _buildCustomAppBar(),
          Expanded(
            child: _days.isEmpty || _selectedDay == null
                ? Center(
                    child: _loadingSchedule
                        ? CircularProgressIndicator(
                            color: R.color.greenGradientBottom,
                          )
                        : Text(
                            R.string.bcb_no_schedule_available.tr(),
                            textAlign: TextAlign.center,
                          ),
                  )
                : Stack(
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
                              _slotsForPeriod(_selectedDay!, _morning).isEmpty
                                  ? Center(
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            16, 0, 16, 16),
                                        child: Text(
                                          _morning
                                              ? R.string.bcb_no_slots_morning
                                                  .tr()
                                              : R.string.bcb_no_slots_afternoon
                                                  .tr(),
                                          style: TextStyle(
                                            color: R.color.color0xff111515
                                                .withValues(alpha: 0.7),
                                          ),
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
                                      itemCount: _slotsForPeriod(
                                              _selectedDay!, _morning)
                                          .length,
                                      itemBuilder: (context, i) {
                                        final slot = _slotsForPeriod(
                                            _selectedDay!, _morning)[i];
                                        final isOn = _isSelectedSlot(
                                            _selectedDay!, slot);
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
                                                    child: Icon(
                                                      Icons.check,
                                                      color: R.color.white,
                                                      size: 14,
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
