import 'package:equatable/equatable.dart';
import 'package:flutter_zoom_videosdk/native/zoom_videosdk_user.dart';

abstract class MeetingState extends Equatable {
  const MeetingState();

  @override
  List<Object> get props => [];
}

class MeetingJoining extends MeetingState {
  @override
  String toString() => 'MeetingJoining';
}

class MeetingJoined extends MeetingState {
  final ZoomVideoSdkUser? thisUser;
  final ZoomVideoSdkUser? previewUser;
  final ZoomVideoSdkUser? fullscreenUser;
  final List<ZoomVideoSdkUser> remoteUsers;

  MeetingJoined({
    this.thisUser,
    this.previewUser,
    required this.fullscreenUser,
    this.remoteUsers = const [],
  });

  @override
  String toString() => 'MeetingJoined';

  MeetingJoined copyWith({
    ZoomVideoSdkUser? thisUser,
    ZoomVideoSdkUser? previewUser,
    ZoomVideoSdkUser? fullscreenUser,
    List<ZoomVideoSdkUser>? remoteUsers,
  }) {
    return MeetingJoined(
      thisUser: thisUser ?? this.thisUser,
      previewUser: previewUser ?? this.previewUser,
      fullscreenUser: fullscreenUser ?? this.fullscreenUser,
      remoteUsers: remoteUsers ?? this.remoteUsers,
    );
  }

  @override
  List<Object> get props => [
        if (thisUser != null) thisUser!,
        if (previewUser != null) previewUser!,
        if (fullscreenUser != null) fullscreenUser!,
        remoteUsers,
      ];
}

class MeetingLeaving extends MeetingState {
  @override
  String toString() => 'MeetingLeaving';
}

class MeetingJoinError extends MeetingState {
  const MeetingJoinError({message = 'error_unexpected_error'}) : message = message;

  final String message;

  @override
  String toString() => message;
}
