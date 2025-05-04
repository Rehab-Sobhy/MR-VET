abstract class RegisterState {}

final class RegisterInitial extends RegisterState {}

final class RegisterSuccess extends RegisterState {}

final class RegisterFailed extends RegisterState {
  final String errMessage;
  final String? emailError;
  final String? phoneError;
  final String? passwordError;

  RegisterFailed({
    required this.errMessage,
    this.emailError,
    this.phoneError,
    this.passwordError,
  });
}

final class RegisterLoading extends RegisterState {}
