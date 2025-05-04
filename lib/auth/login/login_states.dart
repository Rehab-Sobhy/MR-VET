abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final String token;

  LoginSuccess({required this.token});
}

class LoginFailed extends LoginState {
  final String errMessage;

  LoginFailed({required this.errMessage});
}
