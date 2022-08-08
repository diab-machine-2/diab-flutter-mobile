import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/modal/user/user_model.dart';
import 'package:medical/src/repo/login/login_client.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:medical/src/utils/app_validation.dart';
import 'package:medical/src/utils/const.dart';
import 'package:meta/meta.dart';
part 'deleteAccount_bloc_state.dart';
part 'deleteAccount_bloc_event.dart';

class DeleteAccountBloc extends Bloc<DeleteAccountEvent, DeleteAccountState> {
  DeleteAccountBloc() : super(DeleteAccountState());

  @override
  Stream<DeleteAccountState> mapEventToState(DeleteAccountEvent event) async* {
    if (event is EventChangeValue) {
      yield* eventChangeValue(event);
    } else if (event is EventSubmitDeleteAccount) {
      yield* eventSubmitDeleteAccount(event);
    } else if (event is EventSubmitValidatePassword) {
      yield* eventSubmitValidatePassword(event);
    }
  }

  Stream<DeleteAccountState> eventChangeValue(EventChangeValue event) async* {
    String? password = event.password;
    String? deleteReason = event.deleteReason;
    Map<String, String?>? errorMessage;
    if (password != null) {
      errorMessage = await checkValidData(password: password);
    }
    if (deleteReason != null) {
      errorMessage = await checkValidData(deleteReason: deleteReason);
    }

    yield state.copyWith(
      password: password,
      deleteReason: event.deleteReason,
      errorMessage: errorMessage,
    );
  }

  Future<Map<String, String?>> checkValidData({
    String? password,
    String? deleteReason,
  }) async {
    Map<String, String?> errorMessage = {}..addAll(state.errorMessage);
    if (password != null) {
      bool isValidPassword = AppValidation.isValidPassword(password);
      errorMessage['password'] =
          isValidPassword ? null : R.string.password_least_character.tr();
    }
    if (deleteReason != null) {
      errorMessage['deleteReason'] =
          deleteReason == '' ? "Vui lòng chọn lý do xoá tài khoản." : null;
    }
    return errorMessage;
  }

  bool isValidData(Map<String, String?> errorMessage) {
    bool hasError = true;
    errorMessage.forEach((key, value) {
      if (value != null) {
        hasError = false;
        return;
      }
    });
    return hasError;
  }

  Stream<DeleteAccountState> eventSubmitValidatePassword(
      EventSubmitValidatePassword event) async* {
    UserModel? userInfo = AppSettings.userInfo;
    Map<String, String?> errorMessage = await checkValidData(
        password: state.password, deleteReason: state.deleteReason);

    if (isValidData(errorMessage)) {
      try {
        await LoginClient().login({
          "client_id": Const.CLIENT_ID,
          "client_secret": Const.CLIENT_SECRET,
          "grant_type": "phone_number_password",
          "password": state.password,
          "phone_number": userInfo?.phoneNumber
        });
        yield state.copyWith(
          blocStatus: BlocStatus.verifyPasswordSuccess,
        );
      } catch (e) {
        yield state.copyWith(blocStatus: BlocStatus.error, errorMessage: {
          "password": R.string.mat_khau_khong_chinh_xac.tr(),
        });
      }
    } else {
      yield state.copyWith(
        errorMessage: errorMessage,
        blocStatus: BlocStatus.error,
      );
    }
  }

  Stream<DeleteAccountState> eventSubmitDeleteAccount(
      EventSubmitDeleteAccount event) async* {
    try {
      await UserClient().deleteUser();
      yield state.copyWith(
        blocStatus: BlocStatus.deleteAccountSuccess,
      );
    } catch (e) {
      yield state.copyWith(
        blocStatus: BlocStatus.error,
      );
    }
  }
}
