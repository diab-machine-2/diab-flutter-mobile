import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../app_setting/app_setting.dart';
import '../../../../model/preference/app_preference.dart';
import '../../../../utils/const.dart';

class PopupStore extends StatefulWidget {
  const PopupStore({
    Key? key,
  }) : super(key: key);

  @override
  State<PopupStore> createState() => _PopupStoreState();
}

class _PopupStoreState extends State<PopupStore> {
  final String? accessToken = appPreference.getData(Const.TOKEN);

  var user = AppSettings.userInfo!;
  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Ưu đãi dành cho bạn",
            style: TextStyle(
              //     color: R.color.accentColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              height: 1.375,
            ),
          ),
          Container(
            height: 30,
            width: 35,
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.clear),
            ),
            margin: EdgeInsets.zero,
          ),
        ],
      ),
      titlePadding: EdgeInsets.fromLTRB(10, 0, 0, 0),
      content: GestureDetector(
        onTap: () {
          _launchWEBSITE();
          Navigator.pop(context);
        },
        child: Container(
          margin: EdgeInsets.zero,
          child: Image.asset(
            R.drawable.promotion_popup,
            fit: BoxFit.fill,
          ),
        ),
      ),
      contentPadding: EdgeInsets.fromLTRB(10, 5, 10, 0),
      actions: [
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Checkbox(
                    value: _isChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        _isChecked = value!;
                        if (value == true) {
                          UserClient().updateCheckedPopup();
                        } else {}
                      });
                    },
                  ),
                  Text(
                    'Không hiển thị lại',
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
            SizedBox(width: 15),
            GestureDetector(
              onTap: () {
                _launchWEBSITE();
                Navigator.pop(context);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                decoration: BoxDecoration(
                    color: R.color.red,
                    borderRadius: BorderRadius.circular(200),
                    gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.centerRight,
                        colors: [
                          R.color.greenGradientTop,
                          R.color.greenGradientBottom
                        ])),
                child: Center(
                  child: Text('Xem ngay',
                      style: TextStyle(
                          color: R.color.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  void _launchWEBSITE() async {
    const url = 'https://diab.com.vn/danh-sach-san-pham/?p=may-do-duong-huyet';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
