import 'package:flutter/material.dart';
import 'package:medical/theme/app_theme.dart';
import 'package:medical/widget/helper/show_message.dart';

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
        color: Colors.white,
        shape: CircularNotchedRectangle(),
        notchMargin: 12,
        child: SafeArea(
          child: Container(
            height: 60,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // GestureDetector(
                  //     child: Container(
                  //       color: Colors.transparent,
                  //       padding: EdgeInsets.only(left: 8, right: 8),
                  //       child: Column(
                  //         mainAxisAlignment: MainAxisAlignment.center,
                  //         children: [
                  //           index == 0
                  //               ? Image.asset('assets/images/home.png',
                  //                   width: 26, height: 26)
                  //               : Image.asset('assets/images/home.png',
                  //                   width: 26, height: 26),
                  //           SizedBox(height: 4),
                  //           Text('Trang chủ',
                  //               style: TextStyle(
                  //                   color: index == 0
                  //                       ? mainColor
                  //                       : primaryGreyColor,
                  //                   fontSize: 13,
                  //                   fontWeight: FontWeight.w400))
                  //         ],
                  //       ),
                  //     ),
                  //     onTap: () {
                  //       setState(() {
                  //         index = 0;
                  //         widget.callback(index);
                  //       });
                  //     }),

                  // GestureDetector(
                  //     child: Container(
                  //       color: Colors.transparent,
                  //       padding: EdgeInsets.only(left: 8, right: 8),
                  //       child: Column(
                  //         mainAxisAlignment: MainAxisAlignment.center,
                  //         children: [
                  //           index == 1
                  //               ? Image.asset('assets/images/newspaper.png',
                  //                   width: 26, height: 26)
                  //               : Image.asset('assets/images/newspaper.png',
                  //                   width: 26, height: 26),
                  //           SizedBox(height: 4),
                  //           Text('Khoá học',
                  //               style: TextStyle(
                  //                   color: index == 1
                  //                       ? mainColor
                  //                       : primaryGreyColor,
                  //                   fontSize: 13,
                  //                   fontWeight: FontWeight.w400))
                  //         ],
                  //       ),
                  //     ),
                  //     onTap: () {
                  //       Message.showToastMessage(context,
                  //           'Tính năng này sẽ được ra mắt trong bản nâng cấp tiếp theo');

                  //     })
                ]),
          ),
        ));
    // return BottomNavigationBar(
    //     currentIndex: index,
    //     type: BottomNavigationBarType.fixed,
    //     elevation: 10,
    //     showUnselectedLabels: true,
    //     selectedItemColor: primaryColor,
    //     unselectedItemColor: primaryGreyColor,
    //     selectedFontSize: 12,
    //     unselectedFontSize: 12,
    //     items: [
    //       BottomNavigationBarItem(
    //           icon: Image.asset('assets/images/icon_home.png',
    //               width: 22, height: 24, color: primaryGreyColor),
    //           activeIcon: Image.asset('assets/images/icon_home.png',
    //               width: 22, height: 24, color: primaryColor),
    //           label: 'Tổng quan'),
    //       BottomNavigationBarItem(
    //           icon: Image.asset('assets/images/icon_book.png',
    //               width: 22, height: 22, color: primaryGreyColor),
    //           activeIcon: Image.asset('assets/images/icon_book.png',
    //               width: 22, height: 22, color: primaryColor),
    //           label: 'Khoá học')
    //     ],
    //     onTap: (int index) {
    //       setState(() {
    //         this.index = index;
    //         widget.callback(index);
    //       });
    //     });
  }
}
