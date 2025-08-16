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
import 'onboarding_model.dart';

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
  // Tab Lịch uống thuốc
  final List<MedicineScheduleItem> _medicineSchedules = [
    MedicineScheduleItem(
      dayInWeek: "T4",
      date: "21/08",
      isToday: true,
      medicineSessions: [
        MedicineSession(
            name: "Buổi sáng",
            sessionType: Session.MORNING,
            time: "08:30",
            dosages: [
              DosageInSession(
                  name: "Metformin (Metformin Stella 1000mg) 1000 mg",
                  quantity: 1,
                  unit: "viên",
                  isUsed: false,
                  timeOfUse: "Trước ăn"
              )
            ]
        ),
        MedicineSession(
            name: "Buổi tối",
            sessionType: Session.NIGHT,
            time: "19:30",
            dosages: [
              DosageInSession(
                  name: "Metformin (Metformin Stella 1000mg) 1000 mg",
                  quantity: 1,
                  unit: "viên",
                  isUsed: false,
                  timeOfUse: "Sau ăn"
              ),
              DosageInSession(
                  name: "Fluvastatin (Autifan 40) 40mg",
                  quantity: 1,
                  unit: "viên",
                  isUsed: false,
                  timeOfUse: "Sau ăn"
              ),
            ]
        ),
      ]
    )
  ];
  // Tab Đơn thuốc
  final List<PrescriptionItem> _prescriptionItems = [];

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
        Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
          NavigatorName.tabbar,
          (route) => false, // This removes all routes from stack
        );
        return false;
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
                  Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
                    NavigatorName.tabbar,
                    (route) => false,
                  );
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
          bottomNavigationBar: BottomNavigationBar(
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.medication),
                label: "Lịch uống thuốc",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add_circle, size: 32),
                label: "",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history),
                label: "Đơn thuốc",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContainer() {
    if (_medicineSchedules.isEmpty && _prescriptionItems.isEmpty) {
      // UI no schedule of medicine
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
    } else {
      return _buildScheduleAndPrescription();
    }
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
            onTap: () => _showPopupInputOptions(context),
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
                onTap: () => _navigateToLessonDetail('142c710d-8aed-463f-c86b-08d9f022ae7d', 1),
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
                imageUrl: lesson.image?.url,
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

  /*-----------------UI Lịch uống thuốc và Đơn thuốc*/
  Widget _buildScheduleAndPrescription() {
    return Column(
      children: [
        _buildDateSelector(),
        Expanded(
          child: ListView(
            children: [
              _buildSession(
                "Buổi sáng",
                [
                  MedicineCard(
                    condition: "Bệnh đái tháo đường không phụ thuộc insulin",
                    time: "08:30",
                    medicineName: "Gliclazid (Glycinorm-80)",
                    dosage: "80mg",
                    instruction: "1 viên - Trước ăn",
                    isTaken: false,
                  ),
                ],
              ),
              _buildSession(
                "Buổi tối",
                [
                  MedicineCard(
                    condition: "Bệnh đái tháo đường không phụ thuộc insulin",
                    time: "19:30",
                    medicineName: "Metformin (Metformin Stella 1000mg)",
                    dosage: "1000mg",
                    instruction: "1 viên - Sau ăn",
                    isTaken: true,
                  ),
                  MedicineCard(
                    condition: "",
                    time: "",
                    medicineName: "Fluvastatin (Autifan 40)",
                    dosage: "40mg",
                    instruction: "1 viên - Sau ăn",
                    note: "Ghi chú: Uống lúc 20h",
                    isTaken: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return Column(
      children: [
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.arrow_back_ios)),
            const Text("Hôm nay - 21/08/2024"),
            IconButton(onPressed: () {}, icon: const Icon(Icons.arrow_forward_ios)),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildDateItem("T2", "19/08", false),
            _buildDateItem("T3", "20/08", false),
            _buildDateItem("T4", "21/08", true),
            _buildDateItem("T5", "22/08", false),
            _buildDateItem("T6", "23/08", false),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildDateItem(String day, String date, bool selected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: selected ? Colors.teal : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(day,
              style: TextStyle(
                  color: selected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold)),
          Text(date,
              style: TextStyle(
                color: selected ? Colors.white : Colors.black,
              )),
        ],
      ),
    );
  }

  Widget _buildSession(String title, List<Widget> medicines) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ExpansionTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        children: medicines,
      ),
    );
  }
}

class MedicineCard extends StatelessWidget {
  final String condition;
  final String time;
  final String medicineName;
  final String dosage;
  final String instruction;
  final String? note;
  final bool isTaken;

  const MedicineCard({
    super.key,
    required this.condition,
    required this.time,
    required this.medicineName,
    required this.dosage,
    required this.instruction,
    this.note,
    required this.isTaken,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (condition.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(condition, style: const TextStyle(color: Colors.orange)),
                Text(time, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          const SizedBox(height: 6),
          Text("$medicineName $dosage",
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(instruction, style: const TextStyle(color: Colors.grey)),
              Row(
                children: [
                  Icon(isTaken ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: isTaken ? Colors.teal : Colors.grey),
                  const SizedBox(width: 4),
                  Text(isTaken ? "Đã dùng" : "Chưa dùng",
                      style: TextStyle(
                          color: isTaken ? Colors.teal : Colors.grey)),
                ],
              )
            ],
          ),
          if (note != null) ...[
            const SizedBox(height: 6),
            Text(note!, style: const TextStyle(color: Colors.grey)),
          ]
        ],
      ),
    );
  }
}
