import 'package:flutter/foundation.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

/// Extracts a direct playable stream URL from a YouTube link.
///
/// Shared by the lesson and exercise video players (previously duplicated
/// verbatim in both). Extraction logic/behavior is unchanged from before:
/// only the Android client is used (YoutubeApiClient.ios returns HLS/m3u8,
/// which the current BetterPlayer setup can't reliably play), muxed streams
/// are preferred, falling back to the highest-bitrate video stream otherwise.
///
/// The only behavior change is that a failure is now reported to Crashlytics
/// (non-fatal) with the real exception, instead of being swallowed into a
/// generic "failed to extract" message with no visibility into the cause
/// (403, timeout, decipher failure, bot-check, ...).
class YoutubeVideoExtractor {
  static final RegExp _youtubeRegex = RegExp(
    r'^(https?:\/\/)?(www\.)?(youtube\.com|youtu\.be)\/',
    caseSensitive: false,
  );

  static bool isYoutubeLink(String? url) {
    if (url == null || url.isEmpty) return false;
    return _youtubeRegex.hasMatch(url);
  }

  static Future<String?> getMp4Url(String youtubeUrl, {String tag = 'VIDEO'}) async {
    final yt = YoutubeExplode();
    try {
      debugPrint('[$tag] Processing YouTube URL: $youtubeUrl');

      final videoId = VideoId.parseVideoId(youtubeUrl);
      if (videoId == null) {
        debugPrint('[$tag] Invalid YouTube URL: $youtubeUrl');
        return null;
      }

      // YoutubeApiClient.ios is getting m3u8 streams -> cannot open with current player
      final streamManifest = await yt.videos.streamsClient
          .getManifest(videoId, ytClients: [YoutubeApiClient.android]);

      // Priority 1: Muxed MP4 streams (contain both video and audio)
      final muxedStreams = streamManifest.muxed.toList();

      if (muxedStreams.isNotEmpty) {
        final selectedStream = muxedStreams.first;
        debugPrint(
            '[$tag] Selected muxed MP4 stream: ${selectedStream.qualityLabel}, Size: ${selectedStream.size}');
        return selectedStream.url.toString();
      } else {
        debugPrint('[$tag] No suitable streams found with video and audio');
        debugPrint('[$tag] Available stream types:');
        debugPrint(
            '[$tag] - HLS streams: ${streamManifest.streams.whereType<HlsVideoStreamInfo>().length}');
        debugPrint(
            '[$tag] - Muxed streams: ${streamManifest.streams.whereType<MuxedStreamInfo>().length}');
        debugPrint('[$tag] - Video-only streams: ${streamManifest.videoOnly.length}');
        debugPrint('[$tag] - Audio-only streams: ${streamManifest.audioOnly.length}');
        final videoStream = streamManifest.video.withHighestBitrate();
        debugPrint(
            '[$tag] Selected video stream: ${videoStream.qualityLabel}, Size: ${videoStream.size}');
        return videoStream.url.toString();
      }
    } catch (e, s) {
      debugPrint('[$tag] Error extracting stream URL: $e');
      try {
        await TrackingManager.logError(
            '[$tag] YouTube extraction failed for $youtubeUrl: $e');
        await TrackingManager.recordError(e, s, fatal: false);
      } catch (loggingError) {
        // Never let a logging failure (e.g. Crashlytics not initialized) mask
        // the real extraction failure above.
        debugPrint('[$tag] Failed to report extraction failure: $loggingError');
      }
      return null;
    } finally {
      yt.close();
    }
  }
}
