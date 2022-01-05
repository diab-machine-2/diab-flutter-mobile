class SectionStatusData {
  SectionStatusData({
    required this.hasVideo,
    required this.hasAudio,
  });
  final bool hasVideo;
  final bool hasAudio;
  bool? isVideoCompleted;
  bool? isAudioCompleted;

  bool get isSectionCompleted {
    if (hasVideo && isVideoCompleted != true) return false;
    if (hasAudio && isAudioCompleted != true) return false;
    return true;
  }
}
