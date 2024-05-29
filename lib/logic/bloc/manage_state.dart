part of 'manage_bloc.dart';

@immutable
abstract class ManageState {}

class ManageInitial extends ManageState {}

//Auth...!

class AuthLoading extends ManageState {}

class Authenticated extends ManageState {
  final UserModel user;
  Authenticated(this.user);
}

class UnAthenticated extends ManageState {}

class AuthenticatedErrors extends ManageState {
  final String message;

  AuthenticatedErrors({required this.message});
}

class TextValid extends ManageState {}

class TextInvalid extends ManageState {
  final String message;

  TextInvalid({required this.message});
}

class passwordValid extends ManageState {}

class passwordInvalid extends ManageState {
  final String message;

  passwordInvalid({required this.message});
}

class PasswordVisibilityToggled extends ManageState {
  final bool isVisible;

  PasswordVisibilityToggled(this.isVisible);
}

class ValidatonSuccess extends ManageState {}
