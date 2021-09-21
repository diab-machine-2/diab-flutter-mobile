
import 'package:flutter/material.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:loadmore/loadmore.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/bloc/emotion/emotion_bloc.dart';
import 'package:medical/src/modal/emotion/input_emotion_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/Emotion/emotion_detail_tabbar.dart';
import 'package:medical/src/widget/components/load_more.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:easy_localization/easy_localization.dart';

class EmotionDetailController extends StatefulWidget {
  EmotionDetailController({Key? key}) : super(key: key);
  @override
  EmotionDetailControllerState createState() => EmotionDetailControllerState();
}

class EmotionDetailControllerState extends State<EmotionDetailController>
    with AutomaticKeepAliveClientMixin<EmotionDetailController> {
  @override
  bool get wantKeepAlive => true;

  late BuildContext currentContext;
  ScrollController _scrollController = ScrollController();

  int page = 1;
  bool? hasMore = false;
  bool isLoading = false;
  int periodFilterType = 1;

  @override
  void initState() {
    periodFilterType =
        EmotionDetailTabbarController.of(context)!.periodFilterType;
    super.initState();
    initializeDateFormatting();

    TrackingManager.analytics.setCurrentScreen(screenName: 'Emotion Detail');
  }

  reloadData(int periodFilter) {
    periodFilterType = periodFilter;
    _scrollController.jumpTo(0);
    _refresh();
  }

  Future<bool> _loadMorePage() async {
    if (isLoading || !hasMore!) {
      return true;
    } else {
      isLoading = true;
      BlocProvider.of<EmotionBloc>(currentContext).add(FetchInputEmotion(
        page: page,
        currentDateTime:
            (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
        periodFilterType: periodFilterType.toString(),
      ));
    }
    return true;
  }

  Future<bool> _refresh() async {
    page = 1;
    BlocProvider.of<EmotionBloc>(currentContext).add(FetchInputEmotion(
      page: 1,
      currentDateTime:
          (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
      periodFilterType: periodFilterType.toString(),
    ));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider<EmotionBloc>(
        create: (context) => EmotionBloc(),
        child: BlocBuilder<EmotionBloc, EmotionState>(
            builder: (BuildContext context, EmotionState state) {
          currentContext = context;
          List<InputEmotionModel>? model;
          if (state is EmotionInitial) {
            BlocProvider.of<EmotionBloc>(context).add(FetchInputEmotion(
                currentDateTime:
                    (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
                periodFilterType: periodFilterType.toString(),
                page: 1));
          }
          if (state is EmotionError) {
            Message.showToastMessage(context, state.message);
          }
          if (state is EmotionLoading) {
            return Center(child: CircularProgressIndicator());
          }
          if (state is EmotionLoaded) {
            model = state.inputModel.inputs;
            hasMore = state.inputModel.hasMore;
            if (hasMore!) {
              page += 1;
            }
            isLoading = false;
          }

          return RefreshIndicator(
              onRefresh: _refresh,
              child: Scaffold(
                backgroundColor: R.color.backgroundColor,
                body: model == null
                    ? Center(child: CircularProgressIndicator())
                    : Container(
                        decoration: BoxDecoration(
                            image: DecorationImage(
                          image:
                              AssetImage(R.drawable.bg_detail),
                          fit: BoxFit.cover,
                        )),
                        child: LoadMore(
                            onLoadMore: _loadMorePage,
                            isFinish: !hasMore!,
                            whenEmptyLoad: false,
                            delegate: CustomLoadMoreDelegate(),
                            textBuilder: DefaultLoadMoreTextBuilder.english,
                            child: ListView.builder(
                              controller: _scrollController,
                              physics: AlwaysScrollableScrollPhysics(),
                              itemCount: model.length,
                              itemBuilder: (BuildContext context, int index) {
                                final element = model![index];
                                final previousElement =
                                    index == 0 ? null : model[index - 1];

                                final showDate = previousElement == null
                                    ? true
                                    : (convertCustomDate(element.date!) !=
                                        convertCustomDate(
                                            previousElement.date!));
                                return GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(
                                          context, NavigatorName.add_insight, arguments: {
                                        'type': 'update',
                                        'id': model![index].id
                                      });
                                    },
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        showDate
                                            ? Padding(
                                                padding: EdgeInsets.all(16),
                                                child: Text(
                                                  convertCustomDate(
                                                      model[index].date!),
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                              )
                                            : SizedBox(),
                                        Padding(
                                          padding: EdgeInsets.only(
                                              left: 16, right: 16, bottom: 16),
                                          child: Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  color: R.color.white),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                      height: 58,

                                                      // color: R.color.color0xff50C087,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 16,
                                                                right: 16),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Text(
                                                                  convertToUTC(
                                                                          element
                                                                              .date!,
                                                                          'HH:mm') +
                                                                      ',',
                                                                  style: TextStyle(
                                                                      color: R.color
                                                                          .black,
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700),
                                                                ),
                                                                SizedBox(
                                                                    width: 4),
                                                                Text(
                                                                    element
                                                                        .timeFrameText!,
                                                                    style: TextStyle(
                                                                        color: R.color
                                                                            .black,
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight.w700)),
                                                              ],
                                                            ),
                                                            Image.network(
                                                              element.emotionIcon
                                                                      .url ??
                                                                  '',
                                                              width: 36,
                                                              height: 36,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      decoration: BoxDecoration(
                                                          color: toColor(element
                                                              .backgroundColorCode),
                                                          borderRadius:
                                                              BorderRadius.only(
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          13),
                                                                  topRight: Radius
                                                                      .circular(
                                                                          13)))),
                                                  Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              16.0),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            R.string.trieu_chung.tr(),
                                                            style: TextStyle(
                                                                color: R.color
                                                                    .black,
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700),
                                                          ),
                                                          SizedBox(
                                                            height: 8,
                                                          ),
                                                          Tags(
                                                            // key: _tagStateKey,
                                                            alignment:
                                                                WrapAlignment
                                                                    .start,
                                                            runAlignment:
                                                                WrapAlignment
                                                                    .start,
                                                            //columns: 3,
                                                            horizontalScroll:
                                                                false,
                                                            itemCount: element
                                                                .symptoms
                                                                .length,
                                                            itemBuilder:
                                                                (index) {
                                                              final item = element
                                                                      .symptoms[
                                                                  index];

                                                              return ItemTags(
                                                                  pressEnabled:
                                                                      false,
                                                                  key: Key(index
                                                                      .toString()),
                                                                  index: index,
                                                                  image:
                                                                      ItemTagsImage(
                                                                    child: Image.network(
                                                                        item.icon.url ??
                                                                            '',
                                                                        width:
                                                                            24,
                                                                        height:
                                                                            24),
                                                                  ),
                                                                  title: item.name ??
                                                                      '',
                                                                  activeColor:
                                                                      R.color
                                                                          .white,
                                                                  textOverflow:
                                                                      TextOverflow
                                                                          .visible,
                                                                  splashColor:
                                                                      Colors
                                                                          .green,
                                                                  combine:
                                                                      ItemTagsCombine
                                                                          .withTextAfter,
                                                                  textActiveColor:
                                                                      R.color.textDark,
                                                                  textStyle:
                                                                      TextStyle(
                                                                          fontSize:
                                                                              14),
                                                                  elevation: 0,
                                                                  onPressed:
                                                                      (item) =>
                                                                          null);
                                                            },
                                                          ),
                                                          model[index].otherSymptom ==
                                                                      null ||
                                                                  model[index]
                                                                      .otherSymptom!
                                                                      .isEmpty
                                                              ? SizedBox()
                                                              : Padding(
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      top: 16,
                                                                      bottom:
                                                                          8),
                                                                  child: Row(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Text(
                                                                        '${R.string.trieu_chung_khac.tr()}:',
                                                                        style: TextStyle(
                                                                            color: R.color
                                                                                .black,
                                                                            fontSize:
                                                                                14,
                                                                            fontWeight:
                                                                                FontWeight.w400),
                                                                      ),
                                                                      SizedBox(
                                                                        width:
                                                                            4,
                                                                      ),
                                                                      Expanded(
                                                                        child:
                                                                            Text(
                                                                          model[index]
                                                                              .otherSymptom!,
                                                                          style: TextStyle(
                                                                              color: R.color.black,
                                                                              fontSize: 14,
                                                                              fontWeight: FontWeight.w400),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                          SizedBox(
                                                            height: 8,
                                                          ),
                                                          Container(
                                                              height: 1,
                                                              color: R.color.color0xffE5E5E5),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    top: 16,
                                                                    bottom: 8),
                                                            child: Text(
                                                              R.string.hoat_dong.tr(),
                                                              style: TextStyle(
                                                                  color: R.color
                                                                      .black,
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700),
                                                            ),
                                                          ),
                                                          Tags(
                                                            alignment:
                                                                WrapAlignment
                                                                    .start,
                                                            runAlignment:
                                                                WrapAlignment
                                                                    .start,
                                                            // key: _tagStateKey,
                                                            //columns: 3,
                                                            horizontalScroll:
                                                                false,
                                                            itemCount: element
                                                                .activities
                                                                .length,
                                                            itemBuilder:
                                                                (index) {
                                                              final item = element
                                                                      .activities[
                                                                  index];

                                                              return ItemTags(
                                                                  pressEnabled:
                                                                      false,
                                                                  key: Key(index
                                                                      .toString()),
                                                                  index: index,
                                                                  image:
                                                                      ItemTagsImage(
                                                                    child: Image.network(
                                                                        item.icon.url ??
                                                                            '',
                                                                        width:
                                                                            24,
                                                                        height:
                                                                            24),
                                                                  ),
                                                                  title: item.name ??
                                                                      '',
                                                                  activeColor:
                                                                      R.color
                                                                          .white,
                                                                  textOverflow:
                                                                      TextOverflow
                                                                          .visible,
                                                                  splashColor:
                                                                      Colors
                                                                          .green,
                                                                  combine:
                                                                      ItemTagsCombine
                                                                          .withTextAfter,
                                                                  textActiveColor:
                                                                      R.color.textDark,
                                                                  textStyle:
                                                                      TextStyle(
                                                                          fontSize:
                                                                              14),
                                                                  elevation: 0,
                                                                  onPressed:
                                                                      (item) =>
                                                                          null);
                                                            },
                                                          ),
                                                          model[index].otherActivity ==
                                                                      null ||
                                                                  model[index]
                                                                      .otherActivity!
                                                                      .isEmpty
                                                              ? SizedBox()
                                                              : Padding(
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      top: 16,
                                                                      bottom:
                                                                          8),
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        '${R.string.hoat_dong_khac.tr()}:',
                                                                        style: TextStyle(
                                                                            color: R.color
                                                                                .black,
                                                                            fontSize:
                                                                                14,
                                                                            fontWeight:
                                                                                FontWeight.w400),
                                                                      ),
                                                                      SizedBox(
                                                                        width:
                                                                            4,
                                                                      ),
                                                                      Expanded(
                                                                        child:
                                                                            Text(
                                                                          model[index]
                                                                              .otherActivity!,
                                                                          style: TextStyle(
                                                                              color: R.color.black,
                                                                              fontSize: 14,
                                                                              fontWeight: FontWeight.w400),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                        ],
                                                      )),
                                                ],
                                              )),
                                        ),
                                      ],
                                    ));
                              },
                            ))),
              ));
        }));
  }
}
