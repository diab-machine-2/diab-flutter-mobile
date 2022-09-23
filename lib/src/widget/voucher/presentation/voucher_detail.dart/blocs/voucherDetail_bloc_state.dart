part of 'voucherDetail_bloc.dart';

class VoucherDetailState {
  final String blocMessage;
  final BlocStatus blocStatus;
  final VoucherModel? voucherDetail;

  const VoucherDetailState({
    this.blocStatus = BlocStatus.initial,
    this.blocMessage = "",
    this.voucherDetail,
  });

  VoucherDetailState copyWith({
    BlocStatus blocStatus = BlocStatus.initial,
    VoucherModel? voucherDetail,
    int? expireDuration,
    String? blocMessage,
  }) {
    return VoucherDetailState(
      blocStatus: blocStatus,
      voucherDetail: voucherDetail ?? this.voucherDetail,
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
