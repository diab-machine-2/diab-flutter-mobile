import 'package:bot_toast/bot_toast.dart';
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
import 'package:medical/src/widgets/network_image_widget.dart';

import 'select_road_map.dart';

class SelectRoadMapPage extends StatefulWidget {
  const SelectRoadMapPage();

  @override
  _SelectRoadMapPageState createState() => _SelectRoadMapPageState();
}

class _SelectRoadMapPageState extends State<SelectRoadMapPage> {
  late final SelectRoadMapCubit _cubit;

  @override
  void initState() {
    super.initState();
    final AppRepository appRepository = AppRepository();
    _cubit = SelectRoadMapCubit(appRepository);
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
          child: BlocConsumer<SelectRoadMapCubit, SelectRoadMapState>(
            listener: (context, state) {
              if (state is SelectRoadMapLoading) {
                BotToast.showLoading();
              } else {
                BotToast.closeAllLoading();
              }
              if (state is SelectRoadMapFailure) {
                Message.showToastMessage(context, state.error);
              }
              if (state is SelectRoadMapChanged) {
                showDialogChangeSuccessed();
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
                      return _buildRoadMap(_cubit.roadMapList[index]);
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

  Widget _buildRoadMap(ListRoadmapResponseDataItems? itemData) {
    if (itemData == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          clipBehavior: Clip.hardEdge,
          alignment: Alignment.center,
          height: 171.5,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
          ),
          child: NetWorkImageWidget(
            imageUrl: itemData.image?.url,
          ),
        ),
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
                          _cubit.changeRoadMap();
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

  void showDialogChangeSuccessed() {
    showDialog(
      context: context,
      builder: (_) => Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: SingleChildScrollView(
            child: Stack(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        R.color.white,
                        R.color.main_6,
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(50, 4, 50, 24),
                        child: Image.asset(
                          R.drawable.img_select_route_successed,
                        ),
                      ),
                      Text(
                        'Chọn lộ trình thành công!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: R.color.textDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Bạn đã chọn lộ trình cho người có thể trạng yếu. Lộ trình bao gồm 32 bài học.',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: R.color.textDark,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 24,
                  child: IconButton(
                    icon: const Icon(Icons.close_rounded),
                    iconSize: 24,
                    onPressed: () {
                      NavigationUtil.pop(context);
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
