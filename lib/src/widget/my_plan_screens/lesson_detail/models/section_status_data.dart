import 'package:medical/src/utils/const.dart';

class SectionStatusData {
  SectionStatusData({
    required this.type,
    this.isAudioCompleted,
    this.isVideoCompleted,
  });
  int? type;
  bool? isVideoCompleted;
  bool? isAudioCompleted;

  bool get isSectionCompleted {
    if (type == Const.LESSON_SECTION_TYPE_TEXT) return true;
    if (type == Const.LESSON_SECTION_TYPE_VIDEO)
      return isVideoCompleted == true;
    if (type == Const.LESSON_SECTION_TYPE_AUDIO)
      return isAudioCompleted == true;
    return false;
  }
}
