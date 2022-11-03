import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/learning/learning_post_model.dart';
import 'package:medical/src/repo/learning/learning_client.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../widgets/network_image_widget.dart';

class CourseSuggest extends StatefulWidget {
  final int position;

  const CourseSuggest({Key? key, required this.position}) : super(key: key);

  @override
  CourseSuggestState createState() => CourseSuggestState();
}

class CourseSuggestState extends State<CourseSuggest>
    with AutomaticKeepAliveClientMixin<CourseSuggest> {
  @override
  bool get wantKeepAlive => true;
  List<LearningPostModel> models = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  loadData() async {
    models = await LearningClient().fetchLearningPost(widget.position);
    if (widget.position == 1) {
      models.removeWhere((item) => item.status == 0);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return models.length == 0
        ? SizedBox()
        : Container(
            color: R.color.transparent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(R.string.bai_viet_noi_bat.tr(),
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                ),
                Container(
                  height: 190,
                  alignment: Alignment.center,
                  child: CarouselSlider.builder(
                    options: CarouselOptions(
                      autoPlay: true,
                      aspectRatio: 2.16,
                      autoPlayInterval: Duration(seconds: 3),
                      viewportFraction: 0.6,
                      initialPage: 0,
                    ),
                    itemCount: models.length,
                    itemBuilder:
                        (BuildContext context, int index, int pageViewIndex) =>
                            _newsItem(models[index]),
                  ),
                )
              ],
            ),
          );
  }

  Widget _newsItem(LearningPostModel postItem) {
    String? imagePartnerUrl = postItem.imagePartnerUrl?.url;
    return GestureDetector(
      onTap: () {
        if (postItem.enableLink) {
          _launchInBrowser(postItem.link!);
        } else {
          Navigator.pushNamed(
            context,
            NavigatorName.news_detail,
            arguments: {'id': postItem.id},
          );
        }
      },
      child: Container(
        padding: EdgeInsets.only(left: 6, right: 6),
        color: R.color.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: NetWorkImageWidget(
                imageUrl: postItem.imageUrl.url ?? '',
                width: 223.w,
                height: 110.h,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (imagePartnerUrl != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 5.0),
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: R.color.white,
                      child: NetWorkImageWidget(
                        imageUrl: imagePartnerUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AutoSizeText(
                        postItem.title,
                        minFontSize: 10,
                        style: TextStyle(
                          fontSize: 13,
                          color: R.color.textDark,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (postItem.partnerName != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 3.0),
                          child: AutoSizeText(
                            "${postItem.partnerName}",
                            minFontSize: 8,
                            style: TextStyle(
                              fontSize: 12,
                              color: R.color.textDark.withOpacity(0.5),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
        headers: <String, String>{'my_header_key': 'my_header_value'},
      );
    } else {
      throw 'Could not launch $url';
    }
  }
}
