class AppValidation {
  static bool isValidPassword(String? value) {
    return value != null && value.length >= 6;
  }
}
