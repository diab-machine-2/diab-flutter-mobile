import 'package:easy_localization/easy_localization.dart';
import 'package:medical/res/R.dart';
import 'package:flutter/material.dart';
import 'package:medical/src/app_setting/app_sharing.dart';
import 'package:medical/src/app_setting/dynamic_link_config.dart';
import 'package:medical/src/widgets/button_widget.dart';

class ShareAppDetail extends StatefulWidget {
  const ShareAppDetail({Key? key}) : super(key: key);

  @override
  State<ShareAppDetail> createState() => _ShareAppDetailState();
}

class _ShareAppDetailState extends State<ShareAppDetail> {
  bool isSticky = false;
  bool isScrolled = false;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  _scrollListener() {
    if (_scrollController.position.pixels >= 50) {
      if (!isScrolled) {
        setState(() {
          isScrolled = true;
        });
      }
    } else if (isScrolled) {
      setState(() {
        isScrolled = false;
      });
    }

    if (_scrollController.position.pixels >= 300) {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: _btnShare(context),
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              backgroundColor: Colors.white,
              expandedHeight: 340,
              floating: false,
              pinned: true,
              leading: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: AnimatedContainer(
                      margin: EdgeInsets.only(left: 15),
                      duration: Duration(milliseconds: 300),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            isSticky ? Colors.transparent : Color(0xFF172823),
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        size: isSticky ? 24 : 18,
                        color: isSticky ? R.color.textDark : R.color.white,
                      ),
                    ),
                  ),
                ],
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  children: [
                    Positioned(
                      top: 0,
                      right: 0,
                      bottom: 0,
                      left: 0,
                      child: Image.asset(R.drawable.share_app_detail),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      left: 0,
                      child: Container(
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              R.color.black.withOpacity(0.5),
                              R.color.black.withOpacity(0),
                            ],
                          ),
                        ),
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
                          color: Color(0xFFF5FDFB),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          padding: EdgeInsets.only(
            left: 15,
            right: 15,
            top: isScrolled ? 15 : 0,
            bottom: 15,
          ),
          color: Color(0xFFF5FDFB),
          child: _sectionContent(context),
        ),
      ),
    );
  }

  Widget _sectionContent(BuildContext context) {
    double paddingBottom = MediaQuery.of(context).padding.bottom + 10;
    return ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(0),
      children: [
        Text(
          "Mời bạn và nhận thưởng",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 20),
        Text(
          "Khi chia sẻ app Diab thành công bạn sẽ nhận được Voucher khuyến mãi được áp dụng cho tất cả cửa hàng của Long Châu. Chia sẻ app DiaB giúp bạn bè cải thiện sức khoẻ tốt hơn.",
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        SizedBox(height: 15),
        Text(
          "Phần này anh Việt nhờ team MKT update thêm content giúp em với .... Diab thành công bạn sẽ nhận được Voucher khuyến mãi được áp dụng cho tất cả cửa hàng của Long Châu.",
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        SizedBox(
          height: 55 + paddingBottom,
        )
      ],
    );
  }

  Widget _btnShare(BuildContext context) {
    double paddingBottom = MediaQuery.of(context).padding.bottom + 10;
    return Container(
      padding: EdgeInsets.fromLTRB(15, 15, 15, paddingBottom),
      decoration: BoxDecoration(
        color: R.color.white,
        boxShadow: [
          BoxShadow(
            color: R.color.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 7,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ButtonWidget(
        title: R.string.share_now.tr(),
        onPressed: () {},
      ),
    );
  }

  _onShareApp() {
    String? shareLink = DynamicLinkConfig.instance.shareLink;
    if (shareLink != null) {
      AppShare.instance.userReferralCode(context, shareLink);
    }
  }
}
