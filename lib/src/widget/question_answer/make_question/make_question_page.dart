import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'make_question.dart';

class MakeQuestionPage extends StatefulWidget {
  const MakeQuestionPage({Key? key}) : super(key: key);

  @override
  _MakeQuestionPageState createState() => _MakeQuestionPageState();
}

class _MakeQuestionPageState extends State<MakeQuestionPage> {
  late MakeQuestionCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = MakeQuestionCubit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => _cubit,
        child: BlocListener<MakeQuestionCubit, MakeQuestionState>(
          listener: (context, state) {},
          child: BlocBuilder<MakeQuestionCubit, MakeQuestionState>(
            builder: (context, state) {
              return _buildPage(context, state);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPage(BuildContext context, MakeQuestionState state) {
    return Container(
      color: R.color.greenbg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAppBar(context),
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTopic(),
                _buildQuestion(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _buildAppBar(BuildContext context) {
    return CustomAppBar(
      backgroundColor: R.color.transparent,
      title: Text(R.string.ask_question.tr(),
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

  _buildTopic() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          R.string.select_topic.tr(),
          style: TextStyle(
            color: R.color.black,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 8),
        DropdownButtonHideUnderline(
          child: ButtonTheme(
            alignedDropdown: true,
            child: DropdownButton<String>(
              icon: Icon(
                Icons.keyboard_arrow_down,
                size: 20,
                color: R.color.textDark,
              ),
              hint: Text(
                R.string.select_topic.tr(),
                style: TextStyle(
                  color: R.color.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              items: _cubit.topicList.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  _cubit.setCurrentTopic(value);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  _buildQuestion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          R.string.your_question.tr(),
          style: TextStyle(
            color: R.color.black,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: R.color.grayBorder, width: 0.5),
              ),
              filled: true,
              hintStyle: TextStyle(color: R.color.grayBorder),
              hintText: "Bạn muốn hỏi bác sỹ điều gì?",
              fillColor: R.color.white),
          maxLines: 6,
        ),
      ],
    );
  }
}
