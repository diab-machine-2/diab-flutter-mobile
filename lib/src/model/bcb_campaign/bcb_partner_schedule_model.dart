class BcbPartnerScheduleSlot {
  final String? id;
  final String? scheduleDayId;
  final String? examDate;
  final String? startTime;
  final String? endTime;
  final int? maxCapacity;
  final int? bookedCount;
  final bool isFull;
  final bool isActive;

  BcbPartnerScheduleSlot({
    this.id,
    this.scheduleDayId,
    this.examDate,
    this.startTime,
    this.endTime,
    this.maxCapacity,
    this.bookedCount,
    this.isFull = false,
    this.isActive = false,
  });

  factory BcbPartnerScheduleSlot.fromJson(Map<String, dynamic> json) {
    return BcbPartnerScheduleSlot(
      id: (json['slotId'] ?? json['id']) as String?,
      scheduleDayId: json['scheduleDayId'] as String?,
      examDate: json['examDate']?.toString(),
      startTime: json['startTime']?.toString(),
      endTime: json['endTime']?.toString(),
      maxCapacity: json['maxCapacity'] as int?,
      bookedCount: json['bookedCount'] as int?,
      isFull: json['isFull'] == true,
      isActive: json['isActive'] == true,
    );
  }
}

class BcbPartnerScheduleDay {
  final String? id;
  final String? campaignId;
  final int? examDateUnix;
  final int? maxPerDay;
  final int? bookedCount;
  final bool isActive;
  final String? partnerName;
  final String? partnerAddress;
  final String? partnerHotline;
  final List<BcbPartnerScheduleSlot> slots;

  BcbPartnerScheduleDay({
    this.id,
    this.campaignId,
    this.examDateUnix,
    this.maxPerDay,
    this.bookedCount,
    this.isActive = false,
    this.partnerName,
    this.partnerAddress,
    this.partnerHotline,
    this.slots = const [],
  });

  factory BcbPartnerScheduleDay.fromJson(Map<String, dynamic> json) {
    final rawSlots = json['slots'];
    return BcbPartnerScheduleDay(
      id: json['id'] as String?,
      campaignId: json['campaignId'] as String?,
      examDateUnix: _parseUnix(json['examDate']),
      maxPerDay: json['maxPerDay'] as int?,
      bookedCount: json['bookedCount'] as int?,
      isActive: json['isActive'] == true,
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

  static int? _parseUnix(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  /// Exam instant in local timezone (Unix seconds or milliseconds).
  DateTime? get examDateLocal {
    final u = examDateUnix;
    if (u == null) return null;
    if (u > 20000000000) {
      return DateTime.fromMillisecondsSinceEpoch(u, isUtc: true).toLocal();
    }
    return DateTime.fromMillisecondsSinceEpoch(u * 1000, isUtc: true).toLocal();
  }

  static List<BcbPartnerScheduleDay> listFrom(dynamic raw) {
    if (raw is! List) return [];
    return raw
        .map((e) => BcbPartnerScheduleDay.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
