import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/widget/base/customDropdown.dart';
import 'package:medical/src/widget/base/text_field_custom.dart';

import '../blocs/deleteAccount_bloc.dart';
import '../widgets/widgets.dart';
import 'package:medical/res/R.dart';
import 'package:flutter/material.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';

class DeleteAccountController extends StatefulWidget {
  const DeleteAccountController({Key? key}) : super(key: key);

  @override
  State<DeleteAccountController> createState() =>
      _DeleteAccountControllerState();
}

class _DeleteAccountControllerState extends State<DeleteAccountController> {
  final GlobalKey<TextFieldCustomState> passwordKey = GlobalKey();
  String password = '';
  bool isCorrectPassword = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DeleteAccountBloc>(
      create: (_) => DeleteAccountBloc(),
      child: BlocListener<DeleteAccountBloc, DeleteAccountState>(
        listener: (context, state) {
          if (state.blocStatus == BlocStatus.deleteAccountSuccess) {
            AppSettings.logout();
          } else if (state.blocStatus == BlocStatus.verifyPasswordSuccess) {
            ConfirmDialog.showDialogDeleteAccount(
              context,
              onSubmit: () => context
                  .read<DeleteAccountBloc>()
                  .add(EventSubmitDeleteAccount()),
            );
          }
        },
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Scaffold(
            body: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [
                        R.color.greenbg.withOpacity(0.3),
                        R.color.greenbg.withOpacity(0.9),
                      ],
                      begin: const FractionalOffset(1, 1),
                      end: const FractionalOffset(0.9, 0.5),
                      stops: const [0.0, 1.0])),
              child: Stack(
                children: [
                  Column(
                    children: [
                      CustomAppBar(
                        backgroundColor: R.color.transparent,
                        title: Text('Yêu cầu xoá tài khoản',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: R.color.textDark)),
                        leadingIcon: IconButton(
                            splashColor: R.color.transparent,
                            highlightColor: R.color.transparent,
                            icon:
                                Icon(Icons.arrow_back, color: R.color.textDark),
                            onPressed: () {
                              Navigator.pop(context);
                            }),
                      ),
                      SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            PasswordItem(),
                            SizedBox(height: 25),
                            DeleteReasonItem(),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SubmitButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
