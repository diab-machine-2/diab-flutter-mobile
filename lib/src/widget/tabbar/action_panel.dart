import 'dart:ui';

import 'package:flutter/material.dart';

class ActionPanel extends StatelessWidget {
  final List<String> titles = [
    'Đuờng huyết',
    'Huyết áp',
    'Vận động',
    'Cân nặng',
    'Dinh dưỡng',
    'Cảm xúc',
  ];
  final List<String> icons = [
    'icon_duong_huyet',
    'icon_huyet_ap',
    'icon_van_dong',
    'icon_can_nang',
    'icon_dinh_duong',
    'icon_cam_xuc'
  ];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
            GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsets.only(left: 16, right: 16),
                itemCount: titles.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, childAspectRatio: 1),
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      if (index == 0) {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/add_bloodSugar',
                            arguments: {'type': 'input', 'id': null});
                      }
                      if (index == 1) {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/add_bloodPressure',
                            arguments: {
                              'type': 'input',
                            });
                      }
                      if (index == 2) {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/add_exercrises',
                            arguments: {
                              'type': 'input',
                            });
                      }
                      if (index == 3) {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/add_bmi', arguments: {
                          'type': 'input',
                        });
                      }
                      if (index == 4) {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/add_food',
                            arguments: {'type': 'input'});
                      }
                      if (index == 5) {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/add_emo',
                            arguments: {'type': 'input'});
                      }
                    },
                    child: Container(
                        color: Colors.transparent,
                        child: Column(children: [
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30)),
                            width: 60,
                            height: 60,
                            child: Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: Image.asset(
                                  'assets/images/' + icons[index] + '.png',
                                  width: 40,
                                  height: 40),
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(titles[index],
                              style: TextStyle(color: Colors.white))
                        ])),
                  );
                }),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/add_hba1c',
                    arguments: {'type': 'input', 'id': null});
              },
              child: Container(
                  color: Colors.transparent,
                  child: Column(children: [
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30)),
                      width: 60,
                      height: 60,
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Image.asset('assets/images/icon_a1c.png',
                            width: 40, height: 40),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text('HbA1C', style: TextStyle(color: Colors.white))
                  ])),
            ),
            SizedBox(height: 60),
            Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  height: 50,
                  width: 50,
                  child: Image.asset('assets/images/icon_close_action.png'),
                ),
              ),
            ),
            SizedBox(height: 10)
          ]),
        ),
      ),
    );
  }
}
