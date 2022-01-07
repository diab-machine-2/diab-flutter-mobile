import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/user/category_item_user_model.dart';
import 'package:medical/src/repo/user/user_client.dart';

class DiabetesStatusPicker extends StatefulWidget {
  final int? state;
  final Function(int)? onChanged;
  final List<CategoryItemUserModel> levelOfDiabetesList;
  const DiabetesStatusPicker({this.levelOfDiabetesList = const [], this.state, this.onChanged});

  @override
  _DiabetesStatusPickerState createState() => _DiabetesStatusPickerState();
}

class _DiabetesStatusPickerState extends State<DiabetesStatusPicker> {
  FixedExtentScrollController? scrollController;
  int selectedItem = 0;

  List<CategoryItemUserModel>? diabeteStates = [];

  @override
  void initState() {
    super.initState();
    scrollController = FixedExtentScrollController(initialItem: widget.state == null ? 0 : (widget.state! - 1));
    selectedItem = widget.state == null ? 0 : (widget.state! - 1);

    diabeteStates = widget.levelOfDiabetesList;
    if (widget.state == null) {
      widget.onChanged!(0);
      selectedItem = 0;
    }
    //  loadData();
  }

  // loadData() async {
  //   BotToast.showLoading();
  //   diabeteStates = await UserClient().fetchDiabeteStates();
  //   if (widget.state == null) {
  //     widget.onChanged!(diabeteStates![0]);
  //     selectedItem = 0;
  //   }

  //   BotToast.closeAllLoading();
  //   setState(() {});
  // }

  @override
  Widget build(BuildContext context) {
    return diabeteStates!.isEmpty
        ? const SizedBox()
        : CupertinoPicker(
            scrollController: scrollController,
            selectionOverlay: null,
            onSelectedItemChanged: (value) {
              widget.onChanged!(value);
              setState(() {
                selectedItem = value;
              });
            },
            itemExtent: 47.0,
            children: List<int>.generate(diabeteStates!.length, (i) => i)
                .map((e) => Center(
                      child: Text(diabeteStates![e].text ?? '',
                          style: TextStyle(
                              color: selectedItem == e ? R.color.mainColor : R.color.color0xffC0C2C5,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                    ))
                .toList());
  }
}
