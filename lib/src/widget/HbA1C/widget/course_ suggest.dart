import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/learning/learning_post_model.dart';
import 'package:medical/src/repo/learning/learning_client.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';

class CourseSuggest extends StatefulWidget {
  final int position;
  CourseSuggest({required this.position});
  @override
  _CourseSuggestState createState() => _CourseSuggestState();
}

class _CourseSuggestState extends State<CourseSuggest>
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
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return models.length == 0
        ? SizedBox()
        : Container(
            color: R.color.transparent,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(R.string.bai_viet_noi_bat.tr(),
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              ),
              Container(
                height: 180,
                child: ListView.separated(
                    padding: EdgeInsets.only(left: 16, right: 16),
                    itemCount: models.length,
                    scrollDirection: Axis.horizontal,
                    separatorBuilder: (BuildContext context, int index) {
                      return SizedBox(width: 16);
                    },
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                          _launchInBrowser(models[index].link!);
                        },
                        child: Container(
                          color: R.color.transparent,
                          width: 223,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.network(
                                  models[index].imageUrl.url ?? '',
                                  width: 223,
                                  height: 112,
                                  fit: BoxFit.fill,
                                ),
                                SizedBox(height: 8),
                                Text(models[index].title!,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis),
                              ]),
                        ),
                      );
                    }),
              )
            ]),
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
