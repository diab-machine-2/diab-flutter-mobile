class SectionStatusData {
  SectionStatusData({
    required this.hasVideo,
    required this.hasAudio,
  required this.isQuizSection,
  });
  final bool hasVideo;
  final bool hasAudio;
  bool? isVideoCompleted;
  bool? isAudioCompleted;
  bool? isQuizSection;

  bool get isSectionCompleted {
    if (isQuizSection == true) return false;
    if (hasVideo && isVideoCompleted != true) return false;
    if (hasAudio && isAudioCompleted != true) return false;
    return true;
  }
}
