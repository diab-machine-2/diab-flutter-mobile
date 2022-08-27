import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';

class NewsDetailView extends StatelessWidget {
  const NewsDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  backgroundColor: Colors.transparent,
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
                    background: Image.network(
                      "https://via.placeholder.com/375x340",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ];
            },
            body: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Container(
                decoration: BoxDecoration(
                  // color: Colors.transparent,
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
                  children: [
                    Row(
                      children: [
                        _itemHastag(),
                        _itemHastag(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
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
