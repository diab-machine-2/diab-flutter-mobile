import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loadmore/loadmore.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/list_roadmap_response.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widget/components/load_more.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/notice_change/notice_change_page.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:medical/src/widgets/common_page.dart';

import 'select_route.dart';

class SelectRoutePage extends StatefulWidget {
  const SelectRoutePage();

  @override
  _SelectRoutePageState createState() => _SelectRoutePageState();
}

class _SelectRoutePageState extends State<SelectRoutePage> {
  late final SelectRouteCubit _cubit;

  @override
  void initState() {
    super.initState();
    final AppRepository appRepository = AppRepository();
    _cubit = SelectRouteCubit(appRepository);
    _cubit.getRoadAppRoadMap();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _cubit,
      child: Scaffold(
        body: CommonPage(
          //TODO: Change background
          background: R.drawable.bg_lesson_detail,
          title: 'Chọn lộ trình',
          bottomSafeArea: true,
          child: BlocConsumer<SelectRouteCubit, SelectRouteState>(
            listener: (context, state) {
              if (state is SelectRouteLoading) {
                BotToast.showLoading();
              } else {
                BotToast.closeAllLoading();
              }
              if (state is SelectRouteFailure) {
                Message.showToastMessage(context, state.error);
              }
            },
            builder: (context, state) {
              return RefreshIndicator(
                onRefresh: () async {
                  _cubit.getRoadAppRoadMap();
                },
                child: LoadMore(
                  onLoadMore: () async {
                    return _cubit.getRoadAppRoadMap(isLoadMore: true);
                  },
                  isFinish: !_cubit.hasMore,
                  whenEmptyLoad: false,
                  delegate: const CustomLoadMoreDelegate(),
                  textBuilder: DefaultLoadMoreTextBuilder.english,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                    itemCount: _cubit.roadMapList.length,
                    itemBuilder: (context, index) {
                      return _buildRoute(_cubit.roadMapList[index]);
                    },
                    separatorBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 20),
                        height: 1,
                        color: R.color.grayBorder,
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRoute(ListRoadmapResponseDataItems? itemData) {
    if (itemData == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            clipBehavior: Clip.hardEdge,
            height: 171.5,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
            ),
            child: CachedNetworkImage(
              imageUrl: itemData.image?.url ?? '',
            )),
        const SizedBox(height: 12),
        Text(
          itemData.name ?? '',
          style: TextStyle(
            color: R.color.textDark,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          itemData.description ?? '',
          style: TextStyle(
            color: R.color.grey_1,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Cường độ yếu',
              style: TextStyle(
                color: R.color.orange_1,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(
              width: 120,
              child: ButtonWidget(
                title: 'Tham gia',
                height: 32,
                textSize: 14,
                onPressed: () {
                  showDialog(
                    barrierColor: R.color.color0xff003F38.withOpacity(0.5),
                    context: context,
                    builder: (_) => NoticeChangePage(
                        description:
                            'Bạn đang học lộ trình cho người có thể trạng yếu, bạn có chắc muốn đổi lộ trình khác không?',
                        positiveButtonTitle: 'Xác nhận',
                        onClick: () {
                          NavigationUtil.pop(context);
                          // showDialog(
                          //   context: context,
                          //   builder: (_) => Scaffold(
                          //     body: Center(
                          //       child: Container(
                          //         width: 200,
                          //         height: 200,
                          //         color: Colors.red,
                          //       ),
                          //     ),
                          //   ),
                          // );
                        },
                        gradientColor: true),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
