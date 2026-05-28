import 'package:medical/src/model/bcb_campaign/bcb_partner_schedule_model.dart';

class BcbSelectedWishSlot {
  final BcbPartnerScheduleDay day;
  final BcbPartnerScheduleSlot slot;

  const BcbSelectedWishSlot({
    required this.day,
    required this.slot,
  });

  String get key => '${day.id}_${slot.id}';
}
