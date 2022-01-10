import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/user/user_model.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/profile/address_list.dart';
import 'package:easy_localization/easy_localization.dart';

typedef AddresCallback = Function(
    String address, ProvinceModel? province, ProvinceModel? district, ProvinceModel? ward);

class AddressController extends StatefulWidget {
  final String? address;
  final ProvinceModel? province;
  final ProvinceModel? district;
  final ProvinceModel? ward;
  final AddresCallback? callback;
  AddressController({this.address, this.province, this.district, this.ward, this.callback});
  @override
  _AddressControllerState createState() => _AddressControllerState();
}

class _AddressControllerState extends State<AddressController> {
  TextEditingController _textEditingController = TextEditingController();
  ProvinceModel? selectedProvince;
  ProvinceModel? selectedDistrict;
  ProvinceModel? selectedWard;

  @override
  void initState() {
    super.initState();
    _textEditingController.text = widget.address ?? '';
    selectedProvince = widget.province;
    selectedDistrict = widget.district;
    selectedWard = widget.ward;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(R.string.address.tr(),
              style: TextStyle(color: R.color.textDark, fontSize: 16, fontWeight: FontWeight.w600)),
          GestureDetector(
              child: Icon(Icons.close, color: R.color.color0xffBEC0C8),
              onTap: () {
                Navigator.pop(context);
              })
        ]),
        SizedBox(height: 26),
        Text(R.string.specific_address.tr(),
            style: TextStyle(color: R.color.textDark, fontSize: 16, fontWeight: FontWeight.w600)),
        SizedBox(height: 8),
        Container(
            height: 54,
            width: width - 36,
            child: TextField(
                controller: _textEditingController,
                minLines: 1,
                maxLines: 1,
                obscureText: false,
                decoration: InputDecoration(
                  fillColor: R.color.textDark,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: R.color.grayComponentBorder, width: 1.0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: R.color.mainColor, width: 1.0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: EdgeInsets.only(top: 0, left: 16, right: 16),
                  hintText: R.string.enter_your_address.tr(),
                ),
                onChanged: (value) {})),
        SizedBox(height: 8),
        Text(R.string.province.tr(),
            style: TextStyle(color: R.color.textDark, fontSize: 16, fontWeight: FontWeight.w600)),
        SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                return Container(
                  child: AlertDialog(
                      contentPadding: EdgeInsets.all(0),
                      content: AddressListController(
                        type: 0,
                        selected: selectedProvince,
                        callback: (item) {
                          setState(() {
                            selectedProvince = item;
                          });
                          Navigator.pop(context);
                        },
                      )),
                );
              },
            );
          },
          child: Container(
              height: 48,
              padding: EdgeInsets.only(left: 16, right: 16),
              decoration: BoxDecoration(
                  color: R.color.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(width: 1, color: R.color.grayComponentBorder)),
              child: Center(
                  child: Row(
                children: [
                  Expanded(
                    child: Text(selectedProvince == null ? R.string.choose.tr() : selectedProvince!.name!,
                        style: TextStyle(color: selectedProvince == null ? R.color.captionColorGray : R.color.textDark),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ))),
        ),
        SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (selectedProvince == null) {
                  Message.showToastMessage(context, R.string.mes_province_empty.tr());
                  return;
                }
                showDialog(
                  context: context,
                  builder: (context) {
                    return Container(
                      child: AlertDialog(
                          contentPadding: EdgeInsets.all(0),
                          content: AddressListController(
                            type: 1,
                            id: selectedProvince!.id,
                            selected: selectedDistrict,
                            callback: (item) {
                              setState(() {
                                selectedDistrict = item;
                              });
                              Navigator.pop(context);
                            },
                          )),
                    );
                  },
                );
              },
              child: Container(
                color: R.color.transparent,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(R.string.district.tr(),
                      style: TextStyle(color: R.color.textDark, fontSize: 16, fontWeight: FontWeight.w600)),
                  SizedBox(height: 8),
                  Container(
                      height: 48,
                      //width: 200,
                      padding: EdgeInsets.only(left: 16, right: 16),
                      decoration: BoxDecoration(
                          color: R.color.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(width: 1, color: R.color.grayComponentBorder)),
                      child: Center(
                          child: Row(
                        children: [
                          Expanded(
                            child: Text(selectedDistrict == null ? R.string.choose.tr() : selectedDistrict!.name!,
                                style: TextStyle(
                                    color: selectedDistrict == null ? R.color.captionColorGray : R.color.textDark),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      )))
                ]),
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (selectedProvince == null) {
                  Message.showToastMessage(context, R.string.mes_province_empty.tr());
                  return;
                }
                if (selectedDistrict == null) {
                  Message.showToastMessage(context, R.string.mes_district_empty.tr());
                  return;
                }
                showDialog(
                  context: context,
                  builder: (context) {
                    return Container(
                      child: AlertDialog(
                          contentPadding: EdgeInsets.all(0),
                          content: AddressListController(
                            type: 2,
                            id: selectedDistrict!.id,
                            selected: selectedWard,
                            callback: (item) {
                              setState(() {
                                selectedWard = item;
                              });
                              Navigator.pop(context);
                            },
                          )),
                    );
                  },
                );
              },
              child: Container(
                color: R.color.transparent,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(R.string.wards.tr(),
                      style: TextStyle(color: R.color.textDark, fontSize: 16, fontWeight: FontWeight.w600)),
                  SizedBox(height: 8),
                  Container(
                      height: 48,
                      //width: 200,
                      padding: EdgeInsets.only(left: 16, right: 16),
                      decoration: BoxDecoration(
                          color: R.color.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(width: 1, color: R.color.grayComponentBorder)),
                      child: Center(
                          child: Row(
                        children: [
                          Expanded(
                            child: Text(selectedWard == null ? R.string.choose.tr() : selectedWard!.name!,
                                style: TextStyle(
                                    color: selectedWard == null ? R.color.captionColorGray : R.color.textDark),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      )))
                ]),
              ),
            ),
          )
        ]),
        Container(
          margin: EdgeInsets.only(top: 16),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(
              flex: 1,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                    height: 48,
                    width: 119,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(200), color: R.color.grayBorder),
                    child: Center(
                      child: Text(R.string.cancel.tr(),
                          style: TextStyle(color: R.color.textDark, fontSize: 16, fontWeight: FontWeight.w600)),
                    )),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              flex: 1,
              child: GestureDetector(
                onTap: () {
                  final address = _textEditingController.text;
                  if (address.isEmpty) {
                    Message.showToastMessage(context, R.string.mes_address_empty.tr());
                    return;
                  }
                  if (selectedProvince == null) {
                    Message.showToastMessage(context, R.string.mes_province_empty.tr());
                    return;
                  }
                  if (selectedDistrict == null) {
                    Message.showToastMessage(context, R.string.mes_district_empty.tr());
                    return;
                  }
                  if (selectedWard == null) {
                    Message.showToastMessage(context, R.string.mes_wards_empty.tr());
                    return;
                  }

                  widget.callback!(address, selectedProvince, selectedDistrict, selectedWard);
                  Navigator.pop(context);
                },
                child: Container(
                  height: 48,
                  width: 119,
                  decoration: BoxDecoration(
                      color: R.color.red,
                      borderRadius: BorderRadius.circular(200),
                      gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.centerRight,
                          colors: [R.color.greenGradientTop, R.color.greenGradientBottom])),
                  child: Center(
                    child: Text(R.string.save.tr(),
                        style: TextStyle(color: R.color.white, fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
            ),
          ]),
        ),
      ],
    );
  }
}
