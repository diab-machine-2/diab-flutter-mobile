import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/navigator_name.dart';

class SyncAccountModal extends StatefulWidget {
  @override
  _SyncAccountModalState createState() => _SyncAccountModalState();
}

class _SyncAccountModalState extends State<SyncAccountModal> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width * 0.4;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 16.0,
        right: 16.0,
        top: 16.0,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              R.string.first_login_zalo.tr(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 10),
            Text(
              R.string.question_sync_zalo.tr(), // Use R.string here
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    height: 48,
                    width: width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(200),
                      border:
                          Border.all(color: R.color.green), // Use R.color here
                    ),
                    child: Center(
                      child: Text(
                        R.string.not_yet.tr(), // Use R.string here
                        style: TextStyle(
                          color: R.color.green, // Use R.color here
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, NavigatorName.sync_screen);
                  },
                  child: Container(
                    height: 48,
                    width: width,
                    decoration: BoxDecoration(
                      color: R.color.mainColor, // Use R.color here
                      borderRadius: BorderRadius.circular(200),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.centerRight,
                        colors: [
                          R.color.greenGradientBottom, // Use R.color here
                          R.color.greenGradientBottom, // Use R.color here
                        ],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        R.string.used_to.tr(), // Use R.string here
                        style: TextStyle(
                          color: R.color.white, // Use R.color here
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
