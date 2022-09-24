import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:medical/src/modal/error/failures.dart';
import '../../../data/models/voucherList_response.dart';
import '../../../data/voucher_repository.dart';
part 'voucherList_bloc_event.dart';
part 'voucherList_bloc_state.dart';

class VoucherListBloc extends Bloc<VoucherListEvent, VoucherListState> {
  VoucherListBloc() : super(const VoucherListState());

  final repository = VoucherRepository();

  @override
  Stream<VoucherListState> mapEventToState(VoucherListEvent event) async* {
    yield state.copyWith(blocStatus: BlocStatus.loading);
    if (event is EventGetVoucherList) {
      yield* _mapEventGetVoucherList(event);
    }
  }

  Stream<VoucherListState> _mapEventGetVoucherList(
      EventGetVoucherList event) async* {
    Either<Failure, VoucherListResponse> failureOrVoucherData =
        await repository.getListVoucher();

    yield failureOrVoucherData.fold(
      (failure) => state.copyWith(
        voucherList: [],
        blocStatus: BlocStatus.error,
        blocMessage: failure.message,
      ),
      (voucherData) => state.copyWith(
        voucherList: voucherData.items,
        blocStatus: event.isReload
            ? BlocStatus.refreshVoucherListSuccess
            : BlocStatus.getVoucherListSuccess,
      ),
    );
  }
}
