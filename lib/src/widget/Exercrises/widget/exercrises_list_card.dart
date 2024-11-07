import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/firebase_tracking/kpi_motion_tracking.dart';
import 'package:medical/src/modal/exercrises/exercrise_input.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widgets/network_image_widget.dart';

class ExercrisesListCard extends StatelessWidget {
  final InputExercriseModel itemInput;
  const ExercrisesListCard({Key? key, required this.itemInput})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool dataSyncFromHealth =
        itemInput.exercise.first.category == 'Đi bộ (health app)';

    late Widget valueItem;
    if (dataSyncFromHealth) {
      valueItem = Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                  '${formatNumber(itemInput.exercise.first.value!.toDouble())}',
                  style: TextStyle(
                      fontFamily: 'Viga',
                      color: R.color.green,
                      fontSize: 24,
                      fontWeight: FontWeight.w400)),
              Padding(
                padding: const EdgeInsets.only(bottom: 5.0),
                child: Text(' Bước',
                    style: TextStyle(
                        color: R.color.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w400)),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${formatNumber(itemInput.exercise.first.burnedCalorie)}',
                  style: TextStyle(
                      fontFamily: 'Viga',
                      color: R.color.green,
                      fontSize: 24,
                      fontWeight: FontWeight.w400)),
              Padding(
                padding: const EdgeInsets.only(bottom: 5.0),
                child: Text(' Kcal',
                    style: TextStyle(
                        color: R.color.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w400)),
              ),
            ],
          ),
        ],
      );
    } else {
      valueItem = Row(
        children: [
          Text('${formatNumber(itemInput.burnedCalorie)}',
              style: TextStyle(
                  fontFamily: 'Viga',
                  color: R.color.green,
                  fontSize: 24,
                  fontWeight: FontWeight.w400)),
          Text(' ${R.string.kcal.tr()}',
              style: TextStyle(
                  color: R.color.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w400))
        ],
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () {
          bool isNotSyncFromHealth =
              itemInput.exercise.first.name != "Đi bộ (health app)";
          print('isNotSyncFromHealth: $isNotSyncFromHealth');
          if (isNotSyncFromHealth) {
            KpiMotionTracking.clickKpiItem();
            Navigator.pushNamed(context, NavigatorName.add_exercrises,
                arguments: {'type': 'update', 'id': itemInput.id});
          }
        },
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16), color: R.color.white),
          child: Column(
            children: [
              dataSyncFromHealth
                  ? SizedBox(height: 10)
                  : Padding(
                      padding: EdgeInsets.all(16),
                      child: Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                                convertToUTC(itemInput.date!, 'HH:mm') +
                                    ', ' +
                                    itemInput.timeFrame!,
                                style: TextStyle(
                                    color: R.color.textDark,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600)),
                            valueItem
                          ],
                        ),
                      ),
                    ),
              ListView.separated(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding:
                      EdgeInsets.only(left: 0, right: 0, bottom: 8, top: 0),
                  itemCount: itemInput.exercise.length,
                  separatorBuilder: (BuildContext context, int index) {
                    return Container(height: 1, color: R.color.grayBorder);
                  },
                  itemBuilder: (BuildContext context, int index) {
                    final itemInputExercrise = itemInput.exercise[index];
                    print(itemInput.exercise[index].imageUrl.url);
                    return Container(
                      padding: EdgeInsets.only(
                          left: 16, right: 16, top: 8, bottom: 8),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(0),
                          color: R.color.white),
                      child: Row(
                        children: [
                          Stack(
                              alignment: AlignmentDirectional.center,
                              children: [
                                Image.asset(R.drawable.bg_activity_empty,
                                    width: 50, height: 50),
                                NetWorkImageWidget(
                                    imageUrl: itemInput
                                            .exercise[index].imageUrl.url ??
                                        '',
                                    width: 35,
                                    height: 35)
                              ]),
                          SizedBox(
                            width: 12,
                          ),
                          Expanded(
                              child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              dataSyncFromHealth
                                  ? valueItem
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(itemInputExercrise.category!,
                                            style: TextStyle(
                                                color: R.color.textDark,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600)),
                                        Row(
                                          children: [
                                            Text(
                                                formatNumber(itemInputExercrise
                                                    .burnedCalorie),
                                                style: TextStyle(
                                                    fontFamily: 'Viga',
                                                    color: R.color.textDark,
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.w400)),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  top: 0, left: 4),
                                              child: Text(
                                                itemInputExercrise.unit!,
                                                style: TextStyle(
                                                    color: R.color.textDark,
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 16.0),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(itemInputExercrise.name!,
                                        style: TextStyle(
                                            color: R.color.primaryGreyColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400)),
                                  ),
                                  // SizedBox(
                                  //   width: 2,
                                  // ),
                                  // if (!dataSyncFromHealth)
                                  Text(
                                    '${itemInputExercrise.duration!.toInt().toString()} ${R.string.minute.tr()}',
                                    style: TextStyle(
                                        color: R.color.primaryGreyColor,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12.0),
                                  ),
                                ],
                              )
                            ],
                          )),
                        ],
                      ),
                    );
                  }),
              SizedBox(height: 8)
            ],
          ),
        ),
      ),
    );
  }
}
