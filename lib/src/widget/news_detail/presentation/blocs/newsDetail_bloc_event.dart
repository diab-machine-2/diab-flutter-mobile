part of 'newsDetail_bloc.dart';

abstract class NewsDetailEvent {
  const NewsDetailEvent();
}

class EventGetNewsDetail extends NewsDetailEvent {
  final String newsId;
  const EventGetNewsDetail({required this.newsId});

  List<Object> get props => [];
}
