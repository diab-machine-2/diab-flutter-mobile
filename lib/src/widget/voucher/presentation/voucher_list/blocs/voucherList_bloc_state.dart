part of 'voucherList_bloc.dart';

class VoucherListState {
  final String blocMessage;
  final BlocStatus blocStatus;
  final List<VoucherModel>? voucherList;

  const VoucherListState({
    this.blocStatus = BlocStatus.initial,
    this.blocMessage = "",
    this.voucherList,
  });

  VoucherListState copyWith({
    BlocStatus blocStatus = BlocStatus.initial,
    List<VoucherModel>? voucherList,
    int? expireDuration,
    String? blocMessage,
  }) {
    return VoucherListState(
      blocStatus: blocStatus,
      voucherList: voucherList ?? this.voucherList,
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
  getVoucherListSuccess,
  refreshVoucherListSuccess,
}
