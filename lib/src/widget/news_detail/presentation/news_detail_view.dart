import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';

class NewsDetailView extends StatefulWidget {
  const NewsDetailView({Key? key}) : super(key: key);

  @override
  State<NewsDetailView> createState() => _NewsDetailViewState();
}

class _NewsDetailViewState extends State<NewsDetailView> {
  bool isSticky = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NotificationListener(
        onNotification: (ScrollNotification notification) {
          if (notification.metrics.pixels >= 300) {
            if (!isSticky) {
              setState(() {
                isSticky = true;
              });
            }
          } else if (isSticky) {
            setState(() {
              isSticky = false;
            });
          }
          return false;
        },
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                backgroundColor: Colors.white,
                expandedHeight: 340,
                floating: false,
                pinned: true,
                leading: Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        margin: EdgeInsets.only(left: 15),
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF172823),
                        ),
                        child: Icon(
                          Icons.arrow_back,
                          size: 18,
                          color: R.color.white,
                        ),
                      ),
                    ),
                  ],
                ),
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: AnimatedOpacity(
                    opacity: isSticky ? 1 :0,
                    duration: Duration(milliseconds: 300),
                    child: Text(
                      "Tin tức",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  background: Stack(
                    children: [
                      Positioned(
                        top: 0,
                        right: 0,
                        bottom: 0,
                        left: 0,
                        child: Image.network(
                          "https://via.placeholder.com/375x340",
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        left: 0,
                        child: Container(
                          height: 25,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                            color: R.color.greenbg,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: Container(
            padding: EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  R.color.greenbg.withOpacity(0.3),
                  R.color.greenbg.withOpacity(0.9),
                ],
                begin: const FractionalOffset(1, 1),
                end: const FractionalOffset(0.9, 0.5),
                stops: const [0.0, 1.0],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  children: [
                    _itemHastag(),
                    _itemHastag(),
                  ],
                ),
                SizedBox(height: 15),
                Text(
                  "Những đối tượng cần sàng lọc bệnh Đái tháo đường típ 2 sớm",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Ngày 21/01/2022",
                  style: TextStyle(
                    fontSize: 12,
                    color: R.color.grey_2,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Đái tháo đường (tiểu đường) típ 2 là căn bệnh nguy hiểm với mức độ tử vong cao cần phải sàng lọc sớm, nhất là những đối tượng nằm trong nhóm nguy cơ cao sau",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _itemHastag() {
    return Container(
      margin: EdgeInsets.only(right: 10),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: R.color.buttonRoundColor,
      ),
      child: Text(
        "Sức khoẻ",
        style: TextStyle(
          fontSize: 14,
          color: R.color.mainColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
