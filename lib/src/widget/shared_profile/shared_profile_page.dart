import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/patient_info_response.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
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
    return Scaffold(
      body: BlocProvider(
        create: (context) => _cubit,
        child: BlocListener<SharedProfileCubit, SharedProfileState>(
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
          child: BlocBuilder<SharedProfileCubit, SharedProfileState>(
            builder: (context, state) {
              return _buildPage(context, state);
            },
          ),
        ),
      ),
    );
  }

  _buildPage(BuildContext context, SharedProfileState state) {
    return Column(
      children: [
        _buildAppBar(context),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            shrinkWrap: true,
            children: List.generate(
                _cubit.sharedList.length,
                (index) => _buildSingleProfile(
                      _cubit.sharedList[index],
                    )),
          ),
        ),
      ],
    );
  }

  _buildAppBar(BuildContext context) {
    return CustomAppBar(
      backgroundColor: R.color.transparent,
      title: Text(R.string.shared_profile_list.tr(),
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
            child: NetWorkImageWidget(
              imageUrl: userData?.avatar?.url ?? '',
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
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (userData?.nameOfAgency?.isNotEmpty == true)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(
                      userData?.nameOfAgency ?? '',
                      style: const TextStyle(
                        color: Color(0xff888C9F),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                if (userData?.sharedDate != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(
                      R.string.shared_date.tr(args: [DateFormat('dd/MM/yyyy').format(userData!.sharedDate)]),
                      style: const TextStyle(
                        color: Color(0xff888C9F),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              showPopup(context, userData: userData, onTap: () async {
                await _cubit.stopSharing(code: userData?.referralCode ?? '');
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
                padding: const EdgeInsets.only(top: 16, bottom: 16, left: 16, right: 16),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(width: 20),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Image.asset(R.drawable.ic_close, width: 28, height: 28),
                          ),
                        ],
                      ),
                      Image.asset(R.drawable.img_sharing_profile),
                      const SizedBox(height: 28),
                      Text(
                        R.string.stop_sharing.tr(args: [userData?.fullName ?? '']),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: R.color.textDark, fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        R.string.stop_sharing_description.tr(),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: R.color.textDark, fontSize: 16, fontWeight: FontWeight.w400),
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
