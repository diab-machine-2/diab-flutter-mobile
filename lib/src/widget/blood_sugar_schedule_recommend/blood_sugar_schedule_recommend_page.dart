import 'package:easy_localization/easy_localization.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';

class BloodSugarScheduleRecommand extends StatelessWidget {
  const BloodSugarScheduleRecommand();

  @override
  Widget build(BuildContext context) {
    const int number_of_models = 6;
    return Scaffold(
      backgroundColor: R.color.color0xffF4DBBD,
      body: Stack(
        alignment: AlignmentDirectional.topEnd,
        children: [
          SafeArea(
            bottom: false,
            child: Image.asset(R.drawable.im_schedule_glucose, height: 220),
          ),
          Column(
            children: [
              CustomAppBar(
                backgroundColor: Colors.transparent,
                title: Text(R.string.result.tr(),
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: R.color.textDark)),
                leadingIcon: IconButton(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    icon: Icon(Icons.arrow_back, color: R.color.textDark),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
              ),
              Expanded(
                child: Container(
                  color: R.color.white,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 24),
                      child: Column(
                        children: [
                          ExpandableText(
                            'message',
                            expandText: 'show more',
                            maxLines: 2,
                            linkColor: Colors.blue,
                            animation: true,
                            collapseOnTextTap: true,
                            prefixText: 'username',
                            onPrefixTap: () => {},
                            prefixStyle:
                                const TextStyle(fontWeight: FontWeight.bold),
                            onHashtagTap: (name) => {},
                            hashtagStyle: const TextStyle(
                              color: Color(0xFF30B6F9),
                            ),
                            onMentionTap: (username) => {},
                            mentionStyle: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                            onUrlTap: (url) => {},
                            urlStyle: const TextStyle(
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          ExpandableText(
                            'sdfhkashdfksajhdfksdhgjkdshgjkdfbvvhjasbldsjhfbsahjbfiweufbuwehfIAFHJKSAhfkdsjhfdsfhuerhfuihaiHFIUSGDSBpbgidsbgfuwgbvci',
                            expandText: 'show more',
                            collapseText: 'show less',
                            maxLines: 1,
                            linkColor: Colors.blue,
                          ),
                          Text(R.string.pick_a_model
                              .tr(args: ['$number_of_models'])),
                          Container(
                            color: Colors.blue,
                            height: 100,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
