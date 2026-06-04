import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/firebase_tracking/motion_list_tracking.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/list_roadmap_response.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/notice_change/notice_change_page.dart';
import 'package:medical/src/widgets/common_page.dart';
import 'package:medical/src/widgets/gap_widget.dart';
import 'package:medical/src/widgets/network_image_widget.dart';
import 'package:url_launcher/url_launcher.dart';

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
          appbarColor: R.color.greenGradientBottom,
          textColor: Colors.white,
          title: R.string.select_road_map.tr(),
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
                showDialogChangeSuccessed(state.itemData);
              }
            },
            builder: (context, state) {
              return RefreshIndicator(
                onRefresh: () async {
                  _cubit.getRoadAppRoadMap();
                },
                child: Container(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                    children: _cubit.roadMapList
                        .map((item) => _buildRoadMap(item))
                        .toList(),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRoadMap(ListRoadmapResponseData? itemData) {
    if (itemData == null) return const SizedBox.shrink();
    final bool isJoined = itemData.joined == true;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: R.color.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: R.color.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image at top
            Container(
              clipBehavior: Clip.hardEdge,
              height: 171.5,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: NetWorkImageWidget(
                imageUrl: itemData.image?.url,
              ),
            ),
            GapH(16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Intensity label (red)
                if (itemData.exerciseIntensity?.name != null)
                  Text(
                    itemData.exerciseIntensity?.name ?? '',
                    style: TextStyle(
                      color: R.color.blood_pressure_color,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                GapH(4),
                // Title
                MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                      textScaler: MediaQuery.of(context)
                          .textScaler
                          .clamp(minScaleFactor: 1.0, maxScaleFactor: 1.3)),
                  child: Text(
                    itemData.name ?? '',
                    style: TextStyle(
                      color: R.color.textDark,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                GapH(8),
                // Description
                if (itemData.description != null &&
                    itemData.description!.isNotEmpty)
                  Text(
                    itemData.description ?? '',
                    style: TextStyle(
                      color: R.color.captionColorGray,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                GapH(16),
                // Action button
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: isJoined
                        ? () {
                            NavigationUtil.pop(context);
                          }
                        : () {
                            MotionListTracking.clickJoinRoadMap(
                              objectId: '${itemData.id}',
                              objectTitle: '${itemData.name}',
                            );
                            showDialog(
                              barrierColor:
                                  R.color.color0xff003F38.withOpacity(0.5),
                              context: context,
                              builder: (_) => NoticeChangePage(
                                  isShowTextHtml: false,
                                  title: R.string.change_roadmap.tr(),
                                  htmlText:
                                      '''<p><span style="font-family: Arial, Helvetica, sans-serif; font-size: 16px;">Bạn đang tham gia ${_cubit.formatRoadmapName(_cubit.currentRoadMap?.name ?? '')}, bạn c&oacute; chắc muốn đổi lộ tr&igrave;nh kh&aacute;c kh&ocirc;ng?</span></p>''',
                                  description: R.string.ask_for_change_roadmap
                                      .tr(args: [
                                    _cubit.currentRoadMap?.name ?? ''
                                  ]),
                                  negativeButtonTitle: R.string.lan_sau.tr(),
                                  onClick: () {
                                    MotionListTracking.clickConfirmJoinRoadMap(
                                      objectId: '${itemData.id}',
                                      objectTitle: '${itemData.name}',
                                    );
                                    _cubit.changeRoadMap(itemData);
                                  },
                                  gradientColor: false),
                            );
                          },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isJoined ? R.string.joining.tr() : R.string.join.tr(),
                          style: TextStyle(
                            color:
                                isJoined ? R.color.grayCaption : R.color.main_1,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_outlined,
                          size: 18,
                          color:
                              isJoined ? R.color.grayCaption : R.color.main_1,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> showDialogChangeSuccessed(
      ListRoadmapResponseData? itemData) async {
    await showDialog(
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
                        R.string.change_road_map_success.tr(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: R.color.textDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Html(
                        data:
                            '''<div><span style="font-family: Arial, Helvetica, sans-serif; font-size: 15px;">Bạn đ&atilde; chọn ${_cubit.formatRoadmapName(itemData?.name ?? '')}. Lộ tr&igrave;nh bao gồm ${(itemData?.exerciseMovementCount ?? 0).toString()} b&agrave;i học.</span></div>''',
                        style: {
                          "body": Style(
                              padding: HtmlPaddings.zero, margin: Margins.zero),
                        },
                        onLinkTap: (url, attributes, element) {
                          if (url == null) return;
                          launchUrl(Uri.parse(url),
                              mode: LaunchMode.externalApplication);
                        },
                      ),
                      // Text(
                      //   R.string.road_map_changed.tr(args: [
                      //     itemData?.name ?? '',
                      //     (itemData?.exerciseMovementCount ?? 0).toString()
                      //   ]),
                      //   style: TextStyle(
                      //     fontSize: 16,
                      //     fontWeight: FontWeight.w400,
                      //     color: R.color.textDark,
                      //   ),
                      //   textAlign: TextAlign.center,
                      // ),
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
    NavigationUtil.pop(context, result: itemData?.id ?? '');
  }
}
