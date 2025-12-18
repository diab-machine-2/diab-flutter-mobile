import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/bloc/medicine/medicine_lesson/medicine_lesson_bloc.dart';

import '../../../res/R.dart';
import '../../app_setting/firebase_tracking/activity_list_tracking.dart';
import '../../modal/learning/learning_post_model.dart';
import '../../utils/navigation_util.dart';
import '../../utils/navigator_name.dart';
import '../../widgets/network_image_widget.dart';
import '../my_plan_screens/lesson_tab/lesson_detail/lesson_detail.dart';
import 'widgets/input_options_bottom_sheet.dart';
import 'package:medical/src/utils/utils.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _bloc = MedicineLessonBloc();
  int _currentIndex = 0;
  final double _lessonItemWidth = 240.0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // * Scroll listener
  void _onScroll() {
    final double currentScroll = _scrollController.position.pixels;
    final double eachItemWidth = _lessonItemWidth;

    int currentIndex = (currentScroll / eachItemWidth).round();
    setState(() {
      _currentIndex = currentIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop();
        return true;
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: R.color.white,
          appBar: AppBar(
            leading: IconButton(
                splashColor: R.color.transparent,
                highlightColor: R.color.transparent,
                icon: Icon(Icons.arrow_back, color: R.color.white),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
            title: Transform(
              transform: Matrix4.translationValues(-20, 0.0, 0.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  R.string.schedule_medicine.tr(),
                  style: TextStyle(color: R.color.white, fontSize: 20, fontWeight: FontWeight.w400),
                ),
              ),
            ),
            actions: [
              Center(
                child: InkWell(
                  onTap: () => Navigator.of(context).pushNamed(NavigatorName.medicine_tutorial),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      R.string.tutorial.tr(),
                      style: TextStyle(color: R.color.white, fontSize: 15, fontWeight: FontWeight.w400),
                    ),
                  ),
                ),
              ),
            ],
            backgroundColor: R.color.transparent,
            //No more green
            elevation: 0.0,
            //Shadow gone
            flexibleSpace: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [R.color.greenGradientMid, R.color.greenGradientBottom])),
            ),
          ),
          body: _buildContainer(),
        ),
      ),
    );
  }

  Widget _buildContainer() {
    return Container(
      color: R.color.backgroundColorNew,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBanner(),
              _buildDoYouKnow(),
              _buildNeedSupport(),
              const SizedBox(height: 12),
              _buildMedicineLessons(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBanner() {
    return Image.asset(R.drawable.medicine_banner, fit: BoxFit.fitWidth);
  }

  Widget _buildDoYouKnow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE4E4E7), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            R.string.do_you_know.tr(),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: R.color.color0xff111515,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            R.string.do_you_know_content.tr(),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Color(0xff5E6566),
            ),
          ),

          GestureDetector(
            onTap: () {
              InputOptionsBottomSheet.show(
                context,
                onCameraTap: () {
                  Navigator.of(context).pushNamed(NavigatorName.prescription_capture);
                },
                onHandTap: () {
                  Navigator.of(context).pushNamed(NavigatorName.medicine_search);
                },
              );
            },
            child: Container(
              margin: const EdgeInsets.only(top: 16),
              height: 48,
              decoration: BoxDecoration(
                color: R.color.mainColor,
                borderRadius: BorderRadius.circular(200),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.centerRight,
                  colors: [R.color.greenGradientTop, R.color.greenGradientBottom],
                ),
              ),
              child: Center(
                child: Text(
                  R.string.add_schedule_medicine.tr(),
                  style: TextStyle(color: R.color.white, fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNeedSupport() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          R.string.what_need_support.tr(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: R.color.color0xff111515,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Flexible(
              flex: 1,
              child: _buildNeedSupportItem(
                imageAsset: R.drawable.ic_mobile,
                text: R.string.use_schedule_medicine.tr(),
                onTap: () => _navigateToLessonDetail('495c2864-6243-47b5-e5c1-08d9f1cbf93f', 1),
              ),
            ),
            const SizedBox(width: 11),
            Flexible(
              flex: 1,
              child: _buildNeedSupportItem(
                imageAsset: R.drawable.ic_medicine_calendar,
                text: R.string.why_schedule_medicine.tr(),
                onTap: () => _navigateToLessonDetail('c1bb1875-5d2e-43d3-6869-08d9ef854092', 1),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNeedSupportItem({required String imageAsset, required String text, Function? onTap}) {
    return InkWell(
      onTap: () => onTap?.call(),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE4E4E7), width: 1.0),
        ),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Image.asset(imageAsset, width: 72, height: 72),
            const SizedBox(height: 8),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: R.color.color0xff111515,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicineLessons() {
    return BlocProvider.value(
      value: _bloc,
      child: BlocBuilder<MedicineLessonBloc, MedicineLessonState>(builder: (context, state) {
        if (state is MedicineLessonLoaded) {
          final lessons = state.lessons;
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(16.0)),
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE4E4E7), width: 1.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    R.string.knowledge_from_expert.tr(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: R.color.dark,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildListViewMedicineLessons(lessons),
                const SizedBox(height: 16),
                SizedBox(
                  height: 8,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (int i = 0; i < lessons.length; i++)
                          Container(
                            width: _currentIndex == i ? 16 : 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                              color: _currentIndex == i ? R.color.mainColor : Colors.grey,
                              borderRadius: BorderRadius.all(Radius.circular(4)),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        }
        // Hide when loading or error
        return SizedBox();
      }),
    );
  }

  Widget _buildListViewMedicineLessons(List<LessonModel> lessons) {
    return SizedBox(
      height: 263,
      child: ListView.separated(
        padding: const EdgeInsets.only(left: 12),
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return SizedBox(child: _buildLessonItem(lessons[index]));
        },
        separatorBuilder: (context, index) {
          return const SizedBox(width: 12);
        },
        itemCount: lessons.length,
      ),
    );
  }

  Widget _buildLessonItem(LessonModel lesson) {
    return SizedBox(
      height: 263,
      width: _lessonItemWidth,
      child: InkWell(
        onTap: () => _navigateToLessonDetail(lesson.id, lesson.type),
        borderRadius: BorderRadius.circular(12.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE4E4E7), width: 1.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NetWorkImageWidget(
                imageUrl: Utils.getImageUrl(lesson.image?.id),
                fit: BoxFit.cover,
                height: 150.0,
                width: double.infinity,
              ),
              const SizedBox(height: 10.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(
                  lesson.name,
                  maxLines: 2,
                  style: TextStyle(
                    color: R.color.textDark,
                    fontSize: 16,
                    height: 24 / 16,
                  ),
                ),
              ),

              const SizedBox(height: 12.0),
              Divider(
                height: 1,
                color: R.color.color0xffE5E5E5,
              ),

              // Actions
              SizedBox(
                height: 40,
                child: Center(
                  child: InkWell(
                    onTap: () {},
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(R.drawable.ic_lesson_share, width: 20.0, height: 20.0),
                        const SizedBox(width: 8.0),
                        Text(
                          R.string.share.tr(),
                          style: TextStyle(color: R.color.textDark, fontSize: 15.0),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPopupInputOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                R.string.input_options.tr(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: R.color.color0xff111515,
                ),
              ),
              const SizedBox(height: 24),
              _buildOptionItem(
                icon: R.drawable.ic_input_by_camera,
                title: R.string.input_by_camera.tr(),
                description: R.string.input_by_camera_description.tr(),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to camera feature
                },
              ),
              const SizedBox(height: 16),
              _buildOptionItem(
                icon: R.drawable.ic_input_by_hand,
                title: R.string.input_by_hand.tr(),
                description: R.string.input_by_hand_description.tr(),
                onTap: () {
                  Navigator.of(context).pushNamed(NavigatorName.medicine_search);
                },
              ),
              const SizedBox(height: 48),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionItem({
    required String icon,
    required String title,
    required String description,
    Function? onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => onTap?.call(),
      child: Container(
        padding: const EdgeInsets.all(16),
        height: 126,
        decoration: BoxDecoration(
          color: R.color.color0xffF4F7F7,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Image.asset(icon, width: 72, height: 72),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: R.color.color0xff111515,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(description,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: R.color.color0xff5E6566,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.chevron_right, size: 24),
          ],
        ),
      ),
    );
  }

  void _navigateToLessonDetail(String id, int type) async {
    ActivityListTracking.clickLessonItem(
      objectId: id,
      objectIndex: null,
      objectTitle: null,
    );

    await NavigationUtil.navigatePage(
      context,
      LessonDetailPage(
        lessonType: type,
        lessonId: id,
        onComplete: (_, __) {},
      ),
    );
  }
}
