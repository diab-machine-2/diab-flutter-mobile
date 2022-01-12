import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widgets/network_image_widget.dart';
import 'all_question_answer.dart';

class AllQuestionAnswerPage extends StatefulWidget {
  const AllQuestionAnswerPage({Key? key}) : super(key: key);

  @override
  _AllQuestionAnswerPageState createState() => _AllQuestionAnswerPageState();
}

class _AllQuestionAnswerPageState extends State<AllQuestionAnswerPage> with AutomaticKeepAliveClientMixin {
  late AllQuestionAnswerCubit _cubit;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _cubit = AllQuestionAnswerCubit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => _cubit,
        child: BlocListener<AllQuestionAnswerCubit, AllQuestionAnswerState>(
          listener: (context, state) {},
          child: BlocBuilder<AllQuestionAnswerCubit, AllQuestionAnswerState>(
            builder: (context, state) {
              return _buildPage(context, state);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPage(BuildContext context, AllQuestionAnswerState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTopic(context),
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            color: R.color.greenbg,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildQuestionDoctor(),
                SizedBox(height: 8),
                _buildQuestionList(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  _buildTopic(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(10.0), bottomRight: Radius.circular(10.0)), // Set rounded corner radius
        boxShadow: [BoxShadow(blurRadius: 1, color: R.color.grayBorder, offset: Offset(1, 3))],
        color: Colors.white,
      ),
      padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            R.string.view_by_topic.tr(),
            style: TextStyle(color: R.color.black, fontWeight: FontWeight.w400, fontSize: 14),
          ),
          SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: _scrollController,
            child: Row(
              children: List.generate(_cubit.topic.length, (index) {
                return _buildTopicItem(
                    item: _cubit.topic[index],
                    isSelected: index == _cubit.currentTopic,
                    onSelect: () {
                      _cubit.onSelectWeek(index);
                    });
              })
                ..add(SizedBox(width: _cubit.topic.isEmpty ? MediaQuery.of(context).size.width - 96 * 2 : 0)),
            ),
          ),
        ],
      ),
    );
  }

  _buildTopicItem({
    required String item,
    required bool isSelected,
    VoidCallback? onSelect,
  }) {
    return GestureDetector(
      onTap: onSelect,
      child: Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.only(right: 8),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? R.color.greenGradientBottom : R.color.grayBorder,
          border: isSelected ? Border.all(color: R.color.greenGradientBottom) : null,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              item,
              style: TextStyle(
                color: isSelected ? R.color.white : R.color.black,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildQuestionDoctor() {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, NavigatorName.make_question);
      },
      child: Container(
        height: 78,
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              right: 0,
              left: 0,
              child: Container(
                height: 66,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  color: R.color.white,
                  elevation: 2,
                  child: Container(
                    padding: EdgeInsets.all(18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(width: 32),
                        Text(
                          R.string.ask_doctor.tr(),
                          style:
                              TextStyle(color: R.color.greenGradientBottom, fontWeight: FontWeight.w700, fontSize: 16),
                        ),
                        Image.asset(R.drawable.ic_right, width: 18, height: 18, color: R.color.greenGradientBottom),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 8,
              bottom: 5,
              child: Image.asset(R.drawable.ic_doctor, width: 66, height: 66),
            ),
          ],
        ),
      ),
    );
  }

  _buildQuestionList() {
    return Expanded(
      child: ListView.builder(
        itemCount: 10,
        shrinkWrap: true,
        itemBuilder: (context, position) {
          return _buildQuestionItem(position);
        },
      ),
    );
  }

  _buildQuestionItem(int position) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      color: R.color.white,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      elevation: 2,
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeaderItem(),
            SizedBox(height: 12),
            _buildTitleItem(),
            SizedBox(height: 16),
            Divider(height: 0.5, color: R.color.grayBorder),
            SizedBox(height: 16),
            ListView.builder(
              itemCount: 1,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, position) {
                return _buildDoctorItemInQuestionItem(position);
              },
            ),
          ],
        ),
      ),
    );
  }

  _buildHeaderItem() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(vertical: 3, horizontal: 6),
          decoration: BoxDecoration(
            color: true ? R.color.greenGradientBottom : R.color.grayBorder,
            border: true ? Border.all(color: R.color.greenGradientBottom) : null,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Vận động',
            style: TextStyle(
              color: true ? R.color.white : R.color.black,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          R.string.replied.tr(),
          style: TextStyle(
            color: R.color.greenGradientBottom,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  _buildTitleItem() {
    return Text(
      'Di truyền có phải là nguyên nhân gây bệnh đái tháo đường típ 2 không?',
      style: TextStyle(
        color: R.color.black,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  _buildDoctorItemInQuestionItem(int position) {
    return Row(
      children: [
        Container(
          clipBehavior: Clip.hardEdge,
          height: 40,
          width: 40,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(90), color: R.color.grayBorder),
          //     child: NetWorkImageWidget(imageUrl: exerciseItem?.image?.url ?? ''),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'BS. Le Thi Thuy',
                style: TextStyle(
                  color: R.color.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 2),
              Text(
                '12/12/2021 - 10:30',
                style: TextStyle(
                  color: R.color.gray,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        Image.asset(R.drawable.ic_right, width: 14, height: 14, color: R.color.greenGradientBottom),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
