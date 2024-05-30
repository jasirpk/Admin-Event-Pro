part of 'manage_bloc.dart';

@immutable
abstract class ManageEvent {}

// Athentication...loin..!

// class login extends ManageEvent {}

class LoginEvent extends ManageEvent {
  final String email;
  final String password;
  LoginEvent({required this.email, required this.password});
}
// Athentication...Sign Up..!

class SignUp extends ManageEvent {
  final UserModel userModel;

  SignUp({required this.userModel});
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

class Logout extends ManageEvent {}

class AuthenticationError extends ManageEvent {
  final String errorMessage;
  AuthenticationError(this.errorMessage);
}

// check User...!
class CheckUserEvent extends ManageEvent {}
