import 'package:flutter/material.dart';
import 'package:medical/modal/user/user_model.dart';
import 'package:medical/theme/app_theme.dart';
import 'package:medical/widget/helper/show_message.dart';
import 'package:medical/widget/profile/address_list.dart';

typedef AddresCallback = Function(String address, ProvinceModel province,
    ProvinceModel district, ProvinceModel ward);

class AddressController extends StatefulWidget {
  final String address;
  final ProvinceModel province;
  final ProvinceModel district;
  final ProvinceModel ward;
  final AddresCallback callback;
  AddressController(
      {this.address, this.province, this.district, this.ward, this.callback});
  @override
  _AddressControllerState createState() => _AddressControllerState();
}

class _AddressControllerState extends State<AddressController> {
  TextEditingController _textEditingController = TextEditingController();
  ProvinceModel selectedProvince;
  ProvinceModel selectedDistrict;
  ProvinceModel selectedWard;

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
          Text('Địa chỉ',
              style: TextStyle(
                  color: textDark, fontSize: 16, fontWeight: FontWeight.w600)),
          GestureDetector(
              child: Icon(Icons.close, color: Color(0xffBEC0C8)),
              onTap: () {
                Navigator.pop(context);
              })
        ]),
        SizedBox(height: 26),
        Text('Địa chỉ cụ thể',
            style: TextStyle(
                color: textDark, fontSize: 16, fontWeight: FontWeight.w600)),
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
                  fillColor: textDark,
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Color(0xffDDDDDD), width: 1.0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: mainColor, width: 1.0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: EdgeInsets.only(top: 0, left: 16, right: 16),
                  hintText: 'Nhập địa chỉ của bạn',
                ),
                onChanged: (value) {})),
        SizedBox(height: 8),
        Text('Tỉnh thành',
            style: TextStyle(
                color: textDark, fontSize: 16, fontWeight: FontWeight.w600)),
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
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(width: 1, color: Color(0xffDDDDDD))),
              child: Center(
                  child: Row(
                children: [
                  Expanded(
                    child: Text(
                        selectedProvince == null
                            ? 'Chọn'
                            : selectedProvince.name,
                        style: TextStyle(
                            color: selectedProvince == null
                                ? Color(0xff9C9C9C)
                                : textDark),
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
                  Message.showToastMessage(context, 'Bạn chưa chọn tỉnh thành');
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
                            id: selectedProvince.id,
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
                color: Colors.transparent,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Quận/Huyện',
                          style: TextStyle(
                              color: textDark,
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                      SizedBox(height: 8),
                      Container(
                          height: 48,
                          //width: 200,
                          padding: EdgeInsets.only(left: 16, right: 16),
                          decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  width: 1, color: Color(0xffDDDDDD))),
                          child: Center(
                              child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                    selectedDistrict == null
                                        ? 'Chọn'
                                        : selectedDistrict.name,
                                    style: TextStyle(
                                        color: selectedDistrict == null
                                            ? Color(0xff9C9C9C)
                                            : textDark),
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
                  Message.showToastMessage(context, 'Bạn chưa chọn tỉnh thành');
                  return;
                }
                if (selectedDistrict == null) {
                  Message.showToastMessage(context, 'Bạn chưa chọn quận/huyện');
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
                            id: selectedDistrict.id,
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
                color: Colors.transparent,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Phường/Xã',
                          style: TextStyle(
                              color: textDark,
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                      SizedBox(height: 8),
                      Container(
                          height: 48,
                          //width: 200,
                          padding: EdgeInsets.only(left: 16, right: 16),
                          decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  width: 1, color: Color(0xffDDDDDD))),
                          child: Center(
                              child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                    selectedWard == null
                                        ? 'Chọn'
                                        : selectedWard.name,
                                    style: TextStyle(
                                        color: selectedWard == null
                                            ? Color(0xff9C9C9C)
                                            : textDark),
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
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                  height: 48,
                  width: 119,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(200),
                      color: grayBorder),
                  child: Center(
                    child: Text('Huỷ',
                        style: TextStyle(
                            color: textDark,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                  )),
            ),
            GestureDetector(
              onTap: () {
                final addess = _textEditingController.text ?? '';
                if (addess.isEmpty) {
                  Message.showToastMessage(context, 'Bạn chưa nhập địa chỉ');
                  return;
                }
                if (selectedProvince == null) {
                  Message.showToastMessage(context, 'Bạn chưa chọn tỉnh thành');
                  return;
                }
                if (selectedDistrict == null) {
                  Message.showToastMessage(context, 'Bạn chưa chọn quận/huyện');
                  return;
                }
                if (selectedWard == null) {
                  Message.showToastMessage(context, 'Bạn chưa chọn phuờng/xã');
                  return;
                }

                widget.callback(
                    addess, selectedProvince, selectedDistrict, selectedWard);
                Navigator.pop(context);
              },
              child: Container(
                height: 48,
                width: 119,
                decoration: BoxDecoration(
                    color: red,
                    borderRadius: BorderRadius.circular(200),
                    gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.centerRight,
                        colors: [greenGradientTop, greenGradientBottom])),
                child: Center(
                  child: Text('Lưu',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ]),
        ),
      ],
    );
  }
}
