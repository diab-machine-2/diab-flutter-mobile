import 'package:bot_toast/bot_toast.dart';
import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/modal/user/motivation_model.dart';
import 'package:medical/src/modal/user/user_model.dart';
import 'package:medical/src/repo/login/login_client.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:medical/src/theme/app_theme.dart';
import 'package:medical/src/widget/Bmi/widget/add_bmi.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widget/profile/address.dart';
import 'package:permission_handler/permission_handler.dart';

class ProfileInfoController extends StatefulWidget {
  @override
  _ProfileInfoControllerState createState() => _ProfileInfoControllerState();
}

class _ProfileInfoControllerState extends State<ProfileInfoController> {
  MotivationModel motivation;

  void initState() {
    super.initState();
    DartNotificationCenter.subscribe(
        channel: 'user_info_change',
        observer: this,
        onNotification: (_) {
          setState(() {});
        });

    loadMotivation();
    TrackingManager.analytics.setCurrentScreen(screenName: 'Update Profile');
  }

  loadMotivation() async {
    final result = await UserClient().fetchMotivationDiary(1);
    DartNotificationCenter.post(channel: 'motivation_change');
    motivation = result.models.length == 0 ? null : result.models.first;
    setState(() {});
  }

  @override
  void dispose() {
    DartNotificationCenter.unsubscribe(
        channel: 'user_info_change', observer: this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = AppSettings.userInfo;
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
            body: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [
                    Color(0xFFFDC798).withOpacity(0.3),
                    Color(0xFFE6F6ED).withOpacity(0.9),
                  ],
                  begin: FractionalOffset(1, 1),
                  end: FractionalOffset(0.9, 0.5),
                  stops: [0.0, 1.0])),
          child: Stack(children: [
            Image.asset('assets/images/profile_bg.png'),
            Column(children: [
              CustomAppBar(
                backgroundColor: R.color.transparent,
                title: Text('Thông tin cá nhân',
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
                      padding: EdgeInsets.only(bottom: 16, left: 16, right: 16),
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
                                        padding: EdgeInsets.all(8.0),
                                        child: Container(
                                          clipBehavior: Clip.hardEdge,
                                          decoration: BoxDecoration(
                                              color: R.color.mainColor,
                                              borderRadius:
                                                  BorderRadius.circular(80)),
                                          child: user.imageUrl.url == null
                                              ? Icon(Icons.person,
                                                  size: 160,
                                                  color: R.color.white)
                                              : Image.network(user.imageUrl.url,
                                                  width: 160, height: 160),
                                        ),
                                      ),
                                      Image.asset(
                                          'assets/images/icon_camera_picker.png',
                                          width: 50,
                                          height: 50)
                                    ]),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        motivation != null
                            ? Container(
                                decoration: BoxDecoration(
                                    color: R.color.white,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
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
                                                  Text('Động lực của tôi',
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
                                                            'assets/images/icon_edit.png',
                                                            width: 16,
                                                            height: 16),
                                                        SizedBox(width: 4),
                                                        Text('Chỉnh sửa',
                                                            style: TextStyle(
                                                                color:
                                                                    R.color.mainColor,
                                                                fontSize: 16))
                                                      ]),
                                                    ),
                                                  )
                                                ]),
                                            SizedBox(height: 16),
                                            Text('“${motivation.content}”',
                                                style: TextStyle(
                                                    color: R.color.textDark,
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 16)),
                                          ]),
                                    ),
                                    SizedBox(height: 16),
                                    Container(
                                        height: 1, color: Color(0xffe5e5e5)),
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () {
                                                Navigator.pushNamed(
                                                    context, '/motivation');
                                              },
                                              child: Container(
                                                color: R.color.transparent,
                                                child: Center(
                                                  child: Text('Xem nhật ký',
                                                      style: TextStyle(
                                                          color: R.color.mainColor,
                                                          fontSize: 16)),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Container(
                                              height: 46,
                                              width: 1,
                                              color: Color(0xffe5e5e5)),
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () {
                                                _showDialogUpdateMotivation(
                                                    null);
                                              },
                                              child: Container(
                                                color: R.color.transparent,
                                                child: Center(
                                                  child: Text('Động lực mới',
                                                      style: TextStyle(
                                                          color: R.color.mainColor,
                                                          fontSize: 16)),
                                                ),
                                              ),
                                            ),
                                          )
                                        ])
                                  ],
                                ))
                            : GestureDetector(
                                onTap: () {
                                  _showDialogUpdateMotivation(null);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: R.color.transparent,
                                    image: DecorationImage(
                                        image: AssetImage(
                                            'assets/images/bg_dongluc.png'),
                                        fit: BoxFit.fill),
                                  ),
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Động lực của tôi',
                                            style: TextStyle(
                                                color: R.color.white,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 16)),
                                        SizedBox(height: 8),
                                        Text(
                                            'Điều gì tạo động lực sống khoẻ cho bạn?',
                                            style: TextStyle(
                                                color: R.color.white,
                                                fontWeight: FontWeight.w400,
                                                fontSize: 16)),
                                        Padding(
                                          padding: EdgeInsets.only(
                                              top: 16, bottom: 8),
                                          child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  height: 40,
                                                  padding: EdgeInsets.only(
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
                                                      SizedBox(width: 8),
                                                      Text('Viết động lực  ',
                                                          style: TextStyle(
                                                              color:
                                                                  R.color.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              fontSize: 16)),
                                                    ],
                                                  ),
                                                )
                                              ]),
                                        )
                                      ]),
                                ),
                              ),
                        SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                              color: R.color.white,
                              borderRadius: BorderRadius.circular(10)),
                          padding: EdgeInsets.all(16),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Thông tin chung',
                                    style: TextStyle(
                                        color: R.color.black,
                                        fontWeight: FontWeight.w600)),
                                SizedBox(height: 8),
                                buildItem(
                                  'assets/images/icon_person.png',
                                  user.fullName,
                                  'Họ và tên',
                                  Image.asset('assets/images/icon_right.png',
                                      width: 18, height: 18),
                                  0,
                                  callback: () {
                                    _showDialogUpdateName();
                                  },
                                ),
                                buildItem(
                                  'assets/images/icon_birthday.png',
                                  convertToUTC(user.dateOfBirth, 'dd/MM/yyyy'),
                                  'Ngày sinh',
                                  Image.asset('assets/images/icon_right.png',
                                      width: 18, height: 18),
                                  1,
                                  callback: () {
                                    _showDialogUpdateBirthday();
                                  },
                                ),
                                buildItem(
                                  'assets/images/icon_gender.png',
                                  user.gender == null || user.gender.isEmpty
                                      ? 'Đang cập nhật'
                                      : user.gender,
                                  'Giới tính',
                                  Image.asset('assets/images/icon_right.png',
                                      width: 18, height: 18),
                                  2,
                                  callback: () {
                                    _showDialogUpdateGender();
                                  },
                                )
                              ]),
                        ),
                        SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                              color: R.color.white,
                              borderRadius: BorderRadius.circular(10)),
                          padding: EdgeInsets.all(16),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Thông tin bệnh lý',
                                    style: TextStyle(
                                        color: R.color.black,
                                        fontWeight: FontWeight.w600)),
                                SizedBox(height: 8),
                                buildItem(
                                  'assets/images/icon_folder.png',
                                  user.diabetesName ?? 'Đang cập nhật',
                                  'Loại bệnh',
                                  null,
                                  3,
                                  callback: () {
                                    _showDialogUpdateDiabetesStatus();
                                  },
                                ),
                                buildItem(
                                  'assets/images/icon_year.png',
                                  convertToUTC(user.diabetesDate, 'yyyy'),
                                  'Năm phát bệnh',
                                  null,
                                  4,
                                  callback: () {
                                    _showDialogUpdateDiabetesStatusDate();
                                  },
                                )
                              ]),
                        ),
                        SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                              color: R.color.white,
                              borderRadius: BorderRadius.circular(10)),
                          padding: EdgeInsets.all(16),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Chỉ số cơ thể',
                                    style: TextStyle(
                                        color: R.color.black,
                                        fontWeight: FontWeight.w600)),
                                SizedBox(height: 8),
                                buildItem(
                                  'assets/images/icon_kg.png',
                                  user.weight == null
                                      ? 'Chưa cập nhật'
                                      : '${user.weight.round()} kg',
                                  'Cân nặng',
                                  null,
                                  5,
                                  callback: () {
                                    showDialogWeight();
                                  },
                                ),
                                buildItem(
                                  'assets/images/icon_ruler.png',
                                  user.height == null
                                      ? 'Chưa cập nhật'
                                      : '${user.height.round()} cm',
                                  'Chiều cao',
                                  null,
                                  6,
                                  callback: () {
                                    showDialogHeight();
                                  },
                                )
                              ]),
                        ),
                        SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                              color: R.color.white,
                              borderRadius: BorderRadius.circular(10)),
                          padding: EdgeInsets.all(16),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Thông liên lạc',
                                    style: TextStyle(
                                        color: R.color.black,
                                        fontWeight: FontWeight.w600)),
                                SizedBox(height: 8),
                                buildItem(
                                    'assets/images/icon_phone_info.png',
                                    user.phoneNumber,
                                    'Số điện thoại 1',
                                    Image.asset('assets/images/icon_ok.png',
                                        width: 24, height: 24),
                                    7),
                                buildItem(
                                  'assets/images/icon_phone_info.png',
                                  user.secondPhoneNumber == null ||
                                          user.secondPhoneNumber.isEmpty
                                      ? 'Chưa cập nhật'
                                      : user.secondPhoneNumber,
                                  'Số điện thoại 2',
                                  null,
                                  8,
                                  callback: () {
                                    _showDialogUpdatePhone2();
                                  },
                                ),
                                buildItem(
                                  'assets/images/icon_email.png',
                                  user.email == null || user.email.isEmpty
                                      ? 'Chưa cập nhật'
                                      : user.email,
                                  'Email',
                                  null,
                                  9,
                                  callback: () {
                                    _showDialogUpdateEmail();
                                  },
                                ),
                                buildItem(
                                    'assets/images/icon_location.png',
                                    ((user.address ?? '') +
                                                (user.address ==
                                                            null ||
                                                        user.address.isEmpty
                                                    ? ''
                                                    : ', ') +
                                                (user
                                                            .ward ==
                                                        null
                                                    ? ''
                                                    : user.ward.name) +
                                                (user
                                                                .ward ==
                                                            null ||
                                                        user.ward.name.isEmpty
                                                    ? ''
                                                    : ', ') +
                                                (user
                                                            .district ==
                                                        null
                                                    ? ''
                                                    : user.district.name) +
                                                (user
                                                                .district ==
                                                            null ||
                                                        user.district.name
                                                            .isEmpty
                                                    ? ''
                                                    : ', ') +
                                                (user
                                                            .province ==
                                                        null
                                                    ? ''
                                                    : user.province.name))
                                            .isEmpty
                                        ? 'Chưa cập nhật'
                                        : ((user
                                                    .address ??
                                                '') +
                                            (user.address == null ||
                                                    user.address.isEmpty
                                                ? ''
                                                : ', ') +
                                            (user.ward == null
                                                ? ''
                                                : user.ward.name) +
                                            (user.ward == null ||
                                                    user.ward.name.isEmpty
                                                ? ''
                                                : ', ') +
                                            (user.district == null
                                                ? ''
                                                : user.district.name) +
                                            (user.district == null ||
                                                    user.district.name.isEmpty
                                                ? ''
                                                : ', ') +
                                            (user.province == null
                                                ? ''
                                                : user.province.name)),
                                    'Địa chỉ',
                                    null,
                                    10, callback: () {
                                  _showDialogUpdateAddress();
                                }),
                                buildItem(
                                    'assets/images/icon_google.png',
                                    user.isLinkedGoogle == null ||
                                            !user.isLinkedGoogle
                                        ? 'Chưa kết nối'
                                        : user.fullName,
                                    'Google',
                                    CupertinoSwitch(
                                      activeColor: R.color.mainColor,
                                      value: user.isLinkedGoogle ?? false,
                                      onChanged: (value) {
                                        print(value);
                                        linkedGoogle();
                                      },
                                    ),
                                    11),
                                // buildItem(
                                //     'assets/images/icon_fb_info.png',
                                //     user.isLinkedFacebook == null ||
                                //             !user.isLinkedFacebook
                                //         ? 'Chưa kết nối'
                                //         : user.fullName,
                                //     'Facebook',
                                //     CupertinoSwitch(
                                //       activeColor: R.color.mainColor,
                                //       value: user.isLinkedFacebook ?? false,
                                //       onChanged: (value) {
                                //         print(value);
                                //         linkedFacebook();
                                //       },
                                //     ),
                                //     12)
                              ]),
                        ),
                        SizedBox(height: 16),
                        GestureDetector(
                          onTap: () {
                            _showDialogLogout();
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                  color: R.color.white,
                                  borderRadius: BorderRadius.circular(10)),
                              padding: EdgeInsets.all(16),
                              child: Row(children: [
                                Image.asset('assets/images/icon_logout.png',
                                    width: 33, height: 33),
                                SizedBox(width: 12),
                                Text('Đăng xuất',
                                    style: TextStyle(color: R.color.black))
                              ])),
                        )
                      ]),
                ),
              )
            ]),
          ]),
        )));
  }

  Widget buildItem(
      String image, String title, String subTitle, Widget subIcon, int index,
      {VoidCallback callback}) {
    return GestureDetector(
      onTap: () {
        callback();
      },
      child: Container(
        color: R.color.transparent,
        padding: EdgeInsets.only(top: 8, bottom: 8),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Image.asset(image, width: 33, height: 33),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: TextStyle(color: R.color.black)),
                      SizedBox(height: 2),
                      Text(subTitle, style: TextStyle(color: Color(0xff9c9c9c)))
                    ]),
              )
            ]),
          ),
          subIcon == null ? SizedBox() : subIcon
        ]),
      ),
    );
  }

  showActionSheet(BuildContext context) {
    final action = CupertinoActionSheet(
      actions: <Widget>[
        CupertinoActionSheetAction(
          child: Padding(
            padding: EdgeInsets.only(left: 8, right: 8),
            child: Row(
              children: [
                Image.asset('assets/images/icon_photo.png',
                    width: 24, height: 24),
                SizedBox(width: 16),
                Text("Chọn trong thư viện",
                    style: TextStyle(color: Color(0xff333333), fontSize: 14)),
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
            padding: EdgeInsets.only(left: 8, right: 8),
            child: Row(
              children: [
                Image.asset('assets/images/icon_camera_black.png',
                    width: 24, height: 24),
                SizedBox(width: 16),
                Text("Chụp ảnh",
                    style: TextStyle(color: Color(0xff333333), fontSize: 14)),
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
        child: Text("Huỷ",
            style: TextStyle(color: Color(0xff333333), fontSize: 14)),
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
      final imageFile = await ImageCropper.cropImage(
          maxWidth: 320,
          maxHeight: 320,
          aspectRatioPresets: [CropAspectRatioPreset.square],
          compressQuality: 75,
          compressFormat: ImageCompressFormat.jpg,
          cropStyle: CropStyle.circle,
          sourcePath: url,
          androidUiSettings: AndroidUiSettings(
              toolbarTitle: 'Cropper',
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: false),
          iosUiSettings: IOSUiSettings(
            minimumAspectRatio: 1.0,
          ));

      final path = imageFile.path;
      await uploadAvatar(path);
    } catch (_) {
      BotToast.closeAllLoading();
    }
  }

  showAlertDialog(BuildContext context) {
    Widget cancelButton = FlatButton(
      child: Text("Huỷ"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = FlatButton(
      child: Text("Cấp quyền"),
      onPressed: () {
        Navigator.pop(context);
        openAppSettings();
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("Thông báo"),
      content: Text("Bạn cần cấp quyền truy cập để sử dụng tính năng này"),
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
      await UserClient().updateAvatar(AppSettings.userInfo.id, url);
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
      await UserClient().updateUserInfo(AppSettings.userInfo.id, user);
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
    final user = AppSettings.userInfo;
    if (user.isLinkedGoogle) {
      if (user.firstLinkedAccount != 'Google') {
        unlinkedGoogle();
      }
      return;
    }
    try {
      BotToast.showLoading();
      GoogleSignIn _googleSignIn = GoogleSignIn(
        scopes: [
          'email',
          'profile',
        ],
      );
      await _googleSignIn.signOut();
      GoogleSignInAccount account = await _googleSignIn.signIn();
      final result = await LoginClient().linkedAccountOTP({
        'providerName': 'Google',
        'providerKey': account.id,
        'phoneNumber': user.phoneNumber
      });
      BotToast.closeAllLoading();
      Navigator.pushNamed(context, '/verify', arguments: {
        'type': 'linked_google',
        'otp': result.token,
        'phone': user.phoneNumber,
        'remainingRequestCount': result.remainingRequestCount,
        'googleAccount': account
      });
    } catch (e, _) {
      BotToast.closeAllLoading();
      if (e is Error) {
        if (e.code == 'USER002') {
          Message.showToastMessage(context,
              'Tài khoản này đã được liên kết, vui lòng sử dụng tài khoản khác');
        } else {
          Message.showToastMessage(context, e.message);
        }
      }
    }
  }

  linkedFacebook() async {
    final user = AppSettings.userInfo;

    if (user.isLinkedFacebook) {
      if (user.firstLinkedAccount != 'Facebook') {
        unlinkedFacebook();
      }
      return;
    }
    final facebookLogin = FacebookLogin();
    await facebookLogin.logOut();
    final resultFacebook = await facebookLogin.logIn(['email']);
    switch (resultFacebook.status) {
      case FacebookLoginStatus.loggedIn:
        try {
          BotToast.showLoading();

          final result = await LoginClient().linkedAccountOTP({
            'providerName': 'Facebook',
            'providerKey': resultFacebook.accessToken.userId,
            'phoneNumber': user.phoneNumber
          });
          BotToast.closeAllLoading();
          Navigator.pushNamed(context, '/verify', arguments: {
            'type': 'linked_facebook',
            'otp': result.token,
            'phone': user.phoneNumber,
            'remainingRequestCount': result.remainingRequestCount,
            'facebookAccount': resultFacebook
          });
        } catch (e, _) {
          BotToast.closeAllLoading();
          if (e is Error) {
            if (e.code == 'USER002') {
              Message.showToastMessage(context,
                  'Tài khoản này đã được liên kết, vui lòng sử dụng tài khoản khác');
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
      Message.showToastMessage(context, 'Đã huỷ liên kết');
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
      Message.showToastMessage(context, 'Đã huỷ liên kết');
    } catch (e, _) {
      BotToast.closeAllLoading();
      if (e is Error) {
        Message.showToastMessage(context, e.message);
      } else {
        Message.showToastMessage(context, e.toString());
      }
    }
  }

  _showDialogUpdateMotivation(MotivationModel model) {
    showDialog(
        context: context,
        builder: (context) => Container(
                child: AlertDialog(
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
            )));
  }

  _showDialogLogout() {
    showDialog(
        context: context,
        builder: (context) => Container(
              child: AlertDialog(
                  contentPadding: EdgeInsets.all(0),
                  content: Stack(children: [
                    Container(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset('assets/images/icon_logout.png',
                              width: 64, height: 64),
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Text('Bạn muốn đăng xuất?',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: R.color.textDark,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600)),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Text(
                                'Bạn sẽ không thể theo dõi sức khoẻ của mình sau khi thoát. Bạn vẫn muốn đăng xuất khỏi DiaB?',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: R.color.textDark,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400)),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 16),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                            child: Text('Vẫn ở lại',
                                                style: TextStyle(
                                                    color: R.color.textDark,
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w600)),
                                          )),
                                    ),
                                  ),
                                  SizedBox(width: 14),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        AppSettings.logout();
                                      },
                                      child: Container(
                                        height: 43,
                                        decoration: BoxDecoration(
                                            color: R.color.red,
                                            borderRadius:
                                                BorderRadius.circular(200),
                                            gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.centerRight,
                                                colors: [
                                                  R.color.greenGradientTop,
                                                  R.color.greenGradientBottom
                                                ])),
                                        child: Center(
                                          child: Text('Đăng xuất',
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
                  ])),
            ));
  }

  _showDialogUpdateName() {
    final width = MediaQuery.of(context).size.width;
    TextEditingController textEditingController = TextEditingController();
    textEditingController.text = AppSettings.userInfo.fullName;
    showDialog(
        context: context,
        builder: (context) => Container(
              child: AlertDialog(
                  content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Họ và tên',
                            style: TextStyle(
                                color: R.color.textDark,
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                        GestureDetector(
                            child: Icon(Icons.close, color: Color(0xffBEC0C8)),
                            onTap: () {
                              Navigator.pop(context);
                            })
                      ]),
                  SizedBox(height: 16),
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
                                    color: Color(0xffDDDDDD), width: 1.0),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: R.color.mainColor, width: 1.0),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              contentPadding:
                                  EdgeInsets.only(top: 0, left: 16, right: 16),
                              hintText: 'Nhập họ và tên'),
                          onChanged: (value) {})),
                  Container(
                    margin: EdgeInsets.only(top: 16),
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
                                  child: Text('Huỷ',
                                      style: TextStyle(
                                          color: R.color.textDark,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600)),
                                )),
                          ),
                          GestureDetector(
                            onTap: () {
                              final name = textEditingController.text ?? '';
                              if (name.isEmpty) {
                                Message.showToastMessage(
                                    context, 'Bạn chưa nhập tên');
                                return;
                              } else {
                                UserModel userInfo = AppSettings.userInfo;
                                userInfo = UserModel(
                                    id: userInfo.id,
                                    username: userInfo.username,
                                    fullName: name,
                                    age: userInfo.age,
                                    phoneNumber: userInfo.phoneNumber,
                                    secondPhoneNumber:
                                        userInfo.secondPhoneNumber,
                                    gender: userInfo.gender,
                                    genderType: userInfo.genderType,
                                    createDatetime: userInfo.createDatetime,
                                    isActive: userInfo.isActive,
                                    province: userInfo.province,
                                    district: userInfo.district,
                                    height: userInfo.height,
                                    weight: userInfo.weight,
                                    ward: userInfo.ward,
                                    dateOfBirth: userInfo.dateOfBirth,
                                    diabetesStatus: userInfo.diabetesStatus,
                                    diabetesName: userInfo.diabetesName,
                                    diabetesDate: userInfo.diabetesDate,
                                    imageUrl: userInfo.imageUrl,
                                    code: userInfo.code,
                                    email: userInfo.email,
                                    address: userInfo.address,
                                    goalWaist: userInfo.goalWaist,
                                    goalWeight: userInfo.goalWeight,
                                    isLinkedFacebook: userInfo.isLinkedFacebook,
                                    isLinkedGoogle: userInfo.isLinkedGoogle,
                                    isMobileAccount: userInfo.isMobileAccount,
                                    firstLinkedAccount:
                                        userInfo.firstLinkedAccount,
                                    glucoseUnit: userInfo.glucoseUnit);
                                updateUserInfo(userInfo);
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
                                child: Text('Lưu',
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
              )),
            ));
  }

  _showDialogUpdateBirthday() {
    final width = MediaQuery.of(context).size.width;
    DateTime selectedDate = DateTime.fromMillisecondsSinceEpoch(
        AppSettings.userInfo.dateOfBirth * 1000);
    showDialog(
        context: context,
        builder: (context) => Container(
              child: AlertDialog(
                  content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Ngày sinh',
                            style: TextStyle(
                                color: R.color.textDark,
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                        GestureDetector(
                            child: Icon(Icons.close, color: Color(0xffBEC0C8)),
                            onTap: () {
                              Navigator.pop(context);
                            })
                      ]),
                  SizedBox(height: 16),
                  Container(
                      height: 250,
                      width: width - 36,
                      child: BirthDayPicker(
                        selectedDate: DateTime.fromMillisecondsSinceEpoch(
                            AppSettings.userInfo.dateOfBirth * 1000),
                        onChanged: (date) {
                          selectedDate = date;
                        },
                      )),
                  Container(
                    margin: EdgeInsets.only(top: 16),
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
                                  child: Text('Huỷ',
                                      style: TextStyle(
                                          color: R.color.textDark,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600)),
                                )),
                          ),
                          GestureDetector(
                            onTap: () {
                              UserModel userInfo = AppSettings.userInfo;
                              userInfo = UserModel(
                                  id: userInfo.id,
                                  username: userInfo.username,
                                  fullName: userInfo.fullName,
                                  age: userInfo.age,
                                  phoneNumber: userInfo.phoneNumber,
                                  secondPhoneNumber: userInfo.secondPhoneNumber,
                                  gender: userInfo.gender,
                                  genderType: userInfo.genderType,
                                  createDatetime: userInfo.createDatetime,
                                  isActive: userInfo.isActive,
                                  province: userInfo.province,
                                  district: userInfo.district,
                                  height: userInfo.height,
                                  weight: userInfo.weight,
                                  ward: userInfo.ward,
                                  dateOfBirth:
                                      selectedDate.millisecondsSinceEpoch ~/
                                          1000,
                                  diabetesStatus: userInfo.diabetesStatus,
                                  diabetesName: userInfo.diabetesName,
                                  diabetesDate: userInfo.diabetesDate,
                                  imageUrl: userInfo.imageUrl,
                                  code: userInfo.code,
                                  email: userInfo.email,
                                  address: userInfo.address,
                                  goalWaist: userInfo.goalWaist,
                                  goalWeight: userInfo.goalWeight,
                                  isLinkedFacebook: userInfo.isLinkedFacebook,
                                  isLinkedGoogle: userInfo.isLinkedGoogle,
                                  isMobileAccount: userInfo.isMobileAccount,
                                  firstLinkedAccount:
                                      userInfo.firstLinkedAccount,
                                  glucoseUnit: userInfo.glucoseUnit);
                              updateUserInfo(userInfo);
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
                                child: Text('Đồng ý',
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
              )),
            ));
  }

  _showDialogUpdateGender() {
    final width = MediaQuery.of(context).size.width;
    FixedExtentScrollController controller = FixedExtentScrollController(
        initialItem: AppSettings.userInfo.genderType == 1 ? 0 : 1);
    showDialog(
        context: context,
        builder: (context) => Container(
              child: AlertDialog(
                  content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Giới tính',
                            style: TextStyle(
                                color: R.color.textDark,
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                        GestureDetector(
                            child: Icon(Icons.close, color: Color(0xffBEC0C8)),
                            onTap: () {
                              Navigator.pop(context);
                            })
                      ]),
                  SizedBox(height: 16),
                  Container(
                      height: 150,
                      width: width - 36,
                      child: GenderPicker(controller: controller)),
                  Container(
                    margin: EdgeInsets.only(top: 16),
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
                                  child: Text('Huỷ',
                                      style: TextStyle(
                                          color: R.color.textDark,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600)),
                                )),
                          ),
                          GestureDetector(
                            onTap: () {
                              UserModel userInfo = AppSettings.userInfo;
                              userInfo = UserModel(
                                  id: userInfo.id,
                                  username: userInfo.username,
                                  fullName: userInfo.fullName,
                                  age: userInfo.age,
                                  phoneNumber: userInfo.phoneNumber,
                                  secondPhoneNumber: userInfo.secondPhoneNumber,
                                  gender: userInfo.gender,
                                  genderType:
                                      controller.selectedItem == 0 ? 1 : 2,
                                  createDatetime: userInfo.createDatetime,
                                  isActive: userInfo.isActive,
                                  province: userInfo.province,
                                  district: userInfo.district,
                                  height: userInfo.height,
                                  weight: userInfo.weight,
                                  ward: userInfo.ward,
                                  dateOfBirth: userInfo.dateOfBirth,
                                  diabetesStatus: userInfo.diabetesStatus,
                                  diabetesName: userInfo.diabetesName,
                                  diabetesDate: userInfo.diabetesDate,
                                  imageUrl: userInfo.imageUrl,
                                  code: userInfo.code,
                                  email: userInfo.email,
                                  address: userInfo.address,
                                  goalWaist: userInfo.goalWaist,
                                  goalWeight: userInfo.goalWeight,
                                  isLinkedFacebook: userInfo.isLinkedFacebook,
                                  isLinkedGoogle: userInfo.isLinkedGoogle,
                                  isMobileAccount: userInfo.isMobileAccount,
                                  firstLinkedAccount:
                                      userInfo.firstLinkedAccount,
                                  glucoseUnit: userInfo.glucoseUnit);
                              updateUserInfo(userInfo);
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
                                child: Text('Đồng ý',
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
              )),
            ));
  }

  _showDialogUpdateDiabetesStatus() {
    final width = MediaQuery.of(context).size.width;
    int diabetesStatus = AppSettings.userInfo.diabetesStatus;
    showDialog(
        context: context,
        builder: (context) => Container(
              child: AlertDialog(
                  content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Loại bệnh',
                            style: TextStyle(
                                color: R.color.textDark,
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                        GestureDetector(
                            child: Icon(Icons.close, color: Color(0xffBEC0C8)),
                            onTap: () {
                              Navigator.pop(context);
                            })
                      ]),
                  SizedBox(height: 16),
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
                    margin: EdgeInsets.only(top: 16),
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
                                  child: Text('Huỷ',
                                      style: TextStyle(
                                          color: R.color.textDark,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600)),
                                )),
                          ),
                          GestureDetector(
                            onTap: () {
                              UserModel userInfo = AppSettings.userInfo;
                              userInfo = UserModel(
                                  id: userInfo.id,
                                  username: userInfo.username,
                                  fullName: userInfo.fullName,
                                  age: userInfo.age,
                                  phoneNumber: userInfo.phoneNumber,
                                  secondPhoneNumber: userInfo.secondPhoneNumber,
                                  gender: userInfo.gender,
                                  genderType: userInfo.genderType,
                                  createDatetime: userInfo.createDatetime,
                                  isActive: userInfo.isActive,
                                  province: userInfo.province,
                                  district: userInfo.district,
                                  height: userInfo.height,
                                  weight: userInfo.weight,
                                  ward: userInfo.ward,
                                  dateOfBirth: userInfo.dateOfBirth,
                                  diabetesStatus: diabetesStatus,
                                  diabetesName: userInfo.diabetesName,
                                  diabetesDate: userInfo.diabetesDate,
                                  imageUrl: userInfo.imageUrl,
                                  code: userInfo.code,
                                  email: userInfo.email,
                                  address: userInfo.address,
                                  goalWaist: userInfo.goalWaist,
                                  goalWeight: userInfo.goalWeight,
                                  isLinkedFacebook: userInfo.isLinkedFacebook,
                                  isLinkedGoogle: userInfo.isLinkedGoogle,
                                  isMobileAccount: userInfo.isMobileAccount,
                                  firstLinkedAccount:
                                      userInfo.firstLinkedAccount,
                                  glucoseUnit: userInfo.glucoseUnit);
                              updateUserInfo(userInfo);
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
                                child: Text('Đồng ý',
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
              )),
            ));
  }

  _showDialogUpdateDiabetesStatusDate() {
    final width = MediaQuery.of(context).size.width;
    int year = AppSettings.userInfo.diabetesDate;
    showDialog(
        context: context,
        builder: (context) => Container(
              child: AlertDialog(
                  content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Năm phát hiện bệnh',
                            style: TextStyle(
                                color: R.color.textDark,
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                        GestureDetector(
                            child: Icon(Icons.close, color: Color(0xffBEC0C8)),
                            onTap: () {
                              Navigator.pop(context);
                            })
                      ]),
                  SizedBox(height: 16),
                  Container(
                      height: 150,
                      width: width - 36,
                      child: DiabetesStatusDatePicker(
                        year: DateTime.fromMillisecondsSinceEpoch(year * 1000)
                            .year,
                        onChanged: (data) {
                          year = data;
                        },
                      )),
                  Container(
                    margin: EdgeInsets.only(top: 16),
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
                                  child: Text('Huỷ',
                                      style: TextStyle(
                                          color: R.color.textDark,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600)),
                                )),
                          ),
                          GestureDetector(
                            onTap: () {
                              UserModel userInfo = AppSettings.userInfo;
                              userInfo = UserModel(
                                  id: userInfo.id,
                                  username: userInfo.username,
                                  fullName: userInfo.fullName,
                                  age: userInfo.age,
                                  phoneNumber: userInfo.phoneNumber,
                                  secondPhoneNumber: userInfo.secondPhoneNumber,
                                  gender: userInfo.gender,
                                  genderType: userInfo.genderType,
                                  createDatetime: userInfo.createDatetime,
                                  isActive: userInfo.isActive,
                                  province: userInfo.province,
                                  district: userInfo.district,
                                  height: userInfo.height,
                                  weight: userInfo.weight,
                                  ward: userInfo.ward,
                                  dateOfBirth: userInfo.dateOfBirth,
                                  diabetesStatus: userInfo.diabetesStatus,
                                  diabetesName: userInfo.diabetesName,
                                  diabetesDate: DateTime.utc(year)
                                          .millisecondsSinceEpoch ~/
                                      1000,
                                  imageUrl: userInfo.imageUrl,
                                  code: userInfo.code,
                                  email: userInfo.email,
                                  address: userInfo.address,
                                  goalWaist: userInfo.goalWaist,
                                  goalWeight: userInfo.goalWeight,
                                  isLinkedFacebook: userInfo.isLinkedFacebook,
                                  isLinkedGoogle: userInfo.isLinkedGoogle,
                                  isMobileAccount: userInfo.isMobileAccount,
                                  firstLinkedAccount:
                                      userInfo.firstLinkedAccount,
                                  glucoseUnit: userInfo.glucoseUnit);
                              updateUserInfo(userInfo);
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
                                child: Text('Đồng ý',
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
              )),
            ));
  }

  showDialogWeight() {
    showDialog(
      barrierColor: Color(0xff003F38).withOpacity(0.5),
      context: context,
      builder: (_) => CustomNumPicker(
          callback: (number) {
            if (number <= 0) {
              Message.showToastMessage(context, 'Cân nặng phải lớn hơn 0');
              return;
            }
            UserModel userInfo = AppSettings.userInfo;
            userInfo = UserModel(
                id: userInfo.id,
                username: userInfo.username,
                fullName: userInfo.fullName,
                age: userInfo.age,
                phoneNumber: userInfo.phoneNumber,
                secondPhoneNumber: userInfo.secondPhoneNumber,
                gender: userInfo.gender,
                genderType: userInfo.genderType,
                createDatetime: userInfo.createDatetime,
                isActive: userInfo.isActive,
                province: userInfo.province,
                district: userInfo.district,
                height: userInfo.height,
                weight: number * 1.0,
                ward: userInfo.ward,
                dateOfBirth: userInfo.dateOfBirth,
                diabetesStatus: userInfo.diabetesStatus,
                diabetesName: userInfo.diabetesName,
                diabetesDate: userInfo.diabetesDate,
                imageUrl: userInfo.imageUrl,
                code: userInfo.code,
                email: userInfo.email,
                address: userInfo.address,
                goalWaist: userInfo.goalWaist,
                goalWeight: userInfo.goalWeight,
                isLinkedFacebook: userInfo.isLinkedFacebook,
                isLinkedGoogle: userInfo.isLinkedGoogle,
                isMobileAccount: userInfo.isMobileAccount,
                firstLinkedAccount: userInfo.firstLinkedAccount,
                glucoseUnit: userInfo.glucoseUnit);
            updateUserInfo(userInfo);
          },
          title: 'Nhập cân nặng',
          max: 180,
          numberDefault: (AppSettings.userInfo.weight == null ||
                      AppSettings.userInfo.weight == 0
                  ? 50
                  : AppSettings.userInfo.weight)
              .toInt(),
          unit: ''),
    );
  }

  showDialogHeight() {
    showDialog(
      barrierColor: Color(0xff003F38).withOpacity(0.5),
      context: context,
      builder: (_) => CustomNumPicker(
          callback: (data) {
            if (data <= 0) {
              Message.showToastMessage(context, 'Chiều cao phải lớn hơn 0');
              return;
            }
            UserModel userInfo = AppSettings.userInfo;
            userInfo = UserModel(
                id: userInfo.id,
                username: userInfo.username,
                fullName: userInfo.fullName,
                age: userInfo.age,
                phoneNumber: userInfo.phoneNumber,
                secondPhoneNumber: userInfo.secondPhoneNumber,
                gender: userInfo.gender,
                genderType: userInfo.genderType,
                createDatetime: userInfo.createDatetime,
                isActive: userInfo.isActive,
                province: userInfo.province,
                district: userInfo.district,
                height: data * 1.0,
                weight: userInfo.weight,
                ward: userInfo.ward,
                dateOfBirth: userInfo.dateOfBirth,
                diabetesStatus: userInfo.diabetesStatus,
                diabetesName: userInfo.diabetesName,
                diabetesDate: userInfo.diabetesDate,
                imageUrl: userInfo.imageUrl,
                code: userInfo.code,
                email: userInfo.email,
                address: userInfo.address,
                goalWaist: userInfo.goalWaist,
                goalWeight: userInfo.goalWeight,
                isLinkedFacebook: userInfo.isLinkedFacebook,
                isLinkedGoogle: userInfo.isLinkedGoogle,
                isMobileAccount: userInfo.isMobileAccount,
                firstLinkedAccount: userInfo.firstLinkedAccount,
                glucoseUnit: userInfo.glucoseUnit);
            updateUserInfo(userInfo);
          },
          title: 'Nhập chiều cao',
          max: 250,
          numberDefault: (AppSettings.userInfo.height == null ||
                      AppSettings.userInfo.height == 0
                  ? 150
                  : AppSettings.userInfo.height)
              .toInt(),
          unit: ''),
    );
  }

  _showDialogUpdatePhone2() {
    final width = MediaQuery.of(context).size.width;
    TextEditingController textEditingController = TextEditingController();
    textEditingController.text = AppSettings.userInfo.secondPhoneNumber;
    showDialog(
        context: context,
        builder: (context) => Container(
              child: AlertDialog(
                  content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Số điện thoại 2',
                            style: TextStyle(
                                color: R.color.textDark,
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                        GestureDetector(
                            child: Icon(Icons.close, color: Color(0xffBEC0C8)),
                            onTap: () {
                              Navigator.pop(context);
                            })
                      ]),
                  SizedBox(height: 16),
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
                                  color: Color(0xffDDDDDD), width: 1.0),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: R.color.mainColor, width: 1.0),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding:
                                EdgeInsets.only(top: 0, left: 16, right: 16),
                            hintText: 'Nhập số điện thoại 2',
                          ),
                          onChanged: (value) {})),
                  Container(
                    margin: EdgeInsets.only(top: 16),
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
                                  child: Text('Huỷ',
                                      style: TextStyle(
                                          color: R.color.textDark,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600)),
                                )),
                          ),
                          GestureDetector(
                            onTap: () {
                              final phone = textEditingController.text ?? '';
                              if (phone.isEmpty) {
                                Message.showToastMessage(
                                    context, 'Bạn chưa nhập số điện thoại');
                                return;
                              } else {
                                UserModel userInfo = AppSettings.userInfo;
                                userInfo = UserModel(
                                    id: userInfo.id,
                                    username: userInfo.username,
                                    fullName: userInfo.fullName,
                                    age: userInfo.age,
                                    phoneNumber: userInfo.phoneNumber,
                                    secondPhoneNumber: phone,
                                    gender: userInfo.gender,
                                    genderType: userInfo.genderType,
                                    createDatetime: userInfo.createDatetime,
                                    isActive: userInfo.isActive,
                                    province: userInfo.province,
                                    district: userInfo.district,
                                    height: userInfo.height,
                                    weight: userInfo.weight,
                                    ward: userInfo.ward,
                                    dateOfBirth: userInfo.dateOfBirth,
                                    diabetesStatus: userInfo.diabetesStatus,
                                    diabetesName: userInfo.diabetesName,
                                    diabetesDate: userInfo.diabetesDate,
                                    imageUrl: userInfo.imageUrl,
                                    code: userInfo.code,
                                    email: userInfo.email,
                                    address: userInfo.address,
                                    goalWaist: userInfo.goalWaist,
                                    goalWeight: userInfo.goalWeight,
                                    isLinkedFacebook: userInfo.isLinkedFacebook,
                                    isLinkedGoogle: userInfo.isLinkedGoogle,
                                    isMobileAccount: userInfo.isMobileAccount,
                                    firstLinkedAccount:
                                        userInfo.firstLinkedAccount,
                                    glucoseUnit: userInfo.glucoseUnit);
                                updateUserInfo(userInfo);
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
                                child: Text('Lưu',
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
              )),
            ));
  }

  _showDialogUpdateEmail() {
    final width = MediaQuery.of(context).size.width;
    TextEditingController textEditingController = TextEditingController();
    textEditingController.text = AppSettings.userInfo.email ?? '';
    showDialog(
        context: context,
        builder: (context) => EmailValidate(
              controller: textEditingController,
              completion: (email) {
                UserModel userInfo = AppSettings.userInfo;
                userInfo = UserModel(
                    id: userInfo.id,
                    username: userInfo.username,
                    fullName: userInfo.fullName,
                    age: userInfo.age,
                    phoneNumber: userInfo.phoneNumber,
                    secondPhoneNumber: userInfo.secondPhoneNumber,
                    gender: userInfo.gender,
                    genderType: userInfo.genderType,
                    createDatetime: userInfo.createDatetime,
                    isActive: userInfo.isActive,
                    province: userInfo.province,
                    district: userInfo.district,
                    height: userInfo.height,
                    weight: userInfo.weight,
                    ward: userInfo.ward,
                    dateOfBirth: userInfo.dateOfBirth,
                    diabetesStatus: userInfo.diabetesStatus,
                    diabetesName: userInfo.diabetesName,
                    diabetesDate: userInfo.diabetesDate,
                    imageUrl: userInfo.imageUrl,
                    code: userInfo.code,
                    email: email,
                    address: userInfo.address,
                    goalWaist: userInfo.goalWaist,
                    goalWeight: userInfo.goalWeight,
                    isLinkedFacebook: userInfo.isLinkedFacebook,
                    isLinkedGoogle: userInfo.isLinkedGoogle,
                    isMobileAccount: userInfo.isMobileAccount,
                    firstLinkedAccount: userInfo.firstLinkedAccount,
                    glucoseUnit: userInfo.glucoseUnit);
                updateUserInfo(userInfo);
                Navigator.pop(context);
              },
            ));
  }

  _showDialogUpdateAddress() {
    UserModel userInfo = AppSettings.userInfo;
    showDialog(
      context: context,
      builder: (context) => Container(
        child: AlertDialog(
            content: AddressController(
          address: userInfo.address,
          province: userInfo.province,
          district: userInfo.district,
          ward: userInfo.ward,
          callback: (address, province, district, ward) {
            userInfo = UserModel(
                id: userInfo.id,
                username: userInfo.username,
                fullName: userInfo.fullName,
                age: userInfo.age,
                phoneNumber: userInfo.phoneNumber,
                secondPhoneNumber: userInfo.secondPhoneNumber,
                gender: userInfo.gender,
                genderType: userInfo.genderType,
                createDatetime: userInfo.createDatetime,
                isActive: userInfo.isActive,
                province: province,
                district: district,
                height: userInfo.height,
                weight: userInfo.weight,
                ward: ward,
                dateOfBirth: userInfo.dateOfBirth,
                diabetesStatus: userInfo.diabetesStatus,
                diabetesName: userInfo.diabetesName,
                diabetesDate: userInfo.diabetesDate,
                imageUrl: userInfo.imageUrl,
                code: userInfo.code,
                email: userInfo.email,
                address: address,
                goalWaist: userInfo.goalWaist,
                goalWeight: userInfo.goalWeight,
                isLinkedFacebook: userInfo.isLinkedFacebook,
                isLinkedGoogle: userInfo.isLinkedGoogle,
                isMobileAccount: userInfo.isMobileAccount,
                firstLinkedAccount: userInfo.firstLinkedAccount,
                glucoseUnit: userInfo.glucoseUnit);
            updateUserInfo(userInfo);
          },
        )),
      ),
    );
  }
}

typedef EmailValidateCallback = Function(String);

class EmailValidate extends StatefulWidget {
  final TextEditingController controller;
  final EmailValidateCallback completion;
  EmailValidate({this.controller, this.completion});
  @override
  _EmailValidateState createState() => _EmailValidateState();
}

class _EmailValidateState extends State<EmailValidate> {
  bool showValidate = false;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Container(
      child: AlertDialog(
          content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Email',
                style: TextStyle(
                    color: R.color.textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
            GestureDetector(
                child: Icon(Icons.close, color: Color(0xffBEC0C8)),
                onTap: () {
                  Navigator.pop(context);
                })
          ]),
          SizedBox(height: 16),
          Container(
              height: 54,
              width: width - 36,
              child: TextField(
                  controller: widget.controller,
                  keyboardType: TextInputType.emailAddress,
                  minLines: 1,
                  maxLines: 1,
                  obscureText: false,
                  decoration: InputDecoration(
                    fillColor: R.color.textDark,
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xffDDDDDD), width: 1.0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: R.color.mainColor, width: 1.0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding:
                        EdgeInsets.only(top: 0, left: 16, right: 16),
                    hintText: 'Nhập email của bạn',
                  ),
                  onChanged: (email) {
                    String pattern =
                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";

                    RegExp regExp = new RegExp(pattern);
                    final isCorrect = regExp.hasMatch(email);
                    if (!isCorrect) {
                      setState(() {
                        showValidate = true;
                      });
                    } else {
                      setState(() {
                        showValidate = false;
                      });
                    }
                  })),
          showValidate
              ? Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text('Email không hợp lệ',
                      style: TextStyle(
                          color: Color(0xffFF5756),
                          fontSize: 14,
                          fontWeight: FontWeight.w400)),
                )
              : SizedBox(),
          Container(
            margin: EdgeInsets.only(top: 16),
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
                          child: Text('Huỷ',
                              style: TextStyle(
                                  color: R.color.textDark,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600)),
                        )),
                  ),
                  GestureDetector(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      final email = widget.controller.text ?? '';
                      if (email.isEmpty) {
                        Message.showToastMessage(
                            context, 'Bạn chưa nhập email');
                        return;
                      }
                      String pattern =
                          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";

                      RegExp regExp = new RegExp(pattern);
                      final isCorrect = regExp.hasMatch(email);
                      if (!isCorrect) {
                        Message.showToastMessage(context, 'Email không hợp lệ');
                        return;
                      }

                      widget.completion(email);
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
                              colors: [R.color.greenGradientTop, R.color.greenGradientBottom])),
                      child: Center(
                        child: Text('Lưu',
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
      )),
    );
  }
}

typedef BirthDayPickerCallback = Function(DateTime);

class BirthDayPicker extends StatefulWidget {
  final DateTime selectedDate;
  final BirthDayPickerCallback onChanged;
  BirthDayPicker({this.selectedDate, this.onChanged});
  @override
  _BirthDayPickerState createState() => _BirthDayPickerState();
}

class _BirthDayPickerState extends State<BirthDayPicker> {
  DateTime selectedDate;
  @override
  void initState() {
    super.initState();
    selectedDate = widget.selectedDate;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoDatePicker(
        initialDateTime: selectedDate,
        maximumYear: DateTime.now().year,
        minimumYear: 1900,
        mode: CupertinoDatePickerMode.date,
        onDateTimeChanged: (value) {
          widget.onChanged(value);
          setState(() {
            selectedDate = value;
          });
        });
  }
}

class GenderPicker extends StatefulWidget {
  final FixedExtentScrollController controller;
  GenderPicker({this.controller});

  @override
  _GenderPickerState createState() => _GenderPickerState();
}

class _GenderPickerState extends State<GenderPicker> {
  int selectedItem = 0;
  @override
  void initState() {
    super.initState();
    selectedItem = widget.controller.initialItem;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPicker(
        scrollController: widget.controller,
        selectionOverlay: null,
        onSelectedItemChanged: (value) {
          setState(() {
            selectedItem = value;
          });
        },
        itemExtent: 47.0,
        children: List<int>.generate(2, (i) => i)
            .map((e) => Center(
                  child: Text(e == 0 ? 'Nam' : 'Nữ',
                      style: TextStyle(
                          color: selectedItem == e
                              ? Color(0xff01645A)
                              : Color(0xffC0C2C5),
                          fontSize: 24,
                          fontWeight: FontWeight.bold)),
                ))
            .toList());
  }
}

typedef DiabetesStatusCallback = Function(dynamic);

class DiabetesStatusPicker extends StatefulWidget {
  final int state;
  final DiabetesStatusCallback onChanged;
  DiabetesStatusPicker({this.state, this.onChanged});

  @override
  _DiabetesStatusPickerState createState() => _DiabetesStatusPickerState();
}

class _DiabetesStatusPickerState extends State<DiabetesStatusPicker> {
  FixedExtentScrollController scrollController;
  int selectedItem = 0;

  List<dynamic> diabeteStates = [];
  @override
  void initState() {
    super.initState();
    scrollController = FixedExtentScrollController(
        initialItem: widget.state == null ? 0 : (widget.state - 1));
    selectedItem = widget.state == null ? 0 : (widget.state - 1);
    loadData();
  }

  loadData() async {
    BotToast.showLoading();
    diabeteStates = await UserClient().fetchDiabeteStates();
    if (widget.state == null) {
      widget.onChanged(diabeteStates[0]);
      selectedItem = 0;
    }

    BotToast.closeAllLoading();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return diabeteStates.length == 0
        ? SizedBox()
        : CupertinoPicker(
            scrollController: scrollController,
            selectionOverlay: null,
            onSelectedItemChanged: (value) {
              widget.onChanged(diabeteStates[value]);
              setState(() {
                selectedItem = value;
              });
            },
            itemExtent: 47.0,
            children: List<int>.generate(diabeteStates.length, (i) => i)
                .map((e) => Center(
                      child: Text(diabeteStates[e]['value'],
                          style: TextStyle(
                              color: selectedItem == e
                                  ? Color(0xff01645A)
                                  : Color(0xffC0C2C5),
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                    ))
                .toList());
  }
}

typedef DiabetesStatusDateCallback = Function(int);

class DiabetesStatusDatePicker extends StatefulWidget {
  final int year;
  final DiabetesStatusDateCallback onChanged;
  DiabetesStatusDatePicker({this.year, this.onChanged});

  @override
  _DiabetesStatusDatePickerState createState() =>
      _DiabetesStatusDatePickerState();
}

class _DiabetesStatusDatePickerState extends State<DiabetesStatusDatePicker> {
  FixedExtentScrollController scrollController;
  int selectedYear = 0;
  @override
  void initState() {
    super.initState();
    scrollController =
        FixedExtentScrollController(initialItem: widget.year - 1900);
    selectedYear = widget.year - 1900;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPicker(
        scrollController: scrollController,
        selectionOverlay: null,
        onSelectedItemChanged: (value) {
          widget.onChanged(value + 1900);
          setState(() {
            selectedYear = value;
          });
        },
        itemExtent: 47.0,
        children: List<int>.generate(DateTime.now().year + 1 - 1900, (i) => i)
            .map((e) => Center(
                  child: Text((e + 1900).toString(),
                      style: TextStyle(
                          color: (selectedYear) == e
                              ? Color(0xff01645A)
                              : Color(0xffC0C2C5),
                          fontSize: 24,
                          fontWeight: FontWeight.bold)),
                ))
            .toList());
  }
}

typedef MotivationCallback = Function(MotivationModel model);

class MotivationPopup extends StatefulWidget {
  final MotivationModel model;
  final MotivationCallback callback;
  MotivationPopup({this.model, this.callback});
  @override
  _MotivationPopupState createState() => _MotivationPopupState();
}

class _MotivationPopupState extends State<MotivationPopup> {
  TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    textEditingController.text =
        widget.model == null ? '' : widget.model.content;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                    widget.model == null
                        ? 'Động lực mới'
                        : 'Chỉnh sửa động lực',
                    style: TextStyle(
                        color: R.color.textDark,
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
                SizedBox(height: 8),
                Text('Còn ${100 - textEditingController.text.length} ký tự',
                    style: TextStyle(
                        color: Color(0xff666666),
                        fontSize: 16,
                        fontWeight: FontWeight.w400))
              ]),
              GestureDetector(
                  child: Icon(Icons.close, color: Color(0xffBEC0C8)),
                  onTap: () {
                    Navigator.pop(context);
                  })
            ]),
        SizedBox(height: 16),
        Container(
            width: MediaQuery.of(context).size.width - 36,
            child: TextField(
                controller: textEditingController,
                minLines: 3,
                maxLines: 3,
                maxLength: 100,
                inputFormatters: [
                  LengthLimitingTextFieldFormatterFixed(100),
                ],
                obscureText: false,
                decoration: InputDecoration(
                    fillColor: R.color.textDark,
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xffDDDDDD), width: 1.0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: R.color.mainColor, width: 1.0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    hintText: 'Nhập động lực mới',
                    counterText: '',
                    contentPadding: EdgeInsets.all(16)),
                onChanged: (value) {
                  setState(() {});
                })),
        Container(
          margin: EdgeInsets.only(top: 16),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
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
                    child: Text('Huỷ',
                        style: TextStyle(
                            color: R.color.textDark,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                  )),
            ),
            GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
                final content = textEditingController.text ?? '';
                if (content.isEmpty) {
                  Message.showToastMessage(context, 'Bạn chưa nhập nội dung');
                  return;
                } else {
                  widget.callback(widget.model == null
                      ? MotivationModel(
                          content: content, id: null, createDateTime: null)
                      : MotivationModel(
                          content: content,
                          id: widget.model.id,
                          createDateTime: widget.model.createDateTime));
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
                        colors: [R.color.greenGradientTop, R.color.greenGradientBottom])),
                child: Center(
                  child: Text('Lưu',
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
    );
  }
}

class LengthLimitingTextFieldFormatterFixed
    extends LengthLimitingTextInputFormatter {
  LengthLimitingTextFieldFormatterFixed(int maxLength) : super(maxLength);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (maxLength != null &&
        maxLength > 0 &&
        newValue.text.characters.length > maxLength) {
      // If already at the maximum and tried to enter even more, keep the old
      // value.
      if (oldValue.text.characters.length == maxLength) {
        return oldValue;
      }
      // ignore: invalid_use_of_visible_for_testing_member
      return LengthLimitingTextInputFormatter.truncate(newValue, maxLength);
    }
    return newValue;
  }
}
