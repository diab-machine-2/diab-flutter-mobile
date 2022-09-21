part of 'voucherList_bloc.dart';

abstract class VoucherListEvent {
  const VoucherListEvent();
}

class EventGetVoucherList extends VoucherListEvent {
  const EventGetVoucherList();

  List<Object> get props => [];
}
