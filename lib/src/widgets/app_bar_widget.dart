import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final Function? onBack;
  final String title;
  final bool hasBackIcon;
  final Widget rightAction;
  final double elevation;
  final bool? centerTitle;

  const AppBarWidget({
    Key? key,
    this.onBack,
    this.elevation = 4,
    required this.title,
    this.rightAction = const SizedBox(),
    this.hasBackIcon = true,
    this.centerTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: elevation,
      shadowColor: Colors.black.withOpacity(0.2),
      centerTitle: centerTitle,
      title: Stack(
        children: <Widget>[
          if (hasBackIcon)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: InkWell(
                onTap: () {
                  if (onBack != null) {
                    onBack!();
                  } else {
                    Navigator.pop(context);
                  }
                },
                child: Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.arrow_back,
                    color: R.color.textDark,
                  ),
                ),
              ),
            ),
          centerTitle == true
              ? Center(
                  child: AutoSizeText(
                    title,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 18,
                      color: R.color.textDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              : Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 18,
                      color: R.color.textDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
          Positioned(right: 5, top: 0, bottom: 0, child: rightAction),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(50);
}
