import 'package:flutter_observer/Observable.dart';
import 'package:intl/intl.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'blocs/newsDetail_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/app_setting/app_sharing.dart';
import 'package:medical/src/widgets/html_text_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widgets/network_image_widget.dart';
import 'package:medical/src/app_setting/dynamic_link_config.dart';
import 'package:medical/src/modal/learning/learning_post_model.dart';

class NewsDetailView extends StatefulWidget {
  final String id;
  const NewsDetailView({Key? key, required this.id}) : super(key: key);

  @override
  State<NewsDetailView> createState() => _NewsDetailViewState();
}

class _NewsDetailViewState extends State<NewsDetailView> {
  bool isSticky = false;
  bool isScrolled = false;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  _scrollListener() {
    if (_scrollController.position.pixels >= 50) {
      if (!isScrolled) {
        setState(() {
          isScrolled = true;
        });
      }
    } else if (isScrolled) {
      setState(() {
        isScrolled = false;
      });
    }

    if (_scrollController.position.pixels >= 300) {
      if (!isSticky) {
        setState(() {
          isSticky = true;
        });
      }
    } else if (isSticky) {
      setState(() {
        isSticky = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NewsDetailBloc>(
      create: (_) =>
          NewsDetailBloc()..add(EventGetNewsDetail(newsId: widget.id)),
      child: Scaffold(
        body: BlocListener<NewsDetailBloc, NewsDetailState>(
          listener: ((context, state) {
            if (state.blocStatus == BlocStatus.loading) {
              BotToast.showLoading();
            } else if (state.blocStatus == BlocStatus.error) {
              Message.showToastMessage(context, state.blocMessage);
              BotToast.closeAllLoading();
            } else {
              BotToast.closeAllLoading();
            }
          }),
          child: BlocBuilder<NewsDetailBloc, NewsDetailState>(
            buildWhen: ((previous, current) =>
                previous.newsDetail != current.newsDetail),
            builder: (context, state) {
              bool hasBanner = false;
              final LearningPostModel? newsDetail = state.newsDetail;
              String? createdDate;
              if (newsDetail != null) {
                DateTime dateConverted = DateFormat('MM/dd/yyyy HH:mm:ss')
                    .parse(newsDetail.createDatetime);
                dateConverted = dateConverted.add(Duration(hours: 7));
                createdDate = DateFormat('dd/MM/yyyy - HH:mm')
                    .format(dateConverted)
                    .toString();
                hasBanner = newsDetail.imageBannerUrl != null;
              }
              return NestedScrollView(
                controller: _scrollController,
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                  return <Widget>[
                    SliverAppBar(
                      backgroundColor: Color(0xFF006C5D),
                      expandedHeight: hasBanner ? 350 : 0,
                      floating: false,
                      pinned: true,
                      leading: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () => Navigator.pop(context),
                            child: AnimatedContainer(
                              margin: EdgeInsets.only(left: 15),
                              duration: Duration(milliseconds: 300),
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSticky
                                    ? Colors.transparent
                                    : Color(0xFF172823),
                              ),
                              child: Icon(
                                Icons.arrow_back,
                                size: isSticky ? 24 : 18,
                                color:
                                    isSticky ? R.color.textDark : R.color.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      flexibleSpace: FlexibleSpaceBar(
                        centerTitle: true,
                        title: AnimatedOpacity(
                          opacity: isSticky ? 1 : 0,
                          duration: Duration(milliseconds: 300),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(width: 50),
                              Text(
                                "Tin tức",
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                  color: R.color.textDark,
                                ),
                              ),
                              SizedBox(width: 50),
                              // InkWell(
                              //   onTap: () async =>
                              //       await _onShareNews(newsDetail!),
                              //   child: SizedBox(
                              //     width: 40,
                              //     child: SvgPicture.asset(
                              //       R.icons.ic_share,
                              //       width: 22,
                              //       color: R.color.textDark,
                              //       fit: BoxFit.scaleDown,
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                        background: hasBanner
                            ? Stack(
                                children: [
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    bottom: 25.h,
                                    left: 0,
                                    child: NetWorkImageWidget(
                                      imageUrl: newsDetail!.imageBannerUrl!.url,
                                      width: 223.w,
                                      height: 110.h,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    left: 0,
                                    child: Container(
                                      height: 120,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            R.color.black.withOpacity(0.5),
                                            R.color.black.withOpacity(0),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    left: 0,
                                    child: Container(
                                      height: 25.h,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(16),
                                        ),
                                        color: Color(0xFFF5FDFB),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : null,
                      ),
                    ),
                  ];
                },
                body: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  padding: EdgeInsets.only(
                    left: 15,
                    right: 15,
                    top: isScrolled || !hasBanner ? 15 : 0,
                    bottom: 15,
                  ),
                  color: Color(0xFFF5FDFB),
                  child: newsDetail == null
                      ? SizedBox()
                      : ListView(
                          physics: NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.all(0),
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (newsDetail
                                    .learningPostTagMappings.isNotEmpty)
                                  Expanded(
                                    child: Wrap(
                                      children: newsDetail
                                          .learningPostTagMappings
                                          .map((tag) => _itemHastag(tag))
                                          .toList(),
                                    ),
                                  ),
                                // InkWell(
                                //   onTap: () async =>
                                //       await _onShareNews(newsDetail),
                                //   child: SizedBox(
                                //     width: 40,
                                //     child: SvgPicture.asset(
                                //       R.icons.ic_share,
                                //       width: 22,
                                //       color: R.color.gray,
                                //       fit: BoxFit.scaleDown,
                                //     ),
                                //   ),
                                // ),
                                // InkWell(
                                //   onTap: () => Navigator.pop(context),
                                //   child: SizedBox(
                                //     width: 40,
                                //     child: SvgPicture.asset(
                                //       R.icons.ic_heart,
                                //       width: 21,
                                //       color: R.color.gray,
                                //       fit: BoxFit.scaleDown,
                                //     ),
                                //   ),
                                // ),
                              ],
                            ),
                            SizedBox(height: 15),
                            Text(
                              newsDetail.title,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Ngày $createdDate",
                              style: TextStyle(
                                fontSize: 12,
                                color: R.color.grey_2,
                              ),
                            ),
                            SizedBox(height: 10),
                            WidgetHtmlText(newsDetail.content),
                          ],
                        ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _itemHastag(LearningPostTagMappings tag) {
    return Container(
      margin: EdgeInsets.only(right: 10),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: R.color.color0xffD6F5F6,
      ),
      child: Text(
        tag.name,
        style: TextStyle(
          fontSize: 14,
          color: R.color.color0xff008890,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Future<void> _onShareNews(LearningPostModel newsDetail) async {
    String? shareLink = await DynamicLinkConfig.createShareNewsLink(newsDetail);
    if (shareLink != null) {
      AppShare.instance.shareNews(context, shareLink);
    }
  }
}
