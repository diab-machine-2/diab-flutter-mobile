import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widgets/button_widget.dart';

class VoucherDetailView extends StatelessWidget {
  const VoucherDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double paddingBottom = MediaQuery.of(context).padding.bottom + 10;
    return Container(
      color: R.color.color0xffB1DDDB,
      child: Scaffold(
        bottomSheet: Container(
          padding: EdgeInsets.fromLTRB(15, 15, 15, paddingBottom),
          decoration: BoxDecoration(
            color: R.color.white,
            boxShadow: [
              BoxShadow(
                color: R.color.grey.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 7,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ButtonWidget(
            title: R.string.use_voucher.tr(),
            onPressed: () {},
          ),
        ),
        appBar: CustomAppBar(
          backgroundColor: R.color.transparent,
          title: Text(
            R.string.voucher_detail.tr(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: R.color.textDark,
            ),
          ),
          leadingIcon: IconButton(
            splashColor: R.color.transparent,
            highlightColor: R.color.transparent,
            icon: Icon(Icons.arrow_back, color: R.color.textDark),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Container(
          padding: EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 55 + paddingBottom,
          ),
          color: R.color.color0xfff5f5f5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              
            ],
          ),
        ),
      ),
    );
  }
}
