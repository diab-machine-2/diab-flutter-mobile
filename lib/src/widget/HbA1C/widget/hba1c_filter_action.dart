import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/theme/app_theme.dart';

class FilterAction extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        ItemFilter(R.drawable.icon_filter, 'Xem nguỡng HbA1C',
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
            Image.asset(R.drawable.icon_filter, width: 24, height: 24),
            SizedBox(width: 8),
            Text('Bộ lọc', style: TextStyle(color: R.color.primaryColor)),
          ],
        ));
  }
}

class ItemFilter extends StatelessWidget {
  final String image;
  final String name;

  final int size;
  ItemFilter(this.image, this.name, {@required this.size});
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
