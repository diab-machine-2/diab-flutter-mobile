import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:easy_localization/easy_localization.dart';
class BloodPressureDetailItem extends StatelessWidget {
  final List _elements = [
    {
      'title': R.string.grade_2_hypertension.tr(),
      'name': 'Sau ăn trưa',
      'group': '14 tháng 12 năm 2020',
      'number': '165/100',
      'heart': '130',
      'status': 'high',
      'hour': '12:15',
      'note': 'Tôi vận động cường độ cao liên tục trong nhiều giờ'
    },
    {
      'title': R.string.normal.tr(),
      'name': 'Trước ăn trưa',
      'group': '12 tháng 12 năm 2020',
      'number': '125/83',
      'heart': '70',
      'hour': '12:15',
      'status': 'low',
      'note': ''
    },
  ];
  final bool hasNote;
  BloodPressureDetailItem(this.hasNote);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: GroupedListView<dynamic, dynamic>(
        elements: _elements,
        groupBy: (element) => element['group'],
        order: GroupedListOrder.DESC,
        useStickyGroupSeparators: true,
        stickyHeaderBackgroundColor: R.color.transparent,
        groupSeparatorBuilder: (dynamic value) => Padding(
          padding:
              const EdgeInsets.only(left: 16, right: 16, top: 24, bottom: 8),
          child: Text(
            value,
            textAlign: TextAlign.left,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
        itemBuilder: (c, element) {
          return GestureDetector(
            onTap: () {
              print(element['title']);
              Navigator.pushNamed(context, NavigatorName.blood_pressure_table,
                  arguments: element['title']);
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: R.color.white),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.only(
                                left: 16, right: 16, top: 8, bottom: 8),
                            decoration: BoxDecoration(
                                color: chooseColor(element['status']),
                                // borderRadius: BorderRadius.circular(13))
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(13),
                                    topRight: Radius.circular(13),
                                    bottomRight: Radius.circular(13))),
                            child: Text(element['title'],
                                style: TextStyle(
                                    color: R.color.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700)),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Text(element['number'],
                                  style: TextStyle(
                                      color: chooseColor(element['status']),
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700)),
                              SizedBox(width: 4),
                              Text(R.string.mm_hg.tr(),
                                  style: TextStyle(
                                      color: R.color.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w400)),
                              SizedBox(width: 8),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: Text('.',
                                    style: TextStyle(
                                        color: R.color.black,
                                        fontSize: 30,
                                        fontWeight: FontWeight.w700)),
                              ),
                              SizedBox(width: 8),
                              Text(element['heart'],
                                  style: TextStyle(
                                      color: chooseColor(element['status']),
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700)),
                              SizedBox(width: 4),
                              Text(R.string.time_per_minute.tr(),
                                  style: TextStyle(
                                      color: R.color.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w400)),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            element['hour'],
                            style: TextStyle(
                                color: R.color.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w400),
                          ),
                          SizedBox(width: 4),
                          Text(element['name'],
                              style: TextStyle(
                                  color: R.color.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400)),
                        ],
                      ),
                      element['note'] != ''
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 16),
                                Container(height: 1, color: R.color.color0xffEEEFF3),
                                SizedBox(height: 16),
                                Text(element['note'],
                                    style: TextStyle(
                                        color: R.color.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400)),
                              ],
                            )
                          : SizedBox()
                    ]),
                  )),
            ),
          );
        },
      ),
    );
  }
}

handleStatus(status) {
  switch (status) {
    case 'high':
      {
        return R.string.high.tr();
      }
      break;

    case 'low':
      {
        return R.string.low.tr();
      }
      break;

    default:
      {
        return R.string.good.tr();
      }
      break;
  }
}

chooseColor(status) {
  switch (status) {
    case 'high':
      {
        return R.color.red;
      }
      break;

    case 'low':
      {
        return R.color.green;
      }
      break;

    default:
      {
        return R.color.statusAverage;
      }
      break;
  }
}
