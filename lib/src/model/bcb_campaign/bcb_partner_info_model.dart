import 'package:medical/src/model/bcb_campaign/bcb_partner_schedule_model.dart';

class BcbPartnerInfo {
  final String? partnerId;
  final String? partnerName;
  final String? partnerAddress;
  final String? partnerHotline;
  final List<BcbPartnerScheduleSlot> slots;

  const BcbPartnerInfo({
    this.partnerId,
    this.partnerName,
    this.partnerAddress,
    this.partnerHotline,
    this.slots = const [],
  });

  factory BcbPartnerInfo.fromJson(Map<String, dynamic> json) {
    final rawSlots = json['slots'];
    return BcbPartnerInfo(
      partnerId: json['partnerId'] as String?,
      partnerName: json['partnerName']?.toString(),
      partnerAddress: json['partnerAddress']?.toString(),
      partnerHotline: json['partnerHotline']?.toString(),
      slots: rawSlots is List
          ? rawSlots
              .map((e) =>
                  BcbPartnerScheduleSlot.fromJson(e as Map<String, dynamic>))
              .toList()
          : const [],
    );
  }

  static List<BcbPartnerInfo> listFrom(dynamic raw) {
    if (raw is! List) return [];
    return raw
        .map((e) => BcbPartnerInfo.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Groups slots by scheduleDayId to produce BcbPartnerScheduleDay entries
  /// compatible with BcbSelectWishSlotsScreen.
  List<BcbPartnerScheduleDay> toScheduleDays() {
    final Map<String, List<BcbPartnerScheduleSlot>> byDay = {};
    for (final slot in slots) {
      final key = slot.scheduleDayId ?? slot.examDate ?? '';
      byDay.putIfAbsent(key, () => []).add(slot);
    }
    return byDay.entries.map((e) {
      final daySlots = e.value;
      final firstSlot = daySlots.first;
      int? examDateUnix;
      final examDate = firstSlot.examDate;
      if (examDate != null) {
        try {
          final timestamp = int.tryParse(examDate);
          if (timestamp != null) {
            examDateUnix = timestamp;
          }
        } catch (_) {}
      }
      return BcbPartnerScheduleDay(
        id: firstSlot.scheduleDayId,
        campaignId: null,
        examDateUnix: examDateUnix,
        partnerName: partnerName,
        partnerAddress: partnerAddress,
        partnerHotline: partnerHotline,
        slots: daySlots,
      );
    }).toList();
  }
}
