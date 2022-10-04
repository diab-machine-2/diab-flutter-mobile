import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widgets/network_image_widget.dart';
import '../../../data/models/voucherList_response.dart';
import '../blocs/voucherList_bloc.dart';

class VoucherListItem extends StatelessWidget {
  final VoucherModel voucherData;
  const VoucherListItem({
    Key? key,
    required this.voucherData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isUsed = voucherData.status == 1;
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          NavigatorName.voucher_detail,
          arguments: {
            "voucherId": voucherData.id,
            "updateVoucherList": () {
              BlocProvider.of<VoucherListBloc>(context)
                  .add(EventGetVoucherList(isReload: true));
            }
          },
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 15, right: 1, left: 1),
        constraints: BoxConstraints(
          maxHeight: isUsed ? 120 : 95,
        ),
        decoration: BoxDecoration(
          color: R.color.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: R.color.accentColor.withOpacity(0.1),
              offset: Offset(0, 1),
              blurRadius: 3,
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              flex: 100,
              child: Opacity(
                opacity: isUsed ? 0.5 : 1,
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: voucherData.logo != null
                      ? NetWorkImageWidget(
                          imageUrl: voucherData.logo,
                          width: 50,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          R.drawable.ic_crown_green,
                          width: 40,
                          height: 40,
                          fit: BoxFit.contain,
                        ),
                ),
              ),
            ),
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 14,
                  child: LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                      final boxHeight = constraints.constrainHeight();
                      const dashWidth = 1.0;
                      final dashHeight = 3.0;
                      final dashCount = (boxHeight / (2 * dashHeight)).floor();
                      return Flex(
                        children: List.generate(dashCount, (_) {
                          return SizedBox(
                            height: dashHeight,
                            width: dashWidth,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    R.color.color0xffE0E1E1,
                                    R.color.transparent,
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        direction: Axis.vertical,
                      );
                    },
                  ),
                ),
                Positioned(
                  top: -7,
                  left: 0,
                  right: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: R.color.color0xfff5f5f5,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -7,
                  left: 0,
                  right: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: R.color.color0xfff5f5f5,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              flex: 250,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 15,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    if (isUsed)
                      Text(
                        "Mã ưu đãi: ${voucherData.code.toUpperCase()}",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: R.color.orange,
                        ),
                      ),
                    Text(
                      voucherData.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    if (!isUsed)
                      Text(
                        "Xem chi tiết",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: R.color.greenGradientBottom,
                        ),
                      ),
                    if (isUsed)
                      Row(
                        children: [
                          Text(
                            "Đã sử dụng",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: R.color.green,
                            ),
                          ),
                          SizedBox(width: 5),
                          Icon(
                            Icons.check_circle,
                            size: 14,
                            color: R.color.green,
                          )
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
