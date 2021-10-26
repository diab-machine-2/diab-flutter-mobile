import 'package:medical/src/utils/const.dart';

class SectionStatusData {
  SectionStatusData({
    required this.type,
    this.isScrollToEnd = false,
    this.isAudioCompleted,
    this.isVideoCompleted,
  });
  int? type;
  bool? isScrollToEnd;
  bool? isVideoCompleted;
  bool? isAudioCompleted;

  bool get isSectionCompleted {
    if (type == Const.LESSON_SECTION_TYPE_TEXT) return isScrollToEnd != false;
    if (type == Const.LESSON_SECTION_TYPE_VIDEO) return isScrollToEnd != false && isVideoCompleted == true;
    if (type == Const.LESSON_SECTION_TYPE_AUDIO) return isScrollToEnd != false && isAudioCompleted == true;
    return false;
  }
}
