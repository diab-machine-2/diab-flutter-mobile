import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'expert_comment.dart';
import 'expert_comment_detail/expert_comment_detail_page.dart';
import 'model/expert_comment_model.dart';

class ExpertCommentPage extends StatefulWidget {
  const ExpertCommentPage({Key? key}) : super(key: key);

  @override
  _ExpertCommentPageState createState() => _ExpertCommentPageState();
}

class _ExpertCommentPageState extends State<ExpertCommentPage> {
  late ExpertCommentCubit _cubit;

  @override
  void initState() {
    super.initState();
    final AppRepository appRepository = AppRepository();
    _cubit = ExpertCommentCubit(appRepository);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => _cubit,
        child: BlocListener<ExpertCommentCubit, ExpertCommentState>(
          listener: (context, state) {},
          child: BlocBuilder<ExpertCommentCubit, ExpertCommentState>(
            builder: (context, state) {
              return _buildPage(context, state);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPage(BuildContext context, ExpertCommentState state) {
    return Scaffold(
      body: Container(
        color: R.color.greenbg,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildAppBar(context),
            _buildList(),
          ],
        ),
      ),
    );
  }

  _buildAppBar(BuildContext context) {
    return CustomAppBar(
      backgroundColor: R.color.transparent,
      title: Text(R.string.expert_comment.tr(),
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: R.color.textDark)),
      leadingIcon: IconButton(
          splashColor: R.color.transparent,
          highlightColor: R.color.transparent,
          icon: Icon(Icons.arrow_back, color: R.color.textDark),
          onPressed: () {
            Navigator.pop(context);
          }),
    );
  }

  _buildList() {
    return Expanded(
      child: Container(
        padding: EdgeInsets.only(left: 8, right: 8, bottom: 8),
        child: _cubit.commentList.length > 0
            ? ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: _cubit.commentList.length,
                shrinkWrap: true,
                itemBuilder: (context, position) {
                  return _buildItem(_cubit.commentList[position]);
                },
                // separatorBuilder: (context, position) {
                //   return Divider(height: 0);
                // },
              )
            : _buildEmpty(),
      ),
    );
  }

  _buildItem(ExpertCommentModel item) {
    return GestureDetector(
      onTap: () async {
        final result = await NavigationUtil.navigatePage(context, ExpertCommentDetailPage(item: item));
      },
      child: Container(
        padding: EdgeInsets.all(8),
        child: Row(
          children: [
            Container(
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(color: R.color.mainColor, borderRadius: BorderRadius.circular(52)),
              child: Icon(Icons.person, size: 56, color: R.color.white),
              // item.url == null
              //     ? Icon(Icons.person, size: 56, color: R.color.white)
              //     : Image.network(user.imageUrl!.url!, width: 56, height: 56)),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(color: R.color.textDark, fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.role,
                        style: TextStyle(color: getColor(0), fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                      SizedBox(width: 4),
                      Container(
                          width: 3,
                          height: 3,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: R.color.notActiveGreen)),
                      SizedBox(width: 4),
                      Text(
                        item.dateTime,
                        style: TextStyle(color: R.color.textDark, fontSize: 12, fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                  SizedBox(height: 2),
                  Text(
                    item.comment,
                    style: TextStyle(color: R.color.textDark, fontSize: 12, fontWeight: FontWeight.w400),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildEmpty() {
    return Container(
      padding: EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(R.drawable.ic_expert_comment, width: 300, height: 300),
          SizedBox(height: 8),
          Text(R.string.no_expert_comment.tr(),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: R.color.textDark),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Color getColor(int index) {
    switch (index) {
      case 0:
        return R.color.main_1;
      case 1:
        return R.color.orange_1;
      case 2:
        return R.color.accentColor;
      case 3:
        return R.color.yellow;
      default:
        return R.color.green;
    }
  }
}
