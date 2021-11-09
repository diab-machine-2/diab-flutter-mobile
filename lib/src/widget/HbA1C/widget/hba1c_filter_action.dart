import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:easy_localization/easy_localization.dart';

class FilterAction extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        ItemFilter(R.drawable.ic_filter, R.string.xem_nguong_hba1c.tr(),
            size: 3),
        SizedBox(width: 16),
        buildContainer()
      ]),
    );
  }

  Container buildContainer() {
    return Container(
        padding: EdgeInsets.only(left: 24, right: 24),
        decoration: BoxDecoration(
            color: R.color.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: R.color.primaryColor)),
        height: 40,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(R.drawable.ic_filter, width: 24, height: 24),
            SizedBox(width: 8),
            Text(R.string.filter.tr(), style: TextStyle(color: R.color.primaryColor)),
          ],
        ));
  }
}

class ItemFilter extends StatelessWidget {
  final String image;
  final String name;

  final int size;
  ItemFilter(this.image, this.name, {required this.size});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
          padding: EdgeInsets.only(left: 24, right: 24),
          decoration: BoxDecoration(
              color: R.color.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: R.color.primaryColor)),
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(this.image, width: 24, height: 24),
              SizedBox(width: 8),
              Text(this.name, style: TextStyle(color: R.color.primaryColor)),
            ],
          )),
    );
  }
}
