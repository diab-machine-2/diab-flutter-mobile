import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/patient_info_response.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:medical/src/widgets/common_page.dart';
import 'package:medical/src/widgets/network_image_widget.dart';

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
    _cubit.getSharedProfile();
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
          child: BlocConsumer<SharedProfileCubit, SharedProfileState>(
            listener: (context, state) {
              if (state is SharedProfileLoading) {
                BotToast.showLoading();
              } else {
                BotToast.closeAllLoading();
              }
              if (state is SharedProfileFailure) {
                Message.showToastMessage(context, state.error);
              }
            },
            builder: (context, state) {
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 40, 16, 20),
                children: List.generate(
                    _cubit.sharedList.length,
                    (index) => _buildSingleProfile(
                          _cubit.sharedList[index],
                        )),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSingleProfile(PatientInfoResponseData? userData) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            clipBehavior: Clip.hardEdge,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: const NetWorkImageWidget(
              imageUrl: '',
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userData?.fullName ?? '',
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
              showPopup(context, userData: userData, onTap: () async {
                // TODO(Tuyen): Need code from userData
                await _cubit.stopSharing(code: '');
                _cubit.getSharedProfile();
                NavigationUtil.pop(context);
              });
            },
            child: Image.asset(
              R.drawable.ic_stop_sharing,
              width: 30,
              height: 30,
            ),
          ),
        ],
      ),
    );
  }

  void showPopup(
    context, {
    required PatientInfoResponseData? userData,
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
                        R.string.stop_sharing.tr(args: [
                          userData?.fullName ?? '',
                          '<<tên bệnh viện>>'
                        ]),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: R.color.textDark,
                            fontSize: 20,
                            fontWeight: FontWeight.w700),
                      ),
                      Text(
                        R.string.stop_sharing_description.tr(),
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
                                title: R.string.cancel.tr(),
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
                              title: R.string.confirm.tr(),
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
