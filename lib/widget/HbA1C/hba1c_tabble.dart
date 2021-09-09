import 'package:flutter/material.dart';

class HbA1CTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white.withOpacity(0.90),
        body: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 20, bottom: 20),
                    child: Text('Bảng chỉ số HbA1C & đường huyết',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w700)),
                  ),
                  Expanded(
                      child: Center(
                          child:
                              Image.asset('assets/images/tabble_hba1c.png'))),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: 50,
                      width: 50,
                      child: Image.asset('assets/images/icon_close_border.png'),
                    ),
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
