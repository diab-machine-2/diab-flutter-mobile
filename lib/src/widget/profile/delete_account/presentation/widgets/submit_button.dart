import 'package:medical/res/R.dart';
import 'package:flutter/material.dart';
import '../blocs/deleteAccount_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SubmitButton extends StatelessWidget {
  const SubmitButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 18,
      left: 15,
      right: 15,
      child: BlocBuilder<DeleteAccountBloc, DeleteAccountState>(
          builder: (context, state) {
        return InkWell(
          onTap: () {
            context
                .read<DeleteAccountBloc>()
                .add(EventSubmitValidatePassword());
          },
          child: Container(
            height: 48,
            width: 195,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.centerRight,
                colors: [R.color.greenGradientTop, R.color.greenGradientBottom],
              ),
              borderRadius: BorderRadius.circular(200),
            ),
            child: Center(
              child: Text(
                "Xác nhận xoá",
                style: TextStyle(
                  color: R.color.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
