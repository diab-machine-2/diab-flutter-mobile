import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/bmi/views/add_bmi_view_old/add_bmi_cubit.dart';

class SectionInputNote extends StatelessWidget {
  final AddBmiCubit cubit;
  const SectionInputNote({Key? key, required this.cubit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: TextField(
        controller: cubit.controllerNote,
        style: TextStyle(
            color: R.color.black, fontSize: 16, fontWeight: FontWeight.w400),
        decoration: InputDecoration(
          hintText: R.string.nhap_ghi_chu_cua_ban.tr(),
          contentPadding: EdgeInsets.only(bottom: 8),
          border: InputBorder.none,
          counterText: '',
          hintStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Color(0xFFA1A3A6),
          ),
        ),
      ),
    );
  }
}
