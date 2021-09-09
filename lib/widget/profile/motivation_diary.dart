import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loadmore/loadmore.dart';
import 'package:medical/modal/user/goal_info.dart';
import 'package:medical/modal/user/motivation_model.dart';
import 'package:medical/repo/user/user_client.dart';
import 'package:medical/theme/app_theme.dart';
import 'package:medical/widget/base/custom_appbar.dart';
import 'package:medical/widget/components/horizontal_picker/horizontal_numberpicker_wrapper.dart';
import 'package:medical/widget/components/load_more.dart';
import 'package:medical/widget/helper/helper.dart';
import 'package:medical/widget/helper/show_message.dart';
import 'package:medical/modal/error/error_model.dart';

class MotivationController extends StatefulWidget {
  @override
  _MotivationControllerState createState() => _MotivationControllerState();
}

class _MotivationControllerState extends State<MotivationController> {
  List<MotivationModel> models;

  int page = 1;
  bool hasMore = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<bool> loadData() async {
    page = 1;
    final result = await UserClient().fetchMotivationDiary(page);
    models = result.models;
    hasMore = result.hasMore;
    if (hasMore) {
      page += 1;
    }
    setState(() {});
    return true;
  }

  Future<bool> _loadMore() async {
    if (isLoading || !hasMore) {
      return true;
    } else {
      isLoading = true;
      final result = await UserClient().fetchMotivationDiary(page);
      models.addAll(result.models);
      hasMore = result.hasMore;
      if (hasMore) {
        page += 1;
      }
      isLoading = false;
      setState(() {});
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
          body: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [
                        Color(0xFFFDC798).withOpacity(0.3),
                        Color(0xFFE6F6ED).withOpacity(0.9),
                      ],
                      begin: FractionalOffset(1, 1),
                      end: FractionalOffset(0.9, 0.5),
                      stops: [0.0, 1.0])),
              child: Column(children: [
                CustomAppBar(
                  backgroundColor: Colors.transparent,
                  title: Text('Nhật ký động lực',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: textDark)),
                  leadingIcon: IconButton(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      icon: Icon(Icons.arrow_back, color: textDark),
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                ),
                SizedBox(height: 8),
                Image.asset('assets/images/motivation_bg.png', height: 120),
                SizedBox(height: 8),
                Expanded(
                  child: RefreshIndicator(
                      onRefresh: loadData,
                      child: models == null
                          ? Center(child: CircularProgressIndicator())
                          : LoadMore(
                              onLoadMore: _loadMore,
                              isFinish: !hasMore,
                              whenEmptyLoad: false,
                              delegate: CustomLoadMoreDelegate(),
                              textBuilder: DefaultLoadMoreTextBuilder.english,
                              child: ListView.separated(
                                  padding: EdgeInsets.only(bottom: 16),
                                  itemCount: models.length,
                                  separatorBuilder:
                                      (BuildContext context, int index) {
                                    return Container(
                                        height: 1, color: Color(0xffE5E5E5));
                                  },
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Container(
                                        padding: EdgeInsets.all(16),
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(models[index].content,
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: textDark)),
                                              SizedBox(height: 12),
                                              Text(
                                                  convertToUTC(
                                                      models[index]
                                                          .createDateTime,
                                                      'HH:mm - dd/MM/yyyy'),
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: Color(0xff9C9C9C)))
                                            ]));
                                  }))),
                )
              ]))),
    );
  }
}
