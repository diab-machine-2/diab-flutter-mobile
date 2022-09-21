part of 'voucherDetail_bloc.dart';

class VoucherDetailState {
  final String blocMessage;
  final BlocStatus blocStatus;
  final List<dynamic>? newsList;

  const VoucherDetailState({
    this.blocStatus = BlocStatus.initial,
    this.blocMessage = "",
    this.newsList,
  });

  VoucherDetailState copyWith({
    BlocStatus blocStatus = BlocStatus.initial,
    List<dynamic>? newsList,
    int? expireDuration,
    String? blocMessage,
  }) {
    return VoucherDetailState(
      blocStatus: blocStatus,
      newsList: newsList ?? this.newsList,
      blocMessage: blocMessage ?? this.blocMessage,
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
  useVoucherSuccess,
}
