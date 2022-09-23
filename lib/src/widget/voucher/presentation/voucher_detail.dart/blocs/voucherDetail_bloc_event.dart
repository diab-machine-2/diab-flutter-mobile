part of 'voucherDetail_bloc.dart';

abstract class VoucherDetailEvent {
  const VoucherDetailEvent();
}

class EventGetVoucherDetail extends VoucherDetailEvent {
  final String voucherId;
  const EventGetVoucherDetail(this.voucherId);

  List<Object> get props => [];
}

class SubmitUseVoucher extends VoucherDetailEvent {
  const SubmitUseVoucher();

  List<Object> get props => [];
}
