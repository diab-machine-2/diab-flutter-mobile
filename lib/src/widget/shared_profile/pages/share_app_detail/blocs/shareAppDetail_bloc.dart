import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/error/failures.dart';
import 'package:medical/src/widget/voucher/data/voucher_repository.dart';
part 'shareAppDetail_bloc_event.dart';
part 'shareAppDetail_bloc_state.dart';

class ShareAppDetailBloc extends Bloc<ShareAppDetailEvent, ShareAppDetailState> {
  ShareAppDetailBloc() : super(const ShareAppDetailState());

  final repository = VoucherRepository();

  @override
  Stream<ShareAppDetailState> mapEventToState(ShareAppDetailEvent event) async* {
    yield state.copyWith(blocStatus: BlocStatus.loading);
    if (event is CheckVoucherAvailable) {
      yield* _mapCheckVoucherAvailable(event);
    }
  }

  Stream<ShareAppDetailState> _mapCheckVoucherAvailable(
      CheckVoucherAvailable event) async* {
    Either<Failure, bool> failureOrSuccess =
        await repository.checkVoucherAvailable();
        
    yield failureOrSuccess.fold(
      (failure) => state.copyWith(
        blocStatus: BlocStatus.error,
        blocMessage: failure.message,
      ),
      (success) {
        return state.copyWith(
          isVoucherAvailable: success,
          blocMessage: success == true ? null : R.string.error.tr(),
        );
      },
    );
  }
}
