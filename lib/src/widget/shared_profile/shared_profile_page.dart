import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:medical/src/widgets/common_page.dart';

import 'shared_profile.dart';

class SharedProfilePage extends StatefulWidget {
  const SharedProfilePage();

  @override
  _SharedProfilePageState createState() => _SharedProfilePageState();
}

class _SharedProfilePageState extends State<SharedProfilePage> {
  late final SharedProfileCubit _cubit;

  @override
  void initState() {
    super.initState();
    final AppRepository appRepository = AppRepository();
    _cubit = SharedProfileCubit(appRepository);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _cubit,
      child: Scaffold(
        body: CommonPage(
          background: R.drawable.bg_lesson_detail,
          title: R.string.shared_profile_list.tr(),
          showCloseBackButton: true,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 40, 16, 20),
            children: List.generate(
              3,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(R.drawable.ic_account, width: 56, height: 56),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lê Hương Trúc',
                            style: TextStyle(
                              color: R.color.grey_1,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Bệnh viện Hồng Ngọc',
                            style: TextStyle(
                              color: Color(0xff888C9F),
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 1),
                          const Text(
                            'Ngày chia sẻ: 25/12/2021',
                            style: TextStyle(
                              color: Color(0xff888C9F),
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        showPopup(context, onTap: () {
                          // TODO(Tuyen): Call API to stop sharing
                          NavigationUtil.pop(context);
                        });
                      },
                      child: Image.asset(
                        R.drawable.ic_stop_sharing,
                        width: 24,
                        height: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void showPopup(
    context, {
    required VoidCallback onTap,
  }) {
    showDialog(
      barrierColor: R.color.color0xff003F38.withOpacity(0.5),
      context: context,
      barrierDismissible: true,
      builder: (_) => GestureDetector(
        onTap: () {
          NavigationUtil.pop(context);
        },
        child: Scaffold(
          backgroundColor: R.color.transparent,
          body: Center(
            child: GestureDetector(
              onTap: () {},
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      R.color.white,
                      R.color.main_6,
                    ],
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Image.asset(R.drawable.img_sharing_profile),
                      const SizedBox(height: 24),
                      Text(
                        'Bạn muốn dừng chia sẻ profile cho bác sĩ <<tên bác sĩ>> thuộc <<tên bệnh viện>>?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: R.color.textDark,
                            fontSize: 20,
                            fontWeight: FontWeight.w700),
                      ),
                      Text(
                        'Sau khi dừng chia sẻ, bác sĩ sẽ không thể theo dõi hồ sơ của bạn nữa.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: R.color.textDark,
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 130.w,
                            height: 43,
                            child: ButtonWidget(
                                title: 'Huỷ',
                                textSize: 14,
                                backgroundColor: R.color.grayBorder,
                                textColor: R.color.textDark,
                                onPressed: () {
                                  NavigationUtil.pop(context);
                                }),
                          ),
                          const SizedBox(width: 14),
                          SizedBox(
                            width: 130.w,
                            height: 43,
                            child: ButtonWidget(
                              title: 'Xác nhận',
                              textSize: 14,
                              onPressed: onTap,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
