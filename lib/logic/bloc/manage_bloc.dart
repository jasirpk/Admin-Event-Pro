import 'dart:async';
import 'package:admineventpro/entities/models/admin_auth.dart';
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';

part 'manage_event.dart';
part 'manage_state.dart';

class ManageBloc extends Bloc<ManageEvent, ManageState> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  bool isPasswordVisible = false;

  ManageBloc() : super(ManageInitial()) {
    on<CheckLoginStausEvent>(checkLoginEventStatus);
    on<TextFieldTextChanged>(validateTextField);
    on<TextFieldPasswordChanged>(validatePasswordField);
    on<TogglePasswordVisibility>(togglePasswordVisiblity);
    on<ValidateFields>(validateFields);
  }

  FutureOr<void> validateTextField(
      TextFieldTextChanged event, Emitter<ManageState> emit) {
    emit(isValidEmail(event.text)
        ? TextValid()
        : TextInvalid(message: 'Enter Valid Email'));
  }

  bool isValidEmail(String text) {
    return text.isNotEmpty && text.contains('@gmail.');
  }

  FutureOr<void> validatePasswordField(
      TextFieldPasswordChanged event, Emitter<ManageState> emit) {
    emit(isValidPassword(event.password)
        ? passwordValid()
        : passwordInvalid(message: 'Enter Valid Password'));
  }

  bool isValidPassword(String password) {
    return password.isNotEmpty && password.length >= 4;
  }

  FutureOr<void> togglePasswordVisiblity(
      TogglePasswordVisibility event, Emitter<ManageState> emit) {
    isPasswordVisible = !isPasswordVisible;
    emit(PasswordVisibilityToggled(isPasswordVisible));
  }

  FutureOr<void> validateFields(
      ValidateFields event, Emitter<ManageState> emit) {
    final isEmailvalid = isValidEmail(event.Email);
    final isPasswordValid = isValidPassword(event.Password);

    if (event.Email.isEmpty) {
      emit(TextInvalid(message: 'Email Address Requied'));
    } else if (!isEmailvalid) {
      emit(TextInvalid(message: 'Enter Valid Email'));
    } else if (event.Password.isEmpty) {
      emit(passwordInvalid(message: 'Password Required'));
    } else if (!isPasswordValid) {
      emit(passwordInvalid(message: 'Enter Valid Password'));
    } else {
      emit(ValidatonSuccess());
    }
  }

  FutureOr<void> checkLoginEventStatus(
      CheckLoginStausEvent event, Emitter<ManageState> emit) async {
    User? user;
    try {
      await Future.delayed(Duration(seconds: 2), () {
        user = auth.currentUser;
      });
      if (user != null) {
        emit(Authenticated(user as AdminModel));
      } else {
        emit(UnAthenticated());
      }
    } catch (e) {
      emit(AuthenticatedErrors(message: e.toString()));
    }
  }
}
