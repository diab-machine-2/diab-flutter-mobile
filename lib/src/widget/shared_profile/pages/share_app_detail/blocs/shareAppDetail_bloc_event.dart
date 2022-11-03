part of 'shareAppDetail_bloc.dart';

abstract class ShareAppDetailEvent {
  const ShareAppDetailEvent();
}

class CheckVoucherAvailable extends ShareAppDetailEvent {
  const CheckVoucherAvailable();

  List<Object> get props => [];
}
