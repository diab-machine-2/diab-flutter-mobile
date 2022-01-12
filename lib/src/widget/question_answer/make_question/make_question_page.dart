import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
//import 'package:medical/src/widgets/custom_dropdown.dart';
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
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildTopic(),
                        SizedBox(height: 8),
                        _buildQuestion(),
                        Spacer(),
                      ],
                    ),
                  ),
                  _buildSendButton(),
                ],
              ),
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
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: R.color.grayBorder, style: BorderStyle.solid, width: 1),
            color: R.color.white,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isDense: true,
              isExpanded: true,
              value: _cubit.currentTopic,
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
        // Container(
        //   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        //   decoration: BoxDecoration(
        //     borderRadius: BorderRadius.circular(6),
        //     border: Border.all(color: R.color.grayBorder, style: BorderStyle.solid, width: 1),
        //     color: R.color.white,
        //   ),
        //   child: CustomDropdownButton<String>(
        //     isDense: true,
        //     isExpanded: true,
        //     value: _cubit.currentTopic,
        //     icon: Icon(
        //       Icons.keyboard_arrow_down,
        //       size: 20,
        //       color: R.color.textDark,
        //     ),
        //     hint: Text(
        //       R.string.select_topic.tr(),
        //       style: TextStyle(
        //         color: R.color.textDark,
        //         fontSize: 16,
        //         fontWeight: FontWeight.w400,
        //       ),
        //     ),
        //     items: _cubit.topicList.map((String value) {
        //       return CustomDropdownMenuItem<String>(
        //         value: value,
        //         child: Text(value),
        //       );
        //     }).toList(),
        //     onChanged: (value) {
        //       _cubit.setCurrentTopic(value);
        //     },
        //   ),
        // ),
        SizedBox(height: 8),
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
                borderRadius: BorderRadius.circular(8),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: R.color.grayBorder, width: 1),
              ),
              filled: true,
              hintStyle: TextStyle(color: R.color.gray),
              hintText: "Bạn muốn hỏi bác sỹ điều gì?",
              fillColor: R.color.white),
          maxLines: 6,
        ),
      ],
    );
  }

  _buildSendButton() {
    return Container(
        height: 48,
        width: 300,
        margin: EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: R.color.mainColor,
            borderRadius: BorderRadius.circular(200),
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.centerRight,
                colors: [R.color.greenGradientTop, R.color.greenGradientBottom])),
        child: Center(
          child: Text(R.string.send_question.tr(),
              style: TextStyle(color: R.color.white, fontSize: 16, fontWeight: FontWeight.w600)),
        ));
  }
}
