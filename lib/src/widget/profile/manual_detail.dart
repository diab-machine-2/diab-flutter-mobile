import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/user/manual.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:url_launcher/url_launcher.dart';

class ManualDetailController extends StatelessWidget {
  final ManualModel model;
  ManualDetailController({this.model});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [
                      R.color.color0xFFFDC798.withOpacity(0.3),
                      R.color.greenbg.withOpacity(0.9),
                    ],
                    begin: FractionalOffset(1, 1),
                    end: FractionalOffset(0.9, 0.5),
                    stops: [0.0, 1.0])),
            child: Column(children: [
              CustomAppBar(
                backgroundColor: R.color.transparent,
                title: Text(model.question,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: R.color.textDark)),
                leadingIcon: IconButton(
                    splashColor: R.color.transparent,
                    highlightColor: R.color.transparent,
                    icon: Icon(Icons.arrow_back, color: R.color.textDark),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
              ),
              Expanded(
                child: ListView(padding: EdgeInsets.all(0), children: [
                  Html(
                      data: model.answer,
                      onLinkTap: (url, context, attributes, element) async {
                        await canLaunch(url)
                            ? await launch(url,
                                forceSafariVC: false, forceWebView: false)
                            : throw 'Could not launch $url';
                      })
                ]),
              )
            ])));
  }
}
