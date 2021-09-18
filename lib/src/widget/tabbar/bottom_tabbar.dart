import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';

typedef TabbarSelected = Function(int);

class BottomTabbar extends StatefulWidget {
  final TabbarSelected callback;
  BottomTabbar({@required this.callback});

  final _BottomTabbar state = _BottomTabbar();

  @override
  _BottomTabbar createState() => state;
}

class _BottomTabbar extends State<BottomTabbar> {
  int index = 0;
  int ticketCount;

  @override
  void initState() {
    super.initState();
  }

  jumpToIndex(int index) {
    setState(() {
      this.index = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
        color: R.color.white,
        shape: CircularNotchedRectangle(),
        notchMargin: 12,
        child: SafeArea(
          child: Container(
            height: 60,
          ),
        ));
  }
}
