import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/utils/date_utils.dart';
import 'package:medical/src/utils/length_limit_text_field.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/base/text_field_custom.dart';
import 'package:medical/src/widget/dsmes_appointment/dsmes_appointment_cubit.dart';
import 'package:medical/src/widget/dsmes_appointment/pages/dsmes_navigation_mixin.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/my_plan_screens/activity_tab/create_goal/models/day_in_week.dart';
import 'package:medical/src/widgets/gap_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class DsmesConfirmCreateInformation extends StatefulWidget {
  final String serviceType;

  const DsmesConfirmCreateInformation({
    Key? key,
    required this.serviceType,
  }) : super(key: key);

  @override
  _DsmesConfirmCreateInformationState createState() =>
      _DsmesConfirmCreateInformationState();
}

class _DsmesConfirmCreateInformationState
    extends State<DsmesConfirmCreateInformation> {
  late DsmesAppointmentCubit _cubit;
  late String requesterName;
  late String requesterPhone;

  FocusNode nameFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _cubit = context.read<DsmesAppointmentCubit>();
    requesterName = AppSettings.userInfo?.fullName ?? '';
    requesterPhone = AppSettings.userInfo?.phoneNumber ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              R.color.color0xFFFDC798.withOpacity(0.3),
              R.color.greenbg.withOpacity(0.9),
            ],
            begin: FractionalOffset(1, 1),
            end: FractionalOffset(0.9, 0.5),
            stops: [0.0, 1.0],
          ),
        ),
        child: _buildPage(context),
      ),
    );
  }

  Widget _buildPage(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            CustomAppBar(
              backgroundColor: Colors.transparent,
              title: Text(
                R.string.confirm_information.tr(),
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    // fontFamily: 'sfpro',
                    color: R.color.textDark),
              ),
              actions: [],
              leadingIcon: IconButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                icon: Icon(
                  Icons.arrow_back,
                  color: R.color.textDark,
                ),
                onPressed: () {
                  DsmesNavigationMixin.navigationKey.currentState?.pop(context);
                },
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildPatientInformation(),
                      GapH(12),
                      _buildConsultingInformation(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            color: R.color.white,
            child: Row(
              children: [
                Expanded(
                  child: _buildButton(
                      R.string.confirm_book_consult.tr(), () async {}),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String getTimeRange(String startTime, String endTime) {
    final start = DateFormat('HH:mm')
        .format(DateFormat('yyyy-MM-dd HH:mm').parse(startTime));
    final end = DateFormat('HH:mm')
        .format(DateFormat('yyyy-MM-dd HH:mm').parse(endTime));
    return '$start-$end';
  }

  String getFormattedDate(String startTime) {
    final date = DateFormat('yyyy-MM-dd HH:mm').parse(startTime);
    final weekDay = DateUtil.weekDayToString(date, isDisplayfull: true);
    return '$weekDay, ${DateFormat('dd/MM/yyyy').format(date)}';
  }

  _buildPatientInformation() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: R.color.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  R.string.consult_information.tr().toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: R.color.color0xff141416,
                  ),
                ),
                InkWell(
                  onTap: () {
                    _showEditRequesterInformationBottomSheet();
                  },
                  child: Text(
                    R.string.chinh_sua.tr(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: R.color.color0xff239A90,
                    ),
                  ),
                ),
              ],
            ),
            GapH(16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  R.string.name.tr(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: R.color.color0xff777E90,
                  ),
                ),
                Text(
                  requesterName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: R.color.color0xff141416,
                  ),
                ),
              ],
            ),
            GapH(4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  R.string.so_dien_thoai.tr(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: R.color.color0xff777E90,
                  ),
                ),
                Text(
                  requesterPhone,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: R.color.color0xff141416,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _buildConsultingInformation() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: R.color.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  R.string.consult_direct.tr().toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: R.color.color0xff141416,
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    R.string.chinh_sua.tr(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: R.color.color0xff239A90,
                    ),
                  ),
                ),
              ],
            ),
            GapH(16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  R.string.consult_time.tr(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: R.color.color0xff777E90,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      getTimeRange(_cubit.createDsmesBookingRequest!.startTime,
                          _cubit.createDsmesBookingRequest!.endTime),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: R.color.color0xffA36E2A,
                      ),
                    ),
                    Text(
                      getFormattedDate(
                          _cubit.createDsmesBookingRequest!.startTime),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: R.color.color0xffA36E2A,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            GapH(4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 3,
                  child: Text(
                    R.string.center_name.tr(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: R.color.color0xff777E90,
                    ),
                  ),
                ),
                Flexible(
                  flex: 7,
                  child: Text(
                    _cubit.selectedClinic?.name ?? '',
                    maxLines: 2,
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: R.color.color0xff141416,
                    ),
                  ),
                ),
              ],
            ),
            GapH(4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 3,
                  child: Text(
                    R.string.address.tr(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: R.color.color0xff777E90,
                    ),
                  ),
                ),
                Flexible(
                  flex: 7,
                  child: Text(
                    _cubit.selectedClinic?.address ?? '',
                    maxLines: 2,
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: R.color.color0xff141416,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 44,
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: R.color.mainColor,
          borderRadius: BorderRadius.circular(200),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.centerRight,
            colors: [
              R.color.greenGradientTop,
              R.color.greenGradientMid,
              R.color.greenGradientBottom,
            ],
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: R.color.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  _showEditRequesterInformationBottomSheet() {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: 400,
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              R.string.change_consult_info.tr(),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Divider(
                color: R.color.color0xffE6E8EC,
              ),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(
                R.string.last_name_and_first_name.tr(),
                style: TextStyle(
                    color: R.color.textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
            ]),
            GapH(8),
            Container(
              height: 54,
              child: TextFormField(
                minLines: 1,
                maxLines: 1,
                maxLength: 50,
                inputFormatters: [
                  LengthLimitingTextFieldFormatterFixed(50),
                ],
                obscureText: false,
                initialValue: requesterName,
                decoration: InputDecoration(
                    fillColor: R.color.textDark,
                    counterText: '',
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: R.color.grayComponentBorder, width: 1.0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: R.color.mainColor, width: 1.0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding:
                        const EdgeInsets.only(top: 0, left: 16, right: 16),
                    hintText: R.string.name.tr()),
                onChanged: (value) {
                  requesterName = value;
                },
              ),
            ),
            GapH(16),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(
                R.string.phone_number.tr(),
                style: TextStyle(
                    color: R.color.textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
            ]),
            GapH(8),
            Container(
              height: 54,
              child: TextFormField(
                minLines: 1,
                maxLines: 1,
                maxLength: 50,
                inputFormatters: [
                  LengthLimitingTextFieldFormatterFixed(50),
                ],
                obscureText: false,
                initialValue: requesterPhone,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    fillColor: R.color.textDark,
                    counterText: '',
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: R.color.grayComponentBorder, width: 1.0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: R.color.mainColor, width: 1.0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding:
                        const EdgeInsets.only(top: 0, left: 16, right: 16),
                    hintText: R.string.name.tr()),
                onChanged: (value) {
                  requesterPhone = value;
                },
              ),
            ),
            GapH(16),
            _buildButton(R.string.confirm.tr(), () {
              const String pattern = r'(^(?:[+0]9)?[0-9]{9}|\d{10}$)';
              final RegExp regExp = RegExp(pattern);
              final isCorrect = regExp.hasMatch(requesterPhone);
              if (requesterPhone.length != 9 &&
                  requesterPhone.length != 10 &&
                  !isCorrect) {
                Message.showToastMessage(
                    context, R.string.phone_not_valid.tr());
              }

              if (requesterName.isEmpty) {
                Message.showToastMessage(
                    context, R.string.full_name_at_least_character.tr());
              }

              _cubit.updateCreateDsmesBookingRequestRequesterInfo(
                  name: requesterName, phone: requesterPhone);

              
            })
          ],
        ),
      ),
    );
  }
}
