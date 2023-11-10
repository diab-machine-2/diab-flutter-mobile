import 'package:flutter/material.dart';
import 'package:loadmore/loadmore.dart';

class LoadmoreTemplate extends StatelessWidget {
  final Function onLoadMore;
  final Function onRefresh;
  final bool isFinish;
  final Widget child;
  const LoadmoreTemplate({
    Key? key,
    required this.onLoadMore,
    required this.isFinish,
    required this.child,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LoadMore(
      whenEmptyLoad: true,
      isFinish: isFinish,
      delegate: const DefaultLoadMoreDelegate(),
      textBuilder: _buildLoadMoreText,
      onLoadMore: () async {
        await onLoadMore();
        return true;
      },
      child: child,
    );
  }

  String _buildLoadMoreText(LoadMoreStatus status) {
    switch (status) {
      case LoadMoreStatus.idle:
        return '';
      case LoadMoreStatus.loading:
        return '';
      case LoadMoreStatus.fail:
        return '';
      case LoadMoreStatus.nomore:
        return '';
    }
  }
}
