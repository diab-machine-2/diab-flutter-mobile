import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/my_plan_screens/activity_tab/expert_comment/model/expert_comment_model.dart';
import 'expert_comment_detail.dart';

class ExpertCommentDetailPage extends StatefulWidget {
  ExpertCommentModel? item;

  ExpertCommentDetailPage({Key? key, this.item}) : super(key: key);

  @override
  _ExpertCommentDetailPageState createState() => _ExpertCommentDetailPageState();
}

class _ExpertCommentDetailPageState extends State<ExpertCommentDetailPage> {
  late ExpertCommentDetailCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = ExpertCommentDetailCubit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => _cubit,
        child: BlocListener<ExpertCommentDetailCubit, ExpertCommentDetailState>(
          listener: (context, state) {},
          child: BlocBuilder<ExpertCommentDetailCubit, ExpertCommentDetailState>(
            builder: (context, state) {
              return _buildPage(context, state);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPage(BuildContext context, ExpertCommentDetailState state) {
    return Scaffold(
      body: Container(
        color: R.color.greenbg,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            _buildAppBar(context),
            _buildBody(),
          ],
        ),
      ),
    );
  }

  _buildAppBar(BuildContext context) {
    return CustomAppBar(
      backgroundColor: R.color.transparent,
      title: Text('', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: R.color.textDark)),
      leadingIcon: IconButton(
          splashColor: R.color.transparent,
          highlightColor: R.color.transparent,
          icon: Icon(Icons.arrow_back, color: R.color.textDark),
          onPressed: () {
            Navigator.pop(context);
          }),
    );
  }

  _buildBody() {
    return Container(
      padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(color: R.color.mainColor, borderRadius: BorderRadius.circular(52)),
                child: Icon(Icons.person, size: 64, color: R.color.white),
                // user.imageUrl!.url == null
                //     ? Icon(Icons.person, size: 64, color: R.color.white)
                //     : Image.network(user.imageUrl!.url!, width: 64, height: 64)),
              ),
              SizedBox(height: 8),
              Text(
                widget.item?.name ?? '',
                style: TextStyle(color: R.color.textDark, fontSize: 16, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.item?.role ?? '',
                    style: TextStyle(color: getColor(0), fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(width: 4),
                  Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: R.color.notActiveGreen)),
                  SizedBox(width: 4),
                  Text(
                    widget.item?.dateTime ?? '',
                    style: TextStyle(color: R.color.textDark, fontSize: 14, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
              SizedBox(height: 8),
            ],
          ),
          SizedBox(height: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                R.string.comment.tr(),
                style: TextStyle(color: R.color.captionColorGray, fontSize: 14, fontWeight: FontWeight.w400),
              ),
              SizedBox(height: 4),
              Text(
                widget.item?.comment ?? '',
                style: TextStyle(color: R.color.textDark, fontSize: 16, fontWeight: FontWeight.w400),
              ),
              SizedBox(height: 8),
              Text(
                R.string.next_action.tr(),
                style: TextStyle(color: R.color.captionColorGray, fontSize: 14, fontWeight: FontWeight.w400),
              ),
              SizedBox(height: 4),
              Text(
                'Duy trì hoạt động tập thể dục hàng ngày vào mỗi buổi sáng.',
                style: TextStyle(color: R.color.textDark, fontSize: 16, fontWeight: FontWeight.w400),
              ),
            ],
          ),
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
