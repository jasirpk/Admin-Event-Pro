part of 'manage_bloc.dart';

@immutable
abstract class ManageState {}

class ManageInitial extends ManageState {}

class NavigateToWelcomeScreen extends ManageState {}

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
