import 'dart:async';
import 'package:admineventpro/entities/models/admin_auth.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'manage_event.dart';
part 'manage_state.dart';

class ManageBloc extends Bloc<ManageEvent, ManageState> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  bool isPasswordVisible = false;

  ManageBloc() : super(ManageInitial()) {
    on<TextFieldTextChanged>(validateTextField);
    on<TextFieldPasswordChanged>(validatePasswordField);
    on<TogglePasswordVisibility>(togglePasswordVisibility);
    on<AuthenticationError>((event, emit) {
      emit(AuthenticatedErrors(message: event.errorMessage));
    });

    // Handle login
    on<LoginEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final userCredential = await auth.signInWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );
        final user = userCredential.user;
        if (user != null) {
          print('Account is authenticated');
          emit(Authenticated(
              UserModel(uid: user.uid, email: user.email, password: '')));
        } else {
          emit(UnAthenticated());
          Get.snackbar('eror', 'not authenticated');
          print('Authentication failed');
        }
      } catch (e) {
        emit(AuthenticatedErrors(message: 'not authenticated'));
        print('Authentication failed: $e');
      }
    });

    // Handle sign-up
    on<SignUp>((event, emit) async {
      emit(AuthLoading());
      try {
        final userCredential = await auth.createUserWithEmailAndPassword(
          email: event.userModel.email.toString(),
          password: event.userModel.password.toString(),
        );
        final user = userCredential.user;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
            'uid': user.uid,
            'email': user.email,
            'password': event.userModel.password,
            'createdAt': DateTime.now(),
          });
          print('Account is authenticated');
          emit(Authenticated(
              UserModel(uid: user.uid, email: user.email, password: '')));
        } else {
          emit(UnAthenticated());
        }
      } catch (e) {
        emit(AuthenticatedErrors(message: e.toString()));
        print('Authentication failed: $e');
      }
    });

    // Handle logout
    on<Logout>((event, emit) async {
      try {
        await auth.signOut();
        emit(UnAthenticated());
      } catch (e) {
        emit(AuthenticatedErrors(message: e.toString()));
      }
    });

// // Handle splash Screen...!

//     on<CheckUserEvent>((event, emit) async {
//       emit(AuthLoading());
//       User? user;
//       try {
//         await Future.delayed(Duration(seconds: 2), () {
//           user = auth.currentUser;
//         });
//         if (user != null) {
//           emit(Authenticated(
//               UserModel(uid: user!.uid, email: user!.email, password: '')));
//         } else {
//           emit(UnAthenticated());
//         }
//       } catch (e) {
//         emit(AuthenticatedErrors(message: e.toString()));
//       }
//     });

// user Checking...!

    on<CheckUserEvent>((event, emit) async {
      emit(AuthLoading());
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('uid');
      final email = prefs.getString('email');
      if (uid != null && email != null) {
        emit(Authenticated(UserModel(uid: uid, email: email, password: '')));
      } else {
        final user = auth.currentUser;
        if (user != null) {
          emit(Authenticated(
              UserModel(uid: user.uid, email: user.email, password: '')));
        } else {
          emit(UnAthenticated());
        }
      }
    });
  }
  Future<void> saveAuthState(String uid, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('uid', uid);
    await prefs.setString('email', email);
  }

  Future<void> clearAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('uid');
    await prefs.remove('email');
  }

  // validation...!

  FutureOr<void> validateTextField(
      TextFieldTextChanged event, Emitter<ManageState> emit) {
    try {
      emit(isValidEmail(event.text)
          ? TextValid()
          : TextInvalid(message: 'Enter valid email'));
    } catch (e) {
      emit(AuthenticatedErrors(message: e.toString()));
    }
  }

  bool isValidEmail(String text) {
    return text.isNotEmpty && text.contains('@gmail.com');
  }

  FutureOr<void> validatePasswordField(
      TextFieldPasswordChanged event, Emitter<ManageState> emit) {
    try {
      emit(isValidPassword(event.password)
          ? passwordValid()
          : passwordInvalid(message: 'Enter valid password'));
    } catch (e) {
      emit(AuthenticatedErrors(message: e.toString()));
    }
  }

  bool isValidPassword(String password) {
    return password.isNotEmpty && password.length >= 6;
  }

// view Password...!

  FutureOr<void> togglePasswordVisibility(
      TogglePasswordVisibility event, Emitter<ManageState> emit) {
    isPasswordVisible = !isPasswordVisible;
    emit(PasswordVisibilityToggled(isPasswordVisible));
  }
}
