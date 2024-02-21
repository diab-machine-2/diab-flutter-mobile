import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/user/motivation_model.dart';
import 'package:medical/src/utils/length_limit_text_field.dart';

class MotivationPopup extends StatefulWidget {
  final MotivationModel? model;
  final Function(MotivationModel model)? callback;
  const MotivationPopup({this.model, this.callback});
  @override
  _MotivationPopupState createState() => _MotivationPopupState();
}

class _MotivationPopupState extends State<MotivationPopup> {
  TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    textEditingController.text = widget.model == null ? '' : widget.model!.content!;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.model == null ? R.string.new_motivation.tr() : R.string.edit_motivation.tr(),
                style: TextStyle(color: R.color.textDark, fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(R.string.letters_left_count.tr(args: ['${100 - textEditingController.text.length}']),
                style: TextStyle(color: R.color.primaryGreyColor, fontSize: 16, fontWeight: FontWeight.w400))
          ]),
          GestureDetector(
              child: Icon(Icons.close, color: R.color.color0xffBEC0C8),
              onTap: () {
                Navigator.pop(context);
              })
        ]),
        const SizedBox(height: 16),
        Container(
            width: MediaQuery.of(context).size.width - 36,
            child: TextField(
                controller: textEditingController,
                minLines: 3,
                maxLines: 3,
                maxLength: 100,
                inputFormatters: [
                  LengthLimitingTextFieldFormatterFixed(100),
                ],
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
                    hintText: R.string.add_new_motivation.tr(),
                    counterText: '',
                    contentPadding: const EdgeInsets.all(16)),
                onChanged: (value) {
                  setState(() {});
                })),
        Container(
          margin: const EdgeInsets.only(top: 16),
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
                  FocusScope.of(context).unfocus();
                  final content = textEditingController.text;
             //     if (content.isEmpty) {
             //       Message.showToastMessage(context, R.string.mes_motivation_content_empty.tr());
             //       return;
             //     } else {
                    widget.callback!(widget.model == null
                        ? MotivationModel(content: content, id: null, createDateTime: null)
                        : MotivationModel(
                            content: content, id: widget.model!.id, createDateTime: widget.model!.createDateTime));
                    Navigator.pop(context);
             //     }
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
