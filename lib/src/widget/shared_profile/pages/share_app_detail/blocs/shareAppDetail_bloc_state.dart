part of 'shareAppDetail_bloc.dart';

class ShareAppDetailState {
  final String blocMessage;
  final BlocStatus blocStatus;
  final bool? isVoucherAvailable;

  const ShareAppDetailState({
    this.blocStatus = BlocStatus.initial,
    this.blocMessage = "",
    this.isVoucherAvailable,
  });

  ShareAppDetailState copyWith({
    BlocStatus blocStatus = BlocStatus.initial,
    String? blocMessage,
    bool? isVoucherAvailable,
  }) {
    return ShareAppDetailState(
      blocStatus: blocStatus,
      blocMessage: blocMessage ?? this.blocMessage,
      isVoucherAvailable: isVoucherAvailable ?? this.isVoucherAvailable,
    );
  }

  List<Object> get props => [
        blocStatus,
        blocMessage,
      ];
}

enum BlocStatus {
  initial,
  error,
  loading,
  getVoucherSucess,
  success,
}
