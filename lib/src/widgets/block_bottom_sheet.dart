import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:sticky_headers/sticky_headers.dart';

class BlockBottomSheet extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? header;
  final Widget? footer;
  final Function? onClose;
  final bool disableCloseButton;
  const BlockBottomSheet({
    Key? key,
    required this.title,
    required this.child,
    this.onClose,
    this.header,
    this.footer,
    this.disableCloseButton = false,
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
                        child: Text(title,
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w700)),
                      ),
                      if (!disableCloseButton)
                        Positioned(
                          right: 15,
                          bottom: 0,
                          top: 10,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              if (onClose != null) {
                                onClose!();
                              }
                            },
                            child: Container(
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.close,
                                color: R.color.gray,
                              ),
                            ),
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
