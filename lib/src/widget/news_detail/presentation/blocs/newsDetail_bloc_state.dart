part of 'newsDetail_bloc.dart';

class NewsDetailState {
  final String blocMessage;
  final BlocStatus blocStatus;
  final List<LearningPostModel>? newsList;
  final LearningPostModel? newsDetail;

  const NewsDetailState({
    this.blocStatus = BlocStatus.initial,
    this.blocMessage = "",
    this.newsList,
    this.newsDetail,
  });

  NewsDetailState copyWith({
    BlocStatus blocStatus = BlocStatus.initial,
    List<LearningPostModel>? newsList,
    LearningPostModel? newsDetail,
    int? expireDuration,
    String? blocMessage,
  }) {
    return NewsDetailState(
      blocStatus: blocStatus,
      newsList: newsList ?? this.newsList,
      newsDetail: newsDetail ?? this.newsDetail,
      blocMessage: blocMessage ?? this.blocMessage,
    );
  }

  @override
  List<Object> get props => [
        blocStatus,
        blocMessage,
      ];
}

enum BlocStatus {
  initial,
  error,
  loading,
  success,
}
