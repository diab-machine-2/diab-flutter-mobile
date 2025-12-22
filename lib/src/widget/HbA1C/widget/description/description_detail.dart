import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/HbA1C/short_gui.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:html/dom.dart' as dom;

class DetailDescription extends StatelessWidget {
  final bool input;
  final ShortGuiModel? data;
  final String title;
  final bool isShowTitle;
  final double titleFontSize;

  DetailDescription(
      {required this.input,
      required this.data,
      required this.title,
      this.isShowTitle = true,
      this.titleFontSize = 20});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: R.color.transparent,
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
                          image: AssetImage(R.drawable.bg_des),
                          fit: BoxFit.fill,
                        ),
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: 8),
                          Visibility(
                            visible: isShowTitle,
                            child: Row(children: [
                              Image.asset(
                                R.drawable.img_des,
                                width: 99,
                                height: 85,
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Text(title,
                                    style: TextStyle(
                                        color: R.color.black,
                                        fontSize: titleFontSize,
                                        fontWeight: FontWeight.w600)),
                              )
                            ]),
                          ),
                          SizedBox(height: 16),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 16),
                              child: ListView(children: [
                                Html(
                                    data: (input
                                            ? data?.content2
                                            : data?.content4) ??
                                        "",
                                    onLinkTap: (String? url,
                                        Map<String, String> attributes,
                                        dom.Element? element) {
                                      Utils.launchURL(url ?? "");
                                    })
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
                            color: R.color.greenGradientTop,
                            borderRadius: BorderRadius.circular(30)),
                        child: IconButton(
                            icon: Icon(Icons.close, color: R.color.white),
                            onPressed: () async {
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
