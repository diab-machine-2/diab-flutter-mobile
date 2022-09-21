import 'dart:async';
import 'package:bloc/bloc.dart';
part 'voucherList_bloc_event.dart';
part 'voucherList_bloc_state.dart';

class VoucherListBloc extends Bloc<VoucherListEvent, VoucherListState> {
  VoucherListBloc() : super(const VoucherListState());

  @override
  Stream<VoucherListState> mapEventToState(VoucherListEvent event) async* {
    yield state.copyWith(blocStatus: BlocStatus.loading);
    if (event is EventGetVoucherList) {
      yield* _mapEventGetVoucherList(event);
    }
  }

  Stream<VoucherListState> _mapEventGetVoucherList(
      EventGetVoucherList event) async* {
    try {} catch (e) {
      yield state.copyWith(
        blocStatus: BlocStatus.error,
        blocMessage: e.toString(),
      );
    }
  }
}
