part of 'voucherList_bloc.dart';

abstract class VoucherListEvent {
  const VoucherListEvent();
}

class EventGetVoucherList extends VoucherListEvent {
  final bool isReload;
  const EventGetVoucherList({this.isReload = false});

  List<Object> get props => [];
}
