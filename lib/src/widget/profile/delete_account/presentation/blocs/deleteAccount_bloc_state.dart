part of 'deleteAccount_bloc.dart';

class DeleteAccountState {
  final BlocStatus blocStatus;
  final String password;
  final String? deleteReason;
  final Map<String, String?> errorMessage;

  DeleteAccountState({
    this.blocStatus = BlocStatus.initial,
    this.password = '',
    this.deleteReason = '',
    this.errorMessage = const {},
  });

  DeleteAccountState copyWith({
    String? password,
    String? deleteReason,
    BlocStatus? blocStatus,
    Map<String, String?>? errorMessage,
  }) {
    return DeleteAccountState(
      password: password ?? this.password,
      blocStatus: blocStatus ?? BlocStatus.initial,
      deleteReason: deleteReason ?? this.deleteReason,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

enum BlocStatus {
  initial,
  error,
  loading,
  verifyPasswordSuccess,
  deleteAccountSuccess,
}
