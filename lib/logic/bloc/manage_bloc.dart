import 'dart:async';
import 'package:admineventpro/entities/models/admin_auth.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meta/meta.dart';

part 'manage_event.dart';
part 'manage_state.dart';

class ManageBloc extends Bloc<ManageEvent, ManageState> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  bool isPasswordVisible = false;

  ManageBloc() : super(ManageInitial()) {
    on<TextFieldTextChanged>(validateTextField);
    on<TextFieldPasswordChanged>(validatePasswordField);
    on<TogglePasswordVisibility>(togglePasswordVisiblity);
    on<ValidateFields>(validateFields);
    on<AuthenticationError>((event, emit) {
      emit(AuthenticatedErrors(message: event.errorMessage));
    });

    // login ...!

    on<login>((event, emit) async {
      emit(AuthLoading());
      User? user;
      try {
        await Future.delayed(Duration(seconds: 2), () {
          user = auth.currentUser;
        });
        if (user != null) {
          emit(Authenticated(
              UserModel(uid: user!.uid, email: user!.email, password: '')));
        } else {
          emit(UnAthenticated());
        }
      } catch (e) {
        emit(AuthenticatedErrors(message: e.toString()));
      }
    });

// sign Up...!

    on<SignUp>((event, emit) async {
      emit(AuthLoading());

      try {
        final userCredential = await auth.createUserWithEmailAndPassword(
            email: event.userModel.email.toString(),
            password: event.userModel.password.toString());

        final user = userCredential.user;
        if (user != null) {
          FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'email': user.email,
            'password': event.userModel.password,
            'createdAt': DateTime.now()
          });
          print('account is Authenticated');
          emit(Authenticated(
              UserModel(uid: user.uid, email: user.email, password: '')));
        } else {
          emit(UnAthenticated());
        }
      } catch (e) {
        emit(AuthenticatedErrors(message: e.toString()));
        // Authentication failed, handle error
        print('Authentication failed: $e');
        // Display error message to the user
        Get.snackbar('eror', 'not authenticated');
      }
    });

    // logout...!

    on<Logout>((event, emit) async {
      try {
        await auth.signOut();
        emit(UnAthenticated());
      } catch (e) {
        emit(AuthenticatedErrors(message: e.toString()));
      }
    });

    // LoginEvent...!

    on<LoginEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final userCredential = await auth.signInWithEmailAndPassword(
            email: event.email, password: event.password);

        final user = userCredential.user;

        if (user != null) {
          print('account is Authenticated');
          emit(Authenticated(
              UserModel(uid: user.uid, email: user.email, password: '')));
        } else {
          emit(UnAthenticated()); // Authentication failed, handle error
          print('Authenticated fail');
          // Display error message to the user
          Get.snackbar('eror', 'not authenticated');
        }
      } catch (e) {
        emit(AuthenticatedErrors(message: e.toString()));
        // Authentication failed, handle error
        print('Authentication failed: $e');
        // Display error message to the user
        Get.snackbar('eror', 'not authenticated');
      }
    });
  }

  // validateEmailField...!

  FutureOr<void> validateTextField(
      TextFieldTextChanged event, Emitter<ManageState> emit) {
    try {
      emit(isValidEmail(event.text)
          ? TextValid()
          : TextInvalid(message: 'Enter Valid Email'));
    } catch (e) {
      emit(AuthenticatedErrors(message: e.toString()));
    }
  }

  bool isValidEmail(String text) {
    return text.isNotEmpty && text.contains('@gmail.');
  }

  // validatePasswordField...!

  FutureOr<void> validatePasswordField(
      TextFieldPasswordChanged event, Emitter<ManageState> emit) {
    try {
      emit(isValidPassword(event.password)
          ? passwordValid()
          : passwordInvalid(message: 'Enter Valid Password'));
    } catch (e) {
      emit(AuthenticatedErrors(message: e.toString()));
    }
  }

  bool isValidPassword(String password) {
    return password.isNotEmpty && password.length >= 6;
  }

  // password Visibility Icon..!

  FutureOr<void> togglePasswordVisiblity(
      TogglePasswordVisibility event, Emitter<ManageState> emit) {
    isPasswordVisible = !isPasswordVisible;
    emit(PasswordVisibilityToggled(isPasswordVisible));
  }

  Future<void> initializePersistence() async {
    await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  }
// validate Form...!

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
}
