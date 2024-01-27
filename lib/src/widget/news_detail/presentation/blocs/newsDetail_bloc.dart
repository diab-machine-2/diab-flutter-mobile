import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:medical/src/modal/error/failures.dart';
import 'package:medical/src/modal/learning/learning_post_model.dart';
import 'package:medical/src/widget/news_detail/data/newDetail_repository.dart';
part 'newsDetail_bloc_event.dart';
part 'newsDetail_bloc_state.dart';

class NewsDetailBloc extends Bloc<NewsDetailEvent, NewsDetailState> {
  NewsDetailBloc() : super(const NewsDetailState());

  final repository = NewsDetailRepository();

  @override
  Stream<NewsDetailState> mapEventToState(NewsDetailEvent event) async* {
    yield state.copyWith(blocStatus: BlocStatus.loading);

    if (event is EventGetNewsDetail) {
      yield* _mapEventGetNewsDetail(event);
    }
  }

  Stream<NewsDetailState> _mapEventGetNewsDetail(
      EventGetNewsDetail event) async* {
    try {
      Either<Failure, LearningPostModel> failureOrNewsDetail =
          await repository.getNewsDetaill(event.newsId);

      yield failureOrNewsDetail.fold(
        (failure) => state.copyWith(
          newsList: [],
          blocStatus: BlocStatus.error,
          blocMessage: failure.message,
        ),
        (newsDetail) => state.copyWith(
          newsDetail: newsDetail,
          blocStatus: BlocStatus.success,
        ),
      );
    } catch (e) {
      yield state.copyWith(
        blocStatus: BlocStatus.error,
        blocMessage: e.toString(),
      );
    }
  }
}
