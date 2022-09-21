part of 'voucherList_bloc.dart';

class VoucherListState {
  final String blocMessage;
  final BlocStatus blocStatus;
  final List<dynamic>? newsList;

  const VoucherListState({
    this.blocStatus = BlocStatus.initial,
    this.blocMessage = "",
    this.newsList,
  });

  VoucherListState copyWith({
    BlocStatus blocStatus = BlocStatus.initial,
    List<dynamic>? newsList,
    int? expireDuration,
    String? blocMessage,
  }) {
    return VoucherListState(
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
  success,
}
