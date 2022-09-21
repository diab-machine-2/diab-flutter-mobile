import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:medical/src/modal/error/failures.dart';
part 'voucherDetail_bloc_event.dart';
part 'voucherDetail_bloc_state.dart';

class VoucherDetailBloc extends Bloc<VoucherDetailEvent, VoucherDetailState> {
  VoucherDetailBloc() : super(const VoucherDetailState());

  @override
  Stream<VoucherDetailState> mapEventToState(VoucherDetailEvent event) async* {
    yield state.copyWith(blocStatus: BlocStatus.loading);
    if (event is EventGetVoucherDetail) {
      yield* _mapEventGetVoucherDetail(event);
    } else if (event is SubmitUserVoucher) {
      yield* _mapSubmitUserVoucher(event);
    }
  }

  Stream<VoucherDetailState> _mapEventGetVoucherDetail(
      EventGetVoucherDetail event) async* {
    try {
      // Either<Failure, LearningPostModel> failureOrNewsDetail =
      //     await repository.getNewsDetaill(event.newsId);

      // yield failureOrNewsDetail.fold(
      //   (failure) => state.copyWith(
      //     newsList: [],
      //     blocStatus: BlocStatus.error,
      //     blocMessage: failure.message,
      //   ),
      //   (newsDetail) => state.copyWith(
      //     newsDetail: newsDetail,
      //     blocStatus: BlocStatus.getVoucherSucesss,
      //   ),
      // );
    } catch (e) {
      yield state.copyWith(
        blocStatus: BlocStatus.error,
        blocMessage: e.toString(),
      );
    }
  }

  Stream<VoucherDetailState> _mapSubmitUserVoucher(
      SubmitUserVoucher event) async* {
    try {
      yield state.copyWith(
        blocStatus: BlocStatus.useVoucherSuccess,
      );
    } catch (e) {
      yield state.copyWith(
        blocStatus: BlocStatus.error,
        blocMessage: e.toString(),
      );
    }
  }
}
