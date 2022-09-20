import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';

import '../widgets/index.dart';

class VoucherListView extends StatelessWidget {
  const VoucherListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: R.color.color0xffB1DDDB,
      child: Scaffold(
        appBar: CustomAppBar(
          backgroundColor: R.color.transparent,
          title: Text(
            R.string.voucher_list.tr(),
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
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 25),
          color: R.color.color0xfff5f5f5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                R.string.voucher_have
                    .tr()
                    .replaceFirst("[NUMBER_VOUCHER]", "12"),
              ),
              SizedBox(height: 25),
              Expanded(
                child: ListView(
                  children: [
                    VoucherListItem(isUsed: true),
                    VoucherListItem(),
                    VoucherListItem(),
                    VoucherListItem(),
                    VoucherListItem(),
                    VoucherListItem(),
                    VoucherListItem(),
                    VoucherListItem(),
                    VoucherListItem(),
                    VoucherListItem(),
                    VoucherListItem(),
                    VoucherListItem(),
                    VoucherListItem(),
                    VoucherListItem(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
