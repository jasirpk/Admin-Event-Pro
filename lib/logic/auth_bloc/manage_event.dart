part of 'manage_bloc.dart';

@immutable
abstract class ManageEvent {}

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

// logout..!

class Logout extends ManageEvent {}

// Form validation...!

class TextFieldTextChanged extends ManageEvent {
  final String text;

  TextFieldTextChanged({required this.text});
}

class TextFieldPasswordChanged extends ManageEvent {
  final String password;

  TextFieldPasswordChanged({required this.password});
}

// view Password...!

class TogglePasswordVisibility extends ManageEvent {}

class AuthenticationError extends ManageEvent {
  final String errorMessage;
  AuthenticationError(this.errorMessage);
}

// check User...!
class CheckUserEvent extends ManageEvent {}

// Google auth..!

class GoogleAuth extends ManageEvent {}

class SignOutWithGoogle extends ManageEvent {}

// facebook auth...!
class FaceBookAuth extends ManageEvent {}

class SignOutWithFacebook extends ManageEvent {}
