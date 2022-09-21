part of 'voucherDetail_bloc.dart';

abstract class VoucherDetailEvent {
  const VoucherDetailEvent();
}

class EventGetVoucherDetail extends VoucherDetailEvent {
  const EventGetVoucherDetail();

  List<Object> get props => [];
}

class SubmitUserVoucher extends VoucherDetailEvent {
  const SubmitUserVoucher();

  List<Object> get props => [];
}
