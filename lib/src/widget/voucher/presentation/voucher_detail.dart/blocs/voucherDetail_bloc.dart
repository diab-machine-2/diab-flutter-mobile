import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:medical/src/modal/error/failures.dart';
import '../../../data/models/voucherList_response.dart';
import '../../../data/voucher_repository.dart';
part 'voucherDetail_bloc_event.dart';
part 'voucherDetail_bloc_state.dart';

class VoucherDetailBloc extends Bloc<VoucherDetailEvent, VoucherDetailState> {
  VoucherDetailBloc() : super(const VoucherDetailState());

  final repository = VoucherRepository();

  @override
  Stream<VoucherDetailState> mapEventToState(VoucherDetailEvent event) async* {
    yield state.copyWith(blocStatus: BlocStatus.loading);
    if (event is EventGetVoucherDetail) {
      yield* _mapEventGetVoucherDetail(event);
    } else if (event is SubmitUseVoucher) {
      yield* _mapSubmitUseVoucher(event);
    }
  }

  Stream<VoucherDetailState> _mapEventGetVoucherDetail(
      EventGetVoucherDetail event) async* {
    Either<Failure, VoucherModel> failureOrVoucherData =
        await repository.getVoucherDetail(event.voucherId);
    yield failureOrVoucherData.fold(
      (failure) => state.copyWith(
        blocStatus: BlocStatus.error,
        blocMessage: failure.message,
      ),
      (voucherData) => state.copyWith(
        voucherDetail: voucherData,
        blocStatus: BlocStatus.getVoucherSucess,
      ),
    );
  }

  Stream<VoucherDetailState> _mapSubmitUseVoucher(
      SubmitUseVoucher event) async* {
    Either<Failure, bool> failureOrVoucherData =
        await repository.useVoucher(state.voucherDetail!.id);
    yield failureOrVoucherData.fold(
      (failure) => state.copyWith(
        blocStatus: BlocStatus.error,
        blocMessage: failure.message,
      ),
      (result) => state.copyWith(
        blocStatus: BlocStatus.useVoucherSuccess,
      ),
    );
  }
}
