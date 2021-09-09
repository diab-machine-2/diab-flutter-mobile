import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:medical/modal/HbA1C/short_gui.dart';

class DetailDescription extends StatelessWidget {
  final bool input;
  final ShortGuiModel data;
  final String title;
  DetailDescription(
      {@required this.input, @required this.data, @required this.title});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
          child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/bg_des.png'),
                          fit: BoxFit.fill,
                        ),
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: 8),
                          Row(children: [
                            Image.asset(
                              'assets/images/icon_des.png',
                              width: 99,
                              height: 85,
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Text(title,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600)),
                            )
                          ]),
                          SizedBox(height: 16),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 16),
                              child: ListView(children: [
                                Html(
                                    data: input ? data.content2 : data.content4)
                              ]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: Color(0xff4BB2AB),
                            borderRadius: BorderRadius.circular(30)),
                        child: IconButton(
                            icon: Icon(Icons.close, color: Colors.white),
                            onPressed: () {
                              Navigator.pop(context);
                            }),
                      ),
                    ),
                  )
                ],
              ))),
    );
  }
}
