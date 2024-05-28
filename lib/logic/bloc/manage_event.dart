part of 'manage_bloc.dart';

@immutable
abstract class ManageEvent {}

class SplashEventStatus extends ManageEvent {}

class TextFieldTextChanged extends ManageEvent {
  final String text;

  TextFieldTextChanged({required this.text});
}

class TextFieldPasswordChanged extends ManageEvent {
  final String password;

  TextFieldPasswordChanged({required this.password});
}

class TogglePasswordVisibility extends ManageEvent {}

class ValidateFields extends ManageEvent {
  final String Email;
  final String Password;

  ValidateFields({required this.Email, required this.Password});
}
