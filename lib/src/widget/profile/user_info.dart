import 'dart:async';
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_observer/Observer.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:medical/src/modal/user/motivation_model.dart';
import 'package:medical/src/modal/user/user_model.dart';
import 'package:medical/src/repo/login/login_client.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:medical/src/utils/length_limit_text_field.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/Bmi/widget/add_bmi.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widget/profile/address.dart';
import 'package:medical/src/widgets/select_bottom_sheet_widget.dart';
import 'package:medical/src/widgets/user_icon_widget.dart';
import 'package:permission_handler/permission_handler.dart';

import 'widgets/birth_day_picker.dart';
import 'widgets/diabetes_status_date_picker.dart';
import 'widgets/diabetes_status_picker.dart';
import 'widgets/email_validate.dart';
import 'widgets/gender_picker.dart';
import 'widgets/motivation_popup_widget.dart';

class ProfileInfoController extends StatefulWidget {
  @override
  _ProfileInfoControllerState createState() => _ProfileInfoControllerState();
}

class _ProfileInfoControllerState extends State<ProfileInfoController>
    with Observer {
  MotivationModel? motivation;

  @override
  void initState() {
    super.initState();
    Observable.instance.addObserver(this);

    loadMotivation();
    TrackingManager.analytics.setCurrentScreen(screenName: 'Update Profile');
  }

  loadMotivation() async {
    final result = await UserClient().fetchMotivationDiary(1);
    motivation = result.models.isEmpty ? null : result.models.first;
    setState(() {});
  }

  @override
  void update(
      Observable observable, String? notifyName, Map<dynamic, dynamic>? map) {
    if (notifyName == 'motivation_change') {
      loadMotivation();
    }
    if (notifyName == 'user_info_change') {
      setState(() {});
    }
  }

  @override
  void dispose() {
    Observable.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = AppSettings.userInfo!;
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
            body: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [
                    R.color.color0xFFFDC798.withOpacity(0.3),
                    R.color.greenbg.withOpacity(0.9),
                  ],
                  begin: const FractionalOffset(1, 1),
                  end: const FractionalOffset(0.9, 0.5),
                  stops: const [0.0, 1.0])),
          child: Stack(children: [
            Image.asset(R.drawable.bg_profile),
            Column(children: [
              CustomAppBar(
                backgroundColor: R.color.transparent,
                title: Text(R.string.personal_info.tr(),
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: R.color.textDark)),
                leadingIcon: IconButton(
                    splashColor: R.color.transparent,
                    highlightColor: R.color.transparent,
                    icon: Icon(Icons.arrow_back, color: R.color.textDark),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
              ),
              Expanded(
                child: SafeArea(
                  top: false,
                  child: ListView(
                      padding: const EdgeInsets.only(
                          bottom: 16, left: 16, right: 16),
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                showActionSheet(context);
                              },
                              child: Container(
                                color: R.color.transparent,
                                child: Stack(
                                    alignment: AlignmentDirectional.bottomEnd,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          clipBehavior: Clip.hardEdge,
                                          decoration: BoxDecoration(
                                              color: R.color.mainColor,
                                              borderRadius:
                                                  BorderRadius.circular(80)),
                                          child: user.imageUrl!.url == null
                                              ? Icon(Icons.person,
                                                  size: 160,
                                                  color: R.color.white)
                                              : Image.network(
                                                  user.imageUrl!.url!,
                                                  width: 160,
                                                  height: 160),
                                        ),
                                      ),
                                      Image.asset(R.drawable.ic_camera_picker,
                                          width: 50, height: 50)
                                    ]),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (motivation != null)
                          Container(
                              decoration: BoxDecoration(
                                  color: R.color.white,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 16, left: 16, right: 16),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                    R.string.my_motivation.tr(),
                                                    style: TextStyle(
                                                        color: R.color.black,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontSize: 16)),
                                                GestureDetector(
                                                  onTap: () {
                                                    _showDialogUpdateMotivation(
                                                        motivation);
                                                  },
                                                  child: Container(
                                                    color: R.color.transparent,
                                                    child: Row(children: [
                                                      Image.asset(
                                                          R.drawable.ic_edit,
                                                          width: 16,
                                                          height: 16),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                          R.string.chinh_sua
                                                              .tr(),
                                                          style: TextStyle(
                                                              color: R.color
                                                                  .mainColor,
                                                              fontSize: 16))
                                                    ]),
                                                  ),
                                                )
                                              ]),
                                          const SizedBox(height: 16),
                                          Text('“${motivation!.content}”',
                                              style: TextStyle(
                                                  color: R.color.textDark,
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 16)),
                                        ]),
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                      height: 1,
                                      color: R.color.color0xffE5E5E5),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.pushNamed(context,
                                                  NavigatorName.motivation);
                                            },
                                            child: Container(
                                              color: R.color.transparent,
                                              child: Center(
                                                child: Text(
                                                    R.string.view_log.tr(),
                                                    style: TextStyle(
                                                        color:
                                                            R.color.mainColor,
                                                        fontSize: 16)),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                            height: 46,
                                            width: 1,
                                            color: R.color.color0xffE5E5E5),
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () {
                                              _showDialogUpdateMotivation(null);
                                            },
                                            child: Container(
                                              color: R.color.transparent,
                                              child: Center(
                                                child: Text(
                                                    R.string.new_motivation
                                                        .tr(),
                                                    style: TextStyle(
                                                        color:
                                                            R.color.mainColor,
                                                        fontSize: 16)),
                                              ),
                                            ),
                                          ),
                                        )
                                      ])
                                ],
                              ))
                        else
                          GestureDetector(
                            onTap: () {
                              _showDialogUpdateMotivation(null);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: R.color.transparent,
                                image: DecorationImage(
                                    image: AssetImage(R.drawable.bg_dong_luc),
                                    fit: BoxFit.fill),
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(R.string.my_motivation.tr(),
                                        style: TextStyle(
                                            color: R.color.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16)),
                                    const SizedBox(height: 8),
                                    Text(R.string.new_motivaiton_suggest.tr(),
                                        style: TextStyle(
                                            color: R.color.white,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 16)),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 16, bottom: 8),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              height: 40,
                                              padding: const EdgeInsets.only(
                                                  left: 16, right: 16),
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: R.color.white,
                                                      width: 2),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20)),
                                              child: Row(
                                                children: [
                                                  Icon(Icons.add,
                                                      color: R.color.white,
                                                      size: 28),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                      '${R.string.enter_motivation.tr()}  ',
                                                      style: TextStyle(
                                                          color: R.color.white,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontSize: 16)),
                                                ],
                                              ),
                                            )
                                          ]),
                                    )
                                  ]),
                            ),
                          ),
                        _buildCardLayout(
                            title: R.string.general_info.tr(),
                            children: [
                              buildItem(
                                image: R.drawable.ic_person,
                                title: user.fullName!,
                                subTitle:
                                    R.string.last_name_and_first_name.tr(),
                                subIcon: Image.asset(R.drawable.ic_right,
                                    width: 18, height: 18),
                                callback: () {
                                  _showDialogUpdateName();
                                },
                              ),
                              buildItem(
                                image: R.drawable.ic_birthday,
                                title: convertToUTC(
                                    user.dateOfBirth!, 'dd/MM/yyyy'),
                                subTitle: R.string.ngay_sinh.tr(),
                                subIcon: Image.asset(R.drawable.ic_right,
                                    width: 18, height: 18),
                                callback: () {
                                  _showDialogUpdateBirthday();
                                },
                              ),
                              buildItem(
                                image: R.drawable.ic_gender,
                                title:
                                    user.gender == null || user.gender!.isEmpty
                                        ? R.string.updating.tr()
                                        : user.gender!,
                                subTitle: R.string.gioi_tinh.tr(),
                                subIcon: Image.asset(R.drawable.ic_right,
                                    width: 18, height: 18),
                                callback: () {
                                  _showDialogUpdateGender();
                                },
                              ),
                              buildItem(
                                icon: R.drawable.ic_user_job,
                                title: 'Giáo viên',
                                subTitle: 'Nghề nghiệp',
                                subIcon: Image.asset(R.drawable.ic_right,
                                    width: 18, height: 18),
                                callback: () {
                                  // TODO(Tuyen): Update Nghề nghiệp
                                  showActionFilter(
                                      context: context,
                                      builder: (context) {
                                        return SelectBottomSheetWidget(
                                          title: 'Chọn nghề nghiệp',
                                          selectedList: [],
                                          elementList: [],
                                          onSelected: (typeList) {
                                            if (typeList.isNotEmpty) {}
                                          },
                                        );
                                      });
                                },
                              ),
                              buildItem(
                                icon: R.drawable.ic_user_education,
                                title: 'Đại học',
                                subTitle: 'Trình độ văn hoá',
                                subIcon: Image.asset(R.drawable.ic_right,
                                    width: 18, height: 18),
                                callback: () {
                                  // TODO(Tuyen): Update Trình độ văn hoá
                                  showActionFilter(
                                      context: context,
                                      builder: (context) {
                                        return SelectBottomSheetWidget(
                                          title: 'Chọn học vấn',
                                          selectedList: [],
                                          elementList: [],
                                          onSelected: (typeList) {
                                            if (typeList.isNotEmpty) {}
                                          },
                                        );
                                      });
                                },
                              ),
                            ]),
                        _buildCardLayout(
                            title: R.string.pathological_info.tr(),
                            children: [
                              buildItem(
                                image: R.drawable.ic_folder,
                                title:
                                    user.diabetesName ?? R.string.updating.tr(),
                                subTitle: R.string.loai_benh.tr(),
                                callback: () {
                                  _showDialogUpdateDiabetesStatus();
                                },
                              ),
                              buildItem(
                                image: R.drawable.ic_year,
                                title: convertToUTC(
                                    user.diabetesDate ?? 0, 'yyyy'),
                                subTitle: R.string.year_illness_start.tr(),
                                callback: () {
                                  _showDialogUpdateDiabetesStatusDate();
                                },
                              )
                            ]),
                        _buildCardLayout(
                          title: R.string.body_info.tr(),
                          children: [
                            buildItem(
                              image: R.drawable.ic_kg,
                              title: user.weight == null
                                  ? R.string.not_updated_yet.tr()
                                  : '${user.weight!.round()} kg',
                              subTitle: R.string.can_nang.tr(),
                              callback: () {
                                showDialogWeight();
                              },
                            ),
                            buildItem(
                              image: R.drawable.ic_ruler_fill,
                              title: user.height == null
                                  ? R.string.not_updated_yet.tr()
                                  : '${user.height!.round()} cm',
                              subTitle: R.string.chieu_cao.tr(),
                              callback: () {
                                showDialogHeight();
                              },
                            ),
                            buildItem(
                              icon: R.drawable.ic_user_bmi,
                              title: '27.2',
                              subTitle: 'BMI',
                              callback: () {},
                            ),
                          ],
                        ),
                        _buildCardLayout(
                          title: 'Tiêu chí chọn huấn luyện viên sức khỏe',
                          description:
                              'Hãy mô tả chi tiết hơn về bản thân để diaB tìm huấn luyện viên phù hợp với bạn',
                          children: [
                            buildItem(
                              image: R.drawable.ic_person,
                              title: 'Hướng ngoại',
                              subTitle: 'Tính cách',
                              subIcon: Image.asset(R.drawable.ic_right,
                                  width: 18, height: 18),
                              callback: () {
                                // TODO(Tuyen): Update Tính cách
                                showActionFilter(
                                    context: context,
                                    builder: (context) {
                                      return SelectBottomSheetWidget(
                                        title: 'Chọn tính cách',
                                        selectedList: [],
                                        elementList: [],
                                        onSelected: (typeList) {
                                          if (typeList.isNotEmpty) {}
                                        },
                                      );
                                    });
                              },
                            ),
                            buildItem(
                              icon: R.drawable.ic_user_habit,
                              title: 'Chơi game, đọc sách',
                              subTitle: 'Sở thích cá nhân',
                              subIcon: Image.asset(R.drawable.ic_right,
                                  width: 18, height: 18),
                              callback: () {
                                // TODO(Tuyen): Update Sở thích cá nhân
                                showActionFilter(
                                    context: context,
                                    builder: (context) {
                                      return SelectBottomSheetWidget(
                                        title: 'Chọn sở thích',
                                        selectedList: [],
                                        elementList: [],
                                        onSelected: (typeList) {
                                          if (typeList.isNotEmpty) {}
                                        },
                                      );
                                    });
                              },
                            ),
                            buildItem(
                              icon: R.drawable.ic_user_exercise,
                              title: 'Cầu lông, xe đạp',
                              subTitle: 'Môn thể thao yêu thích',
                              subIcon: Image.asset(R.drawable.ic_right,
                                  width: 18, height: 18),
                              callback: () {
                                // TODO(Tuyen): Update Môn thể thao yêu thích
                                showActionFilter(
                                    context: context,
                                    builder: (context) {
                                      return SelectBottomSheetWidget(
                                        title: 'Chọn môn thể thao',
                                        selectedList: [],
                                        elementList: [],
                                        onSelected: (typeList) {
                                          if (typeList.isNotEmpty) {}
                                        },
                                      );
                                    });
                              },
                            ),
                            buildItem(
                              icon: R.drawable.ic_user_mental_exercise,
                              title: 'Không',
                              subTitle: 'Thực hành tâm thức',
                              subIcon: Image.asset(R.drawable.ic_right,
                                  width: 18, height: 18),
                              callback: () {
                                // TODO(Tuyen): Update Thực hành tâm thức
                                showActionFilter(
                                    context: context,
                                    builder: (context) {
                                      return SelectBottomSheetWidget(
                                        title: 'Chọn thực hành tâm thức',
                                        selectedList: [],
                                        elementList: [],
                                        onSelected: (typeList) {
                                          if (typeList.isNotEmpty) {}
                                        },
                                      );
                                    });
                              },
                            ),
                            buildItem(
                              icon: R.drawable.ic_user_religion,
                              title: 'Không',
                              subTitle: 'Tôn giáo',
                              subIcon: Image.asset(R.drawable.ic_right,
                                  width: 18, height: 18),
                              callback: () {
                                // TODO(Tuyen): Update Tôn giáo
                                showActionFilter(
                                    context: context,
                                    builder: (context) {
                                      return SelectBottomSheetWidget(
                                        title: 'Chọn tôn giáo',
                                        selectedList: [],
                                        elementList: [],
                                        onSelected: (typeList) {
                                          if (typeList.isNotEmpty) {}
                                        },
                                      );
                                    });
                              },
                            ),
                            buildItem(
                              icon: R.drawable.ic_user_in_diet,
                              title: 'Không',
                              subTitle: 'Ăn chay',
                              subIcon: Image.asset(R.drawable.ic_right,
                                  width: 18, height: 18),
                              callback: () {
                                // TODO(Tuyen): Update Ăn chay
                                showActionFilter(
                                    context: context,
                                    builder: (context) {
                                      return SelectBottomSheetWidget(
                                        title: 'Chọn ăn chay',
                                        selectedList: [],
                                        elementList: [],
                                        onSelected: (typeList) {
                                          if (typeList.isNotEmpty) {}
                                        },
                                      );
                                    });
                              },
                            ),
                            buildItem(
                              icon: R.drawable.ic_user_schedule,
                              title: 'Buổi sáng; Bao gồm thứ 7',
                              subTitle:
                                  'Khung giờ làm việc với huấn luyện viên',
                              subIcon: Image.asset(R.drawable.ic_right,
                                  width: 18, height: 18),
                              callback: () {
                                // TODO(Tuyen): Update Khung giờ làm việc với huấn luyện viên
                                showActionFilter(
                                    context: context,
                                    builder: (context) {
                                      return SelectBottomSheetWidget(
                                        title:
                                            'Chọn khung giờ trao đổi với coach ưa thích',
                                        selectedList: [],
                                        elementList: [],
                                        onSelected: (typeList) {
                                          if (typeList.isNotEmpty) {}
                                        },
                                      );
                                    });
                              },
                            ),
                          ],
                        ),
                        _buildCardLayout(
                          title: 'Cơ sở dịch vụ đã giới thiệu',
                          children: [
                            buildItem(
                              icon: R.drawable.ic_user_hospital,
                              title: 'Bệnh viện Hồng Ngọc',
                              subTitle: 'Bệnh viện / Phòng khám',
                              callback: () {},
                            ),
                            buildItem(
                              icon: R.drawable.ic_user_doctor,
                              title: 'Đặng Vân Nga',
                              subTitle: 'Bác sĩ giới thiệu',
                              callback: () {},
                            ),
                          ],
                        ),
                        _buildCardLayout(
                          title: R.string.contact_info.tr(),
                          children: [
                            buildItem(
                              image: R.drawable.ic_phone_info,
                              title: user.phoneNumber!,
                              subTitle: R.string.phone_number_1.tr(),
                              subIcon: Image.asset(R.drawable.ic_ok,
                                  width: 24, height: 24),
                            ),
                            buildItem(
                              image: R.drawable.ic_phone_info,
                              title: user.secondPhoneNumber == null ||
                                      user.secondPhoneNumber!.isEmpty
                                  ? R.string.not_updated_yet.tr()
                                  : user.secondPhoneNumber!,
                              subTitle: R.string.phone_number_2.tr(),
                              callback: () {
                                _showDialogUpdatePhone2();
                              },
                            ),
                            buildItem(
                              image: R.drawable.ic_email,
                              title: user.isLinkedGoogle == true
                                  ? (user.googleEmail ?? '')
                                  : (user.email == null || user.email!.isEmpty
                                      ? R.string.not_updated_yet.tr()
                                      : user.email!),
                              subTitle: R.string.email.tr(),
                              callback: () {
                                if (user.isLinkedGoogle == true) {
                                  return;
                                }
                                _showDialogUpdateEmail();
                              },
                            ),
                            buildItem(
                                image: R.drawable.ic_location,
                                title: ((user.address ?? '') +
                                            (user.address == null ||
                                                    user.address!.isEmpty
                                                ? ''
                                                : ', ') +
                                            (user.ward == null
                                                ? ''
                                                : user.ward!.name!) +
                                            (user.ward == null ||
                                                    user.ward!.name!.isEmpty
                                                ? ''
                                                : ', ') +
                                            (user.district == null
                                                ? ''
                                                : user.district!.name!) +
                                            (user.district == null ||
                                                    user.district!.name!.isEmpty
                                                ? ''
                                                : ', ') +
                                            (user.province == null
                                                ? ''
                                                : user.province!.name!))
                                        .isEmpty
                                    ? R.string.not_updated_yet.tr()
                                    : ((user.address ?? '') +
                                        (user.address == null ||
                                                user.address!.isEmpty
                                            ? ''
                                            : ', ') +
                                        (user.ward == null
                                            ? ''
                                            : user.ward!.name!) +
                                        (user.ward == null ||
                                                user.ward!.name!.isEmpty
                                            ? ''
                                            : ', ') +
                                        (user.district == null
                                            ? ''
                                            : user.district!.name!) +
                                        (user.district == null ||
                                                user.district!.name!.isEmpty
                                            ? ''
                                            : ', ') +
                                        (user.province == null
                                            ? ''
                                            : user.province!.name!)),
                                subTitle: R.string.address.tr(),
                                callback: () {
                                  _showDialogUpdateAddress();
                                }),
                            buildItem(
                              image: R.drawable.ic_google,
                              title: user.isLinkedGoogle == null ||
                                      !user.isLinkedGoogle!
                                  ? R.string.not_connected_yet.tr()
                                  : user.fullName!,
                              subTitle: 'Google',
                              subIcon: CupertinoSwitch(
                                activeColor: R.color.mainColor,
                                value: user.isLinkedGoogle ?? false,
                                onChanged: (value) {
                                  print(value);
                                  linkedGoogle();
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () {
                            _showDialogLogout();
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                  color: R.color.white,
                                  borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.all(16),
                              child: Row(children: [
                                Image.asset(R.drawable.ic_logout,
                                    width: 33, height: 33),
                                const SizedBox(width: 12),
                                Text(
                                  R.string.logout.tr(),
                                  style: TextStyle(
                                    color: R.color.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                )
                              ])),
                        )
                      ]),
                ),
              )
            ]),
          ]),
        )));
  }

  Widget buildItem({
    String? image,
    String? icon,
    required String title,
    required String subTitle,
    Widget? subIcon,
    VoidCallback? callback,
  }) {
    return GestureDetector(
      onTap: callback,
      child: Container(
        color: R.color.transparent,
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (image != null)
                Image.asset(image, width: 33, height: 33)
              else
                UserIconWidget(
                  icon: icon!,
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                            color: R.color.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subTitle,
                        style: TextStyle(
                          color: R.color.captionColorGray,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      )
                    ]),
              )
            ]),
          ),
          if (subIcon != null) subIcon
        ]),
      ),
    );
  }

  Widget _buildCardLayout({
    required List<Widget> children,
    required String title,
    String description = '',
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: R.color.white,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          title,
          style: TextStyle(
            color: R.color.black,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Visibility(
          visible: description.isNotEmpty,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              description,
              style: TextStyle(
                color: R.color.captionColorGray,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
        ...children,
      ]),
    );
  }

  showActionSheet(BuildContext context) {
    final action = CupertinoActionSheet(
      actions: <Widget>[
        CupertinoActionSheetAction(
          child: Padding(
            padding: const EdgeInsets.only(left: 8, right: 8),
            child: Row(
              children: [
                Image.asset(R.drawable.ic_photo, width: 24, height: 24),
                const SizedBox(width: 16),
                Text(R.string.chon_trong_thu_vien.tr(),
                    style: TextStyle(
                        color: R.color.color0xff333333, fontSize: 14)),
              ],
            ),
          ),
          onPressed: () {
            showGallery();
            Navigator.pop(context);
          },
        ),
        CupertinoActionSheetAction(
          child: Padding(
            padding: const EdgeInsets.only(left: 8, right: 8),
            child: Row(
              children: [
                Image.asset(R.drawable.ic_camera_black, width: 24, height: 24),
                const SizedBox(width: 16),
                Text(R.string.chup_anh.tr(),
                    style: TextStyle(
                        color: R.color.color0xff333333, fontSize: 14)),
              ],
            ),
          ),
          onPressed: () {
            Navigator.pop(context);
            _openCamera(context);
          },
        )
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text(R.string.cancel.tr(),
            style: TextStyle(color: R.color.color0xff333333, fontSize: 14)),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
    showCupertinoModalPopup(context: context, builder: (context) => action);
  }

  _openCamera(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.getImage(
          maxWidth: 1024,
          maxHeight: 1024,
          source: ImageSource.camera,
          preferredCameraDevice: CameraDevice.rear);
      if (pickedFile != null) {
        await _cropImage(pickedFile.path);
      }
    } catch (_) {
      showAlertDialog(context);
    }
  }

  showGallery() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.getImage(
          maxWidth: 1024, maxHeight: 1024, source: ImageSource.gallery);
      if (pickedFile != null) {
        await _cropImage(pickedFile.path);
      }
    } catch (_) {
      showAlertDialog(context);
    }
  }

  _cropImage(String url) async {
    try {
      BotToast.showLoading();
      final imageFile = await (ImageCropper.cropImage(
          maxWidth: 320,
          maxHeight: 320,
          aspectRatioPresets: [CropAspectRatioPreset.square],
          compressQuality: 75,
          compressFormat: ImageCompressFormat.jpg,
          cropStyle: CropStyle.circle,
          sourcePath: url,
          androidUiSettings: const AndroidUiSettings(
              toolbarTitle: 'Cropper',
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: false),
          iosUiSettings: const IOSUiSettings(
            minimumAspectRatio: 1.0,
          )) as FutureOr<File>);

      final path = imageFile.path;
      await uploadAvatar(path);
    } catch (_) {
      BotToast.closeAllLoading();
    }
  }

  showAlertDialog(BuildContext context) {
    final Widget cancelButton = FlatButton(
      child: Text(R.string.cancel.tr()),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    final Widget continueButton = FlatButton(
      child: Text(R.string.allowed.tr()),
      onPressed: () {
        Navigator.pop(context);
        openAppSettings();
      },
    );

    final AlertDialog alert = AlertDialog(
      title: Text(R.string.notification.tr()),
      content: Text(R.string.ask_for_permission.tr()),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  uploadAvatar(String url) async {
    try {
      BotToast.showLoading();
      await UserClient().updateAvatar(AppSettings.userInfo!.id, url);
      await UserClient().fetchUser();
      BotToast.closeAllLoading();
    } catch (e, _) {
      BotToast.closeAllLoading();
      if (e is Error) {
        Message.showToastMessage(context, e.message);
      } else {
        Message.showToastMessage(context, e.toString());
      }
    }
  }

  updateUserInfo(UserModel user) async {
    try {
      BotToast.showLoading();
      await UserClient().updateUserInfo(AppSettings.userInfo!.id, user);
      await UserClient().fetchUser();
      BotToast.closeAllLoading();
    } catch (e, _) {
      BotToast.closeAllLoading();
      if (e is Error) {
        Message.showToastMessage(context, e.message);
      } else {
        Message.showToastMessage(context, e.toString());
      }
    }
  }

  addMotivation(MotivationModel model) async {
    try {
      BotToast.showLoading();
      await UserClient().inputMotivationDiary(model.content);
      await loadMotivation();
      BotToast.closeAllLoading();
    } catch (e, _) {
      BotToast.closeAllLoading();
      if (e is Error) {
        Message.showToastMessage(context, e.message);
      } else {
        Message.showToastMessage(context, e.toString());
      }
    }
  }

  updateMotivation(MotivationModel model) async {
    try {
      BotToast.showLoading();
      await UserClient().editMotivationDiary(model.id, model.content);
      await loadMotivation();
      BotToast.closeAllLoading();
    } catch (e, _) {
      BotToast.closeAllLoading();
      if (e is Error) {
        Message.showToastMessage(context, e.message);
      } else {
        Message.showToastMessage(context, e.toString());
      }
    }
  }

  linkedGoogle() async {
    final user = AppSettings.userInfo!;
    if (user.isLinkedGoogle == true) {
      if (user.firstLinkedAccount != 'Google') {
        unlinkedGoogle();
      }
      return;
    }
    try {
      BotToast.showLoading();
      final GoogleSignIn _googleSignIn = GoogleSignIn(
        scopes: [
          R.string.email.tr(),
          'profile',
        ],
      );
      await _googleSignIn.signOut();
      final GoogleSignInAccount account =
          await (_googleSignIn.signIn() as FutureOr<GoogleSignInAccount>);
      final result = await LoginClient().linkedAccountOTP({
        'providerName': 'Google',
        'providerKey': account.id,
        'phoneNumber': user.phoneNumber
      });
      BotToast.closeAllLoading();
      if (result.isSuccess != true) {
        _showDialogError(user.phoneNumber);
      } else {
        Navigator.pushNamed(context, NavigatorName.verify, arguments: {
          'type': 'linked_google',
          'otp': result.token,
          'phone': user.phoneNumber,
          'remainingRequestCount': result.remainingRequestCount,
          'googleAccount': account
        });
      }
    } catch (e, _) {
      BotToast.closeAllLoading();
      if (e is Error) {
        if (e.code == 'USER002') {
          Message.showToastMessage(context, R.string.account_already_used.tr());
        } else {
          Message.showToastMessage(context, e.message);
        }
      }
    }
  }

  linkedFacebook() async {
    final user = AppSettings.userInfo!;

    if (user.isLinkedFacebook == true) {
      if (user.firstLinkedAccount != 'Facebook') {
        unlinkedFacebook();
      }
      return;
    }
    final facebookLogin = FacebookLogin();
    await facebookLogin.logOut();
    final resultFacebook = await facebookLogin.logIn([R.string.email.tr()]);
    switch (resultFacebook.status) {
      case FacebookLoginStatus.loggedIn:
        try {
          BotToast.showLoading();

          final result = await LoginClient().linkedAccountOTP({
            'providerName': 'Facebook',
            'providerKey': resultFacebook.accessToken?.userId,
            'phoneNumber': user.phoneNumber
          });
          BotToast.closeAllLoading();
          if (result.isSuccess != true) {
            _showDialogError(user.phoneNumber);
          } else {
            Navigator.pushNamed(context, NavigatorName.verify, arguments: {
              'type': 'linked_facebook',
              'otp': result.token,
              'phone': user.phoneNumber,
              'remainingRequestCount': result.remainingRequestCount,
              'facebookAccount': resultFacebook
            });
          }
        } catch (e, _) {
          BotToast.closeAllLoading();
          if (e is Error) {
            if (e.code == 'USER002') {
              Message.showToastMessage(
                  context, R.string.account_already_used.tr());
            } else {
              Message.showToastMessage(context, e.message);
            }
          }
        }
        break;
      case FacebookLoginStatus.cancelledByUser:
        break;
      case FacebookLoginStatus.error:
        Message.showToastMessage(context, resultFacebook.errorMessage);
        break;
    }
  }

  unlinkedGoogle() async {
    try {
      BotToast.showLoading();
      await LoginClient().unLinkedAccount({'providerName': 'Google'});
      final refreshToken = await AppSettings.getRefreshToken();
      await LoginClient().login({
        "client_id": '4A293E78-4513-4DAF-958E-A04F93978332',
        "client_secret": "oTxBinRm9NpNen3rs++jN9sWXvOkya60nuffhv6x304=",
        "grant_type": "refresh_token",
        "refresh_token": refreshToken
      });
      await UserClient().fetchUser();
      BotToast.closeAllLoading();
      Message.showToastMessage(context, R.string.unlinked.tr());
    } catch (e, _) {
      BotToast.closeAllLoading();
      if (e is Error) {
        Message.showToastMessage(context, e.message);
      } else {
        Message.showToastMessage(context, e.toString());
      }
    }
  }

  unlinkedFacebook() async {
    try {
      BotToast.showLoading();
      await LoginClient().unLinkedAccount({'providerName': 'Facebook'});
      final refreshToken = await AppSettings.getRefreshToken();
      await LoginClient().login({
        "client_id": '4A293E78-4513-4DAF-958E-A04F93978332',
        "client_secret": "oTxBinRm9NpNen3rs++jN9sWXvOkya60nuffhv6x304=",
        "grant_type": "refresh_token",
        "refresh_token": refreshToken
      });
      await UserClient().fetchUser();
      BotToast.closeAllLoading();
      Message.showToastMessage(context, R.string.unlinked.tr());
    } catch (e, _) {
      BotToast.closeAllLoading();
      if (e is Error) {
        Message.showToastMessage(context, e.message);
      } else {
        Message.showToastMessage(context, e.toString());
      }
    }
  }

  _showDialogError(String? phone) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
            content: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(R.drawable.ic_check_error, width: 64, height: 64),
              const SizedBox(height: 8),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: 'Đã gửi OTP 5 lần cho số điện thoại ',
                  style:
                      const TextStyle(color: Color(0xff172823), fontSize: 16),
                  children: <TextSpan>[
                    TextSpan(
                        text: phone,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const TextSpan(
                        text:
                            '.\nVui lòng kiểm tra lại hoặc đăng ký vào ngày hôm sau!',
                        style:
                            TextStyle(color: Color(0xff172823), fontSize: 16)),
                  ],
                ),
              )
            ],
          ),
        ));
      },
    );
  }

  _showDialogUpdateMotivation(MotivationModel? model) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: MotivationPopup(
                model: model,
                callback: (data) {
                  if (data.id == null) {
                    addMotivation(data);
                  } else {
                    updateMotivation(data);
                  }
                },
              ),
            ));
  }

  _showDialogLogout() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
            contentPadding: const EdgeInsets.all(0),
            content: Stack(children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(R.drawable.ic_logout, width: 64, height: 64),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(R.string.confirm_logout.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: R.color.textDark,
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(R.string.confirm_logout_description.tr(),
                          textAlign: TextAlign.center,
                          style: R.style.normalTextStyle),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Container(
                                    height: 43,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(200),
                                        color: R.color.grayBorder),
                                    child: Center(
                                      child: Text(R.string.van_o_lai.tr(),
                                          style: TextStyle(
                                              color: R.color.textDark,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600)),
                                    )),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  AppSettings.logout();
                                },
                                child: Container(
                                  height: 43,
                                  decoration: BoxDecoration(
                                      color: R.color.red,
                                      borderRadius: BorderRadius.circular(200),
                                      gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.centerRight,
                                          colors: [
                                            R.color.greenGradientTop,
                                            R.color.greenGradientBottom
                                          ])),
                                  child: Center(
                                    child: Text(R.string.logout.tr(),
                                        style: TextStyle(
                                            color: R.color.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600)),
                                  ),
                                ),
                              ),
                            ),
                          ]),
                    ),
                  ],
                ),
              ),
            ])));
  }

  _showDialogUpdateName() {
    final width = MediaQuery.of(context).size.width;
    final TextEditingController textEditingController = TextEditingController();
    textEditingController.text = AppSettings.userInfo?.fullName ?? '';
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
                content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(R.string.last_name_and_first_name.tr(),
                          style: TextStyle(
                              color: R.color.textDark,
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                      GestureDetector(
                          child:
                              Icon(Icons.close, color: R.color.color0xffBEC0C8),
                          onTap: () {
                            Navigator.pop(context);
                          })
                    ]),
                const SizedBox(height: 16),
                Container(
                    height: 64,
                    width: width - 36,
                    child: TextField(
                        controller: textEditingController,
                        minLines: 1,
                        maxLines: 1,
                        maxLength: 50,
                        inputFormatters: [
                          LengthLimitingTextFieldFormatterFixed(50),
                        ],
                        obscureText: false,
                        decoration: InputDecoration(
                            fillColor: R.color.textDark,
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: R.color.grayComponentBorder,
                                  width: 1.0),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: R.color.mainColor, width: 1.0),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: const EdgeInsets.only(
                                top: 0, left: 16, right: 16),
                            hintText:
                                R.string.enter_first_name_and_last_name.tr()),
                        onChanged: (value) {})),
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                              height: 48,
                              width: 119,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(200),
                                  color: R.color.grayBorder),
                              child: Center(
                                child: Text(R.string.cancel.tr(),
                                    style: TextStyle(
                                        color: R.color.textDark,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600)),
                              )),
                        ),
                        GestureDetector(
                          onTap: () {
                            final name = textEditingController.text;
                            if (name.isEmpty) {
                              Message.showToastMessage(
                                  context, R.string.mes_name_empty.tr());
                              return;
                            } else {
                              final UserModel userInfo = AppSettings.userInfo!;
                              updateUserInfo(
                                userInfo.copyWith(
                                  fullName: name,
                                ),
                              );
                              Navigator.pop(context);
                            }
                          },
                          child: Container(
                            height: 48,
                            width: 119,
                            decoration: BoxDecoration(
                                color: R.color.red,
                                borderRadius: BorderRadius.circular(200),
                                gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      R.color.greenGradientTop,
                                      R.color.greenGradientBottom
                                    ])),
                            child: Center(
                              child: Text(R.string.save.tr(),
                                  style: TextStyle(
                                      color: R.color.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ),
                      ]),
                ),
              ],
            )));
  }

  _showDialogUpdateBirthday() {
    final width = MediaQuery.of(context).size.width;
    DateTime selectedDate = DateTime.fromMillisecondsSinceEpoch(
        AppSettings.userInfo!.dateOfBirth! * 1000);
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
                content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(R.string.ngay_sinh.tr(),
                          style: TextStyle(
                              color: R.color.textDark,
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                      GestureDetector(
                          child:
                              Icon(Icons.close, color: R.color.color0xffBEC0C8),
                          onTap: () {
                            Navigator.pop(context);
                          })
                    ]),
                const SizedBox(height: 16),
                Container(
                    height: 250,
                    width: width - 36,
                    child: BirthDayPicker(
                      selectedDate: DateTime.fromMillisecondsSinceEpoch(
                          AppSettings.userInfo!.dateOfBirth! * 1000),
                      onChanged: (date) {
                        selectedDate = date;
                      },
                    )),
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                              height: 48,
                              width: 119,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(200),
                                  color: R.color.grayBorder),
                              child: Center(
                                child: Text(R.string.cancel.tr(),
                                    style: TextStyle(
                                        color: R.color.textDark,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600)),
                              )),
                        ),
                        GestureDetector(
                          onTap: () {
                            final UserModel userInfo = AppSettings.userInfo!;
                            updateUserInfo(
                              userInfo.copyWith(
                                dateOfBirth:
                                    selectedDate.millisecondsSinceEpoch ~/ 1000,
                              ),
                            );
                            Navigator.pop(context);
                          },
                          child: Container(
                            height: 48,
                            width: 119,
                            decoration: BoxDecoration(
                                color: R.color.red,
                                borderRadius: BorderRadius.circular(200),
                                gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      R.color.greenGradientTop,
                                      R.color.greenGradientBottom
                                    ])),
                            child: Center(
                              child: Text(R.string.yes.tr(),
                                  style: TextStyle(
                                      color: R.color.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ),
                      ]),
                ),
              ],
            )));
  }

  _showDialogUpdateGender() {
    final width = MediaQuery.of(context).size.width;
    final FixedExtentScrollController controller = FixedExtentScrollController(
        initialItem: AppSettings.userInfo!.genderType == 1 ? 0 : 1);
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
                content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(R.string.gioi_tinh.tr(),
                          style: TextStyle(
                              color: R.color.textDark,
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                      GestureDetector(
                          child:
                              Icon(Icons.close, color: R.color.color0xffBEC0C8),
                          onTap: () {
                            Navigator.pop(context);
                          })
                    ]),
                const SizedBox(height: 16),
                Container(
                    height: 150,
                    width: width - 36,
                    child: GenderPicker(controller: controller)),
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                              height: 48,
                              width: 119,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(200),
                                  color: R.color.grayBorder),
                              child: Center(
                                child: Text(R.string.cancel.tr(),
                                    style: TextStyle(
                                        color: R.color.textDark,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600)),
                              )),
                        ),
                        GestureDetector(
                          onTap: () {
                            final UserModel userInfo = AppSettings.userInfo!;
                            updateUserInfo(
                              userInfo.copyWith(
                                genderType:
                                    controller.selectedItem == 0 ? 1 : 2,
                              ),
                            );
                            Navigator.pop(context);
                          },
                          child: Container(
                            height: 48,
                            width: 119,
                            decoration: BoxDecoration(
                                color: R.color.red,
                                borderRadius: BorderRadius.circular(200),
                                gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      R.color.greenGradientTop,
                                      R.color.greenGradientBottom
                                    ])),
                            child: Center(
                              child: Text(R.string.yes.tr(),
                                  style: TextStyle(
                                      color: R.color.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ),
                      ]),
                ),
              ],
            )));
  }

  _showDialogUpdateDiabetesStatus() {
    final width = MediaQuery.of(context).size.width;
    int? diabetesStatus = AppSettings.userInfo!.diabetesStatus;
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
                content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(R.string.loai_benh.tr(),
                          style: TextStyle(
                              color: R.color.textDark,
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                      GestureDetector(
                          child:
                              Icon(Icons.close, color: R.color.color0xffBEC0C8),
                          onTap: () {
                            Navigator.pop(context);
                          })
                    ]),
                const SizedBox(height: 16),
                Container(
                    height: 150,
                    width: width - 36,
                    child: DiabetesStatusPicker(
                      state: diabetesStatus,
                      onChanged: (data) {
                        diabetesStatus = data['key'];
                      },
                    )),
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                              height: 48,
                              width: 119,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(200),
                                  color: R.color.grayBorder),
                              child: Center(
                                child: Text(R.string.cancel.tr(),
                                    style: TextStyle(
                                        color: R.color.textDark,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600)),
                              )),
                        ),
                        GestureDetector(
                          onTap: () {
                            final UserModel userInfo = AppSettings.userInfo!;
                            updateUserInfo(
                              userInfo.copyWith(
                                diabetesStatus: diabetesStatus,
                              ),
                            );
                            Navigator.pop(context);
                          },
                          child: Container(
                            height: 48,
                            width: 119,
                            decoration: BoxDecoration(
                                color: R.color.red,
                                borderRadius: BorderRadius.circular(200),
                                gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      R.color.greenGradientTop,
                                      R.color.greenGradientBottom
                                    ])),
                            child: Center(
                              child: Text(R.string.yes.tr(),
                                  style: TextStyle(
                                      color: R.color.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ),
                      ]),
                ),
              ],
            )));
  }

  _showDialogUpdateDiabetesStatusDate() {
    final width = MediaQuery.of(context).size.width;
    int? year = AppSettings.userInfo!.diabetesDate;
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
                content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(R.string.nam_phat_hien_benh.tr(),
                          style: TextStyle(
                              color: R.color.textDark,
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                      GestureDetector(
                          child:
                              Icon(Icons.close, color: R.color.color0xffBEC0C8),
                          onTap: () {
                            Navigator.pop(context);
                          })
                    ]),
                const SizedBox(height: 16),
                Container(
                    height: 150,
                    width: width - 36,
                    child: DiabetesStatusDatePicker(
                      year: DateTime.fromMillisecondsSinceEpoch(
                              (year ?? 0) * 1000)
                          .year,
                      onChanged: (data) {
                        year = data;
                      },
                    )),
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                              height: 48,
                              width: 119,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(200),
                                  color: R.color.grayBorder),
                              child: Center(
                                child: Text(R.string.cancel.tr(),
                                    style: TextStyle(
                                        color: R.color.textDark,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600)),
                              )),
                        ),
                        GestureDetector(
                          onTap: () {
                            final UserModel userInfo = AppSettings.userInfo!;
                            updateUserInfo(
                              userInfo.copyWith(
                                diabetesDate: DateTime.utc(year ?? 0)
                                        .millisecondsSinceEpoch ~/
                                    1000,
                              ),
                            );
                            Navigator.pop(context);
                          },
                          child: Container(
                            height: 48,
                            width: 119,
                            decoration: BoxDecoration(
                                color: R.color.red,
                                borderRadius: BorderRadius.circular(200),
                                gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      R.color.greenGradientTop,
                                      R.color.greenGradientBottom
                                    ])),
                            child: Center(
                              child: Text(R.string.yes.tr(),
                                  style: TextStyle(
                                      color: R.color.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ),
                      ]),
                ),
              ],
            )));
  }

  showDialogWeight() {
    showDialog(
      barrierColor: R.color.color0xff003F38.withOpacity(0.5),
      context: context,
      builder: (_) => CustomWeightPicker(
          callback: (weight) {
            if (weight == null || weight <= 0) {
              Message.showToastMessage(
                  context, R.string.mes_weight_must_greater_than_zero.tr());
              return;
            }
            final UserModel userInfo = AppSettings.userInfo!;
            updateUserInfo(
              userInfo.copyWith(
                weight: weight.toDouble(),
              ),
            );
          },
          title: R.string.enter_weight.tr(),
          max: 180,
          numberDefault: (AppSettings.userInfo!.weight == null ||
                      AppSettings.userInfo!.weight == 0
                  ? 50
                  : AppSettings.userInfo!.weight)!
              .toInt(),
          unit: ''),
    );
  }

  showDialogHeight() {
    showDialog(
      barrierColor: R.color.color0xff003F38.withOpacity(0.5),
      context: context,
      builder: (_) => CustomNumPicker(
          callback: (data) {
            if (data == null || data <= 0) {
              Message.showToastMessage(
                  context, R.string.mes_height_must_greater_than_zero.tr());
              return;
            }
            final UserModel userInfo = AppSettings.userInfo!;
            updateUserInfo(
              userInfo.copyWith(
                height: data.toDouble(),
              ),
            );
          },
          title: R.string.enter_height.tr(),
          max: 250,
          numberDefault: (AppSettings.userInfo!.height == null ||
                      AppSettings.userInfo!.height == 0
                  ? 150
                  : AppSettings.userInfo!.height)!
              .toInt(),
          unit: ''),
    );
  }

  _showDialogUpdatePhone2() {
    final width = MediaQuery.of(context).size.width;
    final TextEditingController textEditingController = TextEditingController();
    textEditingController.text = AppSettings.userInfo?.secondPhoneNumber ?? '';
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
                content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(R.string.phone_number_2.tr(),
                          style: TextStyle(
                              color: R.color.textDark,
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                      GestureDetector(
                          child:
                              Icon(Icons.close, color: R.color.color0xffBEC0C8),
                          onTap: () {
                            Navigator.pop(context);
                          })
                    ]),
                const SizedBox(height: 16),
                Container(
                    height: 54,
                    width: width - 36,
                    child: TextField(
                        controller: textEditingController,
                        keyboardType: TextInputType.number,
                        minLines: 1,
                        maxLines: 1,
                        obscureText: false,
                        decoration: InputDecoration(
                          fillColor: R.color.textDark,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: R.color.grayComponentBorder, width: 1.0),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: R.color.mainColor, width: 1.0),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.only(
                              top: 0, left: 16, right: 16),
                          hintText: R.string.enter_phone_number_2.tr(),
                        ),
                        onChanged: (value) {})),
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                              height: 48,
                              width: 119,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(200),
                                  color: R.color.grayBorder),
                              child: Center(
                                child: Text(R.string.cancel.tr(),
                                    style: TextStyle(
                                        color: R.color.textDark,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600)),
                              )),
                        ),
                        GestureDetector(
                          onTap: () {
                            final phone = textEditingController.text;
                            if (phone.isEmpty) {
                              Message.showToastMessage(context,
                                  R.string.ban_chua_nhap_so_dien_thoai.tr());
                              return;
                            } else {
                              final UserModel userInfo = AppSettings.userInfo!;
                              updateUserInfo(
                                userInfo.copyWith(
                                  secondPhoneNumber: phone,
                                ),
                              );
                              Navigator.pop(context);
                            }
                          },
                          child: Container(
                            height: 48,
                            width: 119,
                            decoration: BoxDecoration(
                                color: R.color.red,
                                borderRadius: BorderRadius.circular(200),
                                gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      R.color.greenGradientTop,
                                      R.color.greenGradientBottom
                                    ])),
                            child: Center(
                              child: Text(R.string.save.tr(),
                                  style: TextStyle(
                                      color: R.color.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ),
                      ]),
                ),
              ],
            )));
  }

  _showDialogUpdateEmail() {
    final TextEditingController textEditingController = TextEditingController();
    textEditingController.text = AppSettings.userInfo!.email ?? '';
    showDialog(
      context: context,
      builder: (context) => EmailValidate(
        controller: textEditingController,
        completion: (email) {
          final UserModel userInfo = AppSettings.userInfo!;
          updateUserInfo(
            userInfo.copyWith(
              email: email,
            ),
          );
          Navigator.pop(context);
        },
      ),
    );
  }

  _showDialogUpdateAddress() {
    final UserModel userInfo = AppSettings.userInfo!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: AddressController(
          address: userInfo.address,
          province: userInfo.province,
          district: userInfo.district,
          ward: userInfo.ward,
          callback: (address, province, district, ward) {
            updateUserInfo(
              userInfo.copyWith(
                province: province,
                district: district,
                ward: ward,
                address: address,
              ),
            );
          },
        ),
      ),
    );
  }

  showActionFilter(
      {required BuildContext context,
      required Widget Function(BuildContext) builder}) {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(15),
        ),
      ),
      backgroundColor: R.color.white,
      context: context,
      isScrollControlled: true,
      builder: builder,
    );
  }
}
