part of 'manage_bloc.dart';

@immutable
abstract class ManageEvent {}

// Athentication...loin..!

class CheckLoginStausEvent extends ManageEvent {}

class LoginEvent extends ManageEvent {
  final String email;
  final String message;

  LoginEvent({required this.email, required this.message});
}
// Athentication...Sign Up..!

class SignUp extends ManageEvent {
  final AdminModel adminModel;

  SignUp({required this.adminModel});
}

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
