import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:medical/res/R.dart';

import '../views/device_detail_view.dart';

class DeviceItemWidget extends StatelessWidget {
  const DeviceItemWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (ctx) => DeviceDetailView(),
        ),
      ),
      child: Container(
        padding: EdgeInsets.all(13),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    height: 96,
                    width: 96,
                    padding: EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Color(0xffF2F2F2),
                      ),
                    ),
                    child: Image.network(
                      'https://placehold.co/100x100',
                      height: 100,
                      width: 100,
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      'Accu Chek Instant',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(width: 15),
            SvgPicture.asset(
              R.icons.ic_chevron_right,
              width: 22,
              color: Color(0xffB1B5C3),
              fit: BoxFit.scaleDown,
            ),
          ],
        ),
      ),
    );
  }
}
