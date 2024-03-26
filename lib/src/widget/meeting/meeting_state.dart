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
  final ZoomVideoSdkUser fullscreenUser;
  final List<ZoomVideoSdkUser> remoteUsers;
  final bool isUserVideoOn;

  MeetingJoined({
    this.thisUser,
    required this.fullscreenUser,
    this.remoteUsers = const [],
    this.isUserVideoOn = false,
  });

  @override
  String toString() => 'MeetingJoined';

  MeetingJoined copyWith({
    ZoomVideoSdkUser? thisUser,
    ZoomVideoSdkUser? fullscreenUser,
    List<ZoomVideoSdkUser>? remoteUsers,
    bool? isUserVideoOn,
  }) {
    return MeetingJoined(
      thisUser: thisUser ?? this.thisUser,
      fullscreenUser: fullscreenUser ?? this.fullscreenUser,
      remoteUsers: remoteUsers ?? this.remoteUsers,
      isUserVideoOn: isUserVideoOn ?? this.isUserVideoOn,
    );
  }

  @override
  List<Object> get props => [if (thisUser != null) thisUser!, fullscreenUser, remoteUsers, isUserVideoOn];
}

class MeetingLeaving extends MeetingState {
  @override
  String toString() => 'MeetingLeaving';
}

class MeetingJoinError extends MeetingState {
  @override
  String toString() => 'MeetingJoinError';
}
