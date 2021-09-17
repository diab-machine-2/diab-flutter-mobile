
import 'package:medical/res/R.dart';

import 'const.dart';
import 'utils.dart';

class Validators {
  static final RegExp _phoneRegex = RegExp(r'(\+84|0)\d{9}$');
  static final RegExp _emailRegex = RegExp(
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');

  String checkPhoneNumber(String phoneNumber) {
    if (Utils.isEmpty(phoneNumber)) {
      return R.string.please_input_phone_number;
    } else if (!_phoneRegex.hasMatch(phoneNumber)) {
      return R.string.phone_not_valid;
    } else {
      return null;
    }
  }

  String checkPhoneNumber2(String phoneNumber) {
    if (Utils.isEmpty(phoneNumber)) return null;
    if (!_phoneRegex.hasMatch(phoneNumber)) {
      return R.string.phone_not_valid;
    } else {
      return null;
    }
  }

  String checkEmail(String email) {
    if (Utils.isEmpty(email)) {
      return R.string.please_input_email;
    } else if (!_emailRegex.hasMatch(email)) {
      return R.string.email_not_valid;
    } else {
      return null;
    }
  }

  String checkEmail2(String email) {
    if (Utils.isEmpty(email)) return null;
    if (!_emailRegex.hasMatch(email)) {
      return R.string.email_not_valid;
    } else {
      return null;
    }
  }

  String checkPass(String password) {
    if (Utils.isEmpty(password)) {
      return R.string.please_enter_password;
    } else if (password.length < 4) {
      return R.string.password_least_character;
    } else {
      return null;
    }
  }

//
//   String checkCurrentPass(BuildContext context, String password) {
//     if (Utils.isEmpty(password)) {
//       return R.string.please_enter_curr_password;
//     } else if (password.length < 4) {
//       return R.string.password_least_character;
//     } else {
//       return null;
//     }
//   }
//
//   String checkNewPass(
//       BuildContext context, String oldPassword, String newPassword) {
//     if (Utils.isEmpty(newPassword)) {
//       return R.string.please_enter_new_password;
//     } else if (newPassword.length < 4) {
//       return R.string.password_least_character;
//     } else if (newPassword == oldPassword) {
//       return R.string.cannot_same_current_password;
//     } else {
//       return null;
//     }
//   }
//
//   String checkConfirmPass(
//       BuildContext context, String password, String rePassword) {
//     if (Utils.isEmpty(rePassword)) {
//       return R.string.please_input_re_password;
//     } else if (rePassword.length < 4) {
//       return R.string.password_least_character;
//     } else if (password != rePassword) {
//       return R.string.password_not_match;
//     } else {
//       return null;
//     }
//   }
//
  String checkRePass(String password, String rePassword) {
    if (Utils.isEmpty(rePassword)) {
      return R.string.please_input_re_password;
    } else if (rePassword.length < 4) {
      return R.string.password_least_character;
    } else if (password != rePassword) {
      return R.string.password_not_match;
    } else {
      return null;
    }
  }

//
//   String checkRePass2(BuildContext context, String password) {
//     if (Utilss.isEmpty(password)) {
//       return R.string.please_input_re_password;
//     } else if (password.length < 4) {
//       return R.string.password_least_character;
//     } else {
//       return null;
//     }
//   }
//
  String checkName(String name) {
    if (Utils.isEmpty(name)) return R.string.please_input_username;
//    else if (name.length < 5)
//      return R.string.name_least_character;
//    else if (name.length > 50) return R.string.name_too_many_characters;
    return null;
  }

  int checkTypeId(String id) {
    if (Utils.isEmpty(id)) return null;
    if (_phoneRegex.hasMatch(id)) return Const.TYPE_PHONE;
    if (_emailRegex.hasMatch(id)) return Const.TYPE_EMAIL;
    return null;
  }
}
