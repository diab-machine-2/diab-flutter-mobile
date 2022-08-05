import 'package:medical/res/R.dart';
import 'package:flutter/material.dart';
import '../blocs/deleteAccount_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/widget/profile/delete_account/presentation/widgets/widgets.dart';

class DeleteReasonItem extends StatefulWidget {
  const DeleteReasonItem({Key? key}) : super(key: key);

  @override
  State<DeleteReasonItem> createState() => _DeleteReasonItemState();
}

class _DeleteReasonItemState extends State<DeleteReasonItem> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeleteAccountBloc, DeleteAccountState>(
        builder: (context, state) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Lý do xoá",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 10),
          TextField(
            onTap: () {
              ReasonDeletePicker.showModelSheet(
                context,
                valueSelected: state.deleteReason,
                onSubmit: (value) => context
                    .read<DeleteAccountBloc>()
                    .add(EventChangeValue(deleteReason: value)),
              );
            },
            readOnly: true,
            controller: TextEditingController(text: state.deleteReason),
            decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              counterText: '',
              enabledBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: R.color.grayComponentBorder, width: 1.0),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: R.color.grayComponentBorder, width: 1.0),
                borderRadius: BorderRadius.circular(10),
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: R.color.mainColor, width: 1.0),
                borderRadius: BorderRadius.circular(10),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: R.color.redAccent, width: 1.0),
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding:
                  const EdgeInsets.only(top: 0, left: 16, right: 16),
              hintText: "Chọn lý do xoá của bạn",
              errorText: state.errorMessage["deleteReason"],
              suffixIcon: Icon(
                Icons.keyboard_arrow_down,
                color: R.color.grayCaption,
              ),
            ),
          )
        ],
      );
    });
  }
}
