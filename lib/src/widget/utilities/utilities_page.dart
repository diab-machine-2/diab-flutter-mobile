import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_sharing.dart';
import 'package:medical/src/app_setting/dynamic_link_config.dart';
import 'package:medical/src/utils/app_log.dart';
import 'package:medical/src/utils/debouncer.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/home/schema/home_schema.dart';

class UtilitiesPage extends StatelessWidget {
  UtilitiesPage({super.key, required this.utilities});

  final List<HomeUtilityData> utilities;
  final _debouncer = Debouncer(milliseconds: 500);

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
            begin: const FractionalOffset(1, 1),
            end: const FractionalOffset(0.9, 0.5),
            stops: const [0.0, 1.0],
          ),
        ),
        child: Column(
          children: [
            CustomAppBar(
              backgroundColor: R.color.transparent,
              title: Text(
                "Tất cả tiện ích",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: R.color.textDark,
                ),
              ),
              leadingIcon: IconButton(
                splashColor: R.color.transparent,
                highlightColor: R.color.transparent,
                icon: Icon(Icons.arrow_back, color: R.color.textDark),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(12.0),
                physics: const ClampingScrollPhysics(),
                itemBuilder: (context, index) {
                  final utility = utilities[index];
                  return Builder(
                    builder: (context) {
                      return InkWell(
                        onTap: () {
                          _debouncer.run(() {
                            final routeName = utility.navigatorName;
                            if (routeName.startsWith("/")) {
                              Navigator.of(context).pushNamed(routeName);
                              return;
                            }
                            // special case for utilities
                            switch (routeName) {
                              case "share":
                                String? shareLink =
                                    DynamicLinkConfig.instance.shareLink;
                                if (shareLink != null) {
                                  AppShare.instance
                                      .userReferralCode(context, shareLink);
                                }
                                return;
                              default:
                                break;
                            }
                            Console.log(
                                "missing handler for routeName: $routeName");
                            BotToast.showText(
                                text: "Chức năng đang được phát triển");
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                utility.icon,
                                width: 30.0,
                                height: 30.0,
                              ),
                              const SizedBox(width: 12.0),
                              Expanded(
                                child: Text(
                                  utility.title,
                                  style: TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF27272A),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12.0),
                              const Icon(
                                Icons.arrow_forward_ios,
                                size: 24.0,
                                color: Color(0xFF666666),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(height: 12.0),
                itemCount: utilities.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
