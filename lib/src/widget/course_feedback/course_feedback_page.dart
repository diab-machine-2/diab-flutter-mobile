import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widgets/background_page.dart';
import 'package:medical/src/widgets/button_widget.dart';

import 'course_feedback.dart';

class CourseFeedbackPage extends StatefulWidget {
  final String lessonId;

  const CourseFeedbackPage({Key? key, required this.lessonId})
      : super(key: key);

  @override
  _CourseFeedbackPageState createState() => _CourseFeedbackPageState();
}

class _CourseFeedbackPageState extends State<CourseFeedbackPage> {
  TextEditingController _commentController = TextEditingController();
  late CourseFeedbackCubit _cubit;

  @override
  void initState() {
    // TODO: implement initState
    AppRepository repository = AppRepository();
    _cubit = CourseFeedbackCubit(repository);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: R.color.grey200,
      body: BlocProvider(
        create: (context) => _cubit,
        child: BlocConsumer<CourseFeedbackCubit, CourseFeedbackState>(
          listener: (context, state) {
            if (state is CourseFeedbackFailure)
              Message.showToastMessage(context, state.error);
            if (state is CourseFeedbackDone) {
              NavigationUtil.pop(context);
            }
          },
          builder: (context, state) {
            if (state is CourseFeedbackLoading) {
              BotToast.showLoading();
            } else {
              BotToast.closeAllLoading();
            }
            return buildPage(context, state);
          },
        ),
      ),
    );
  }

  Widget buildPage(BuildContext context, CourseFeedbackState state) {
    return BackgroundPage(
      background: R.drawable.bg_welcome,
      child: Container(
        padding: EdgeInsets.all(16.h),
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  SizedBox(
                    height: 30.h,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          R.string.evaluation_of_lesson.tr(),
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: R.color.textDark,
                              height: 1.4,
                              letterSpacing: 0.4),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          NavigationUtil.pop(context);
                        },
                        child: Icon(
                          Icons.close,
                          size: 30.h,
                          color: R.color.textDark,
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 20.h),
                  Image.asset(R.drawable.img_course_feedback, height: 150.h),
                  SizedBox(height: 20.h),
                  Text(
                    R.string.rate_how_you_feel.tr(),
                    style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                        color: R.color.textDark,
                        height: 1.37,
                        letterSpacing: 0.4),
                    maxLines: 2,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20.h),
                  Center(
                    child: RatingBar.builder(
                      itemSize: 40.h,
                      initialRating: 0,
                      minRating: 0,
                      direction: Axis.horizontal,
                      allowHalfRating: false,
                      itemCount: 5,
                      itemPadding: EdgeInsets.symmetric(horizontal: 10.h),
                      itemBuilder: (context, _) => Icon(
                        CupertinoIcons.star,
                        color: R.color.accentColor,
                      ),
                      onRatingUpdate: (rating) {
                        _cubit.rateFeedback(rating.toInt());
                      },
                    ),
                  ),
                  SizedBox(height: 45.h),
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: R.color.white,
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.chat_outlined,
                              size: 20.sp,
                              color: R.color.textDark,
                            ),
                            SizedBox(width: 12.h),
                            Text(
                              R.string.feeling.tr(),
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: R.color.textDark,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 15.h,
                        ),
                        TextField(
                          textInputAction: TextInputAction.go,
                          maxLines: 5,
                          minLines: 1,
                          keyboardType: TextInputType.multiline,
                          expands: false,
                          cursorColor: R.color.accentColor,
                          controller: _commentController,
                          decoration: InputDecoration(
                            hintText: R.string.enter_your_feeling.tr(),
                            hintStyle:
                                TextStyle(color: R.color.gray, fontSize: 16.sp),
                            focusColor: R.color.accentColor,
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: R.color.gray),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: R.color.gray),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
                width: 200.w,
                margin: EdgeInsets.only(bottom: 10.h),
                child: ButtonWidget(
                    title: R.string.sent_report.tr(),
                    onPressed: _cubit.rate == 0
                        ? null
                        : () {
                            _cubit.sendFeedback(
                                widget.lessonId, _commentController.text);
                          })),
          ],
        ),
      ),
    );
  }
}
