import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import '../blocs/deleteAccount_bloc.dart';

class PasswordItem extends StatefulWidget {
  const PasswordItem({Key? key}) : super(key: key);

  @override
  State<PasswordItem> createState() => _PasswordItemState();
}

class _PasswordItemState extends State<PasswordItem> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeleteAccountBloc, DeleteAccountState>(
        builder: (context, state) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Nhập mật khẩu hiện tại",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 10),
          TextField(
            // controller: textEditingController,
            minLines: 1,
            maxLines: 1,
            maxLength: 50,
            inputFormatters: [
              // LengthLimitingTextFieldFormatterFixed(50),
            ],
            obscureText: true,
            decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                counterText: '',
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: R.color.grayComponentBorder, width: 1.0),
                  borderRadius: BorderRadius.circular(10),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: R.color.redAccent, width: 1.0),
                  borderRadius: BorderRadius.circular(10),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: R.color.mainColor, width: 1.0),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: R.color.mainColor, width: 1.0),
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding:
                    const EdgeInsets.only(top: 0, left: 16, right: 16),
                hintText: "Nhập mật khẩu hiện tại",
                errorText: state.errorMessage['password']),
            onChanged: (value) {
              context
                  .read<DeleteAccountBloc>()
                  .add(EventChangeValue(password: value));
            },
          )
        ],
      );
    });
  }
}
