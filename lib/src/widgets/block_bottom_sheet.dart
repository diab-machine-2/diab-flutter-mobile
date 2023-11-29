import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/app_media_query.dart';
import 'package:medical/src/widgets/spacing_row.dart';
import 'package:sticky_headers/sticky_headers.dart';

class BlockBottomSheet extends StatelessWidget {
  final String title;
  final String? description;
  final Widget child;
  final Widget? header;
  final Widget? footer;
  final Function? onClose;
  final bool disableCloseButton;
  const BlockBottomSheet({
    Key? key,
    required this.title,
    this.description,
    required this.child,
    this.onClose,
    this.header,
    this.footer,
    this.disableCloseButton = false,
    Function? onSuccess,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    late Widget contentWidget = SingleChildScrollView(
      physics: ClampingScrollPhysics(parent: NeverScrollableScrollPhysics()),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: StickyHeaderBuilder(
          content: SizedBox(
            width: double.infinity,
            child: child,
          ),
          builder: (BuildContext context, double stuckAmount) {
            return Container(
              color: Colors.white,
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.only(
                          top: 20,
                          bottom: 10,
                          left: 15,
                          right: 45,
                        ),
                        width: double.infinity,
                        child: SpacingColumn(
                          spacing: 10,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title,
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w700)),
                            Text(description!,
                                style: TextStyle(
                                    fontSize: 16, color: Color(0xFF75797E))),
                          ],
                        ),
                      ),
                      if (!disableCloseButton)
                        Positioned(
                          right: 5,
                          top: 5,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              if (onClose != null) {
                                onClose!();
                              }
                            },
                            child: Container(
                                alignment: Alignment.center,
                                child: Image.asset(
                                  R.drawable.ic_clear,
                                  width: 45,
                                )),
                          ),
                        ),
                    ],
                  ),
                  header ?? const SizedBox(),
                ],
              ),
            );
          },
        ),
      ),
    );
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 6,
        right: 6,
        bottom: 15,
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Positioned(
              top: 0,
              bottom: 0,
              left: 0,
              right: 0,
              child: InkWell(
                onTap: () => Navigator.pop(context),
                child: Container(color: Colors.transparent),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  color: Colors.white,
                  child: (footer == null)
                      ? contentWidget
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(child: contentWidget),
                            footer ?? const SizedBox(),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
