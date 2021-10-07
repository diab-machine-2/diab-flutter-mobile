import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/user/user_model.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:easy_localization/easy_localization.dart';

typedef AddressItemCallback = Function(ProvinceModel);

class AddressListController extends StatefulWidget {
  final int type;
  final String? id;
  final ProvinceModel? selected;
  final AddressItemCallback? callback;
  AddressListController(
      {required this.type, this.id, this.selected, this.callback});
  @override
  _AddressListControllerState createState() => _AddressListControllerState();
}

class _AddressListControllerState extends State<AddressListController> {
  List<ProvinceModel>? model = [];
  @override
  void initState() {
    super.initState();
    loadData();
  }

  loadData() async {
    BotToast.showLoading();
    if (widget.type == 0) {
      model = await UserClient().fetchProvinces();
    } else if (widget.type == 1) {
      model = await UserClient().fetchDictricts(widget.id ?? '');
    } else if (widget.type == 2) {
      model = await UserClient().fetchWards(widget.id ?? '');
    }
    BotToast.closeAllLoading();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height / 2;
    return Container(
      decoration: BoxDecoration(
          color: R.color.white, borderRadius: BorderRadius.circular(20)),
      padding: EdgeInsets.only(top: 16, bottom: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 16, right: 16, bottom: 8),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(R.string.address.tr(),
                      style: TextStyle(
                          color: R.color.textDark,
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                  GestureDetector(
                      child: Icon(Icons.close, color: R.color.color0xffBEC0C8),
                      onTap: () {
                        Navigator.pop(context);
                      })
                ]),
          ),
          Container(
            height: height,
            width: width,
            child: ListView.builder(
                itemCount: model!.length,
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      widget.callback!(model![index]);
                    },
                    child: Container(
                        padding: EdgeInsets.only(left: 16, right: 16),
                        height: 46,
                        color: widget.selected == null
                            ? R.color.white
                            : widget.selected!.id == model![index].id
                                ? R.color.color0xffDFF6EC
                                : R.color.white,
                        child: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(model![index].name!),
                              widget.selected == null ||
                                      widget.selected!.id != model![index].id
                                  ? SizedBox()
                                  : Image.asset(R.drawable.ic_check,
                                      width: 24, height: 22)
                            ],
                          ),
                        )),
                  );
                }),
          )
        ],
      ),
    );
  }
}
