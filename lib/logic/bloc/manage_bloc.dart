// import 'dart:async';
// import 'package:admineventpro/entities/models/admin_auth.dart';
// import 'package:bloc/bloc.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:meta/meta.dart';

// part 'manage_event.dart';
// part 'manage_state.dart';

// class ManageBloc extends Bloc<ManageEvent, ManageState> {
//   final FirebaseAuth auth = FirebaseAuth.instance;
//   bool isPasswordVisible = false;

//   ManageBloc() : super(ManageInitial()) {
//     on<TextFieldTextChanged>(validateTextField);
//     on<TextFieldPasswordChanged>(validatePasswordField);
//     on<TogglePasswordVisibility>(togglePasswordVisiblity);
//     on<ValidateFields>(validateFields);
//     on<AuthenticationError>((event, emit) {
//       emit(AuthenticatedErrors(message: event.errorMessage));
//     });

//     // login ...!

//     on<login>((event, emit) async {
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

// // sign Up...!

//     on<SignUp>((event, emit) async {
//       emit(AuthLoading());

//       try {
//         final userCredential = await auth.createUserWithEmailAndPassword(
//             email: event.userModel.email.toString(),
//             password: event.userModel.password.toString());

//         final user = userCredential.user;
//         if (user != null) {
//           FirebaseFirestore.instance.collection('users').doc(user.uid).set({
//             'uid': user.uid,
//             'email': user.email,
//             'password': event.userModel.password,
//             'createdAt': DateTime.now()
//           });
//           print('account is Authenticated');
//           emit(Authenticated(
//               UserModel(uid: user.uid, email: user.email, password: '')));
//         } else {
//           emit(UnAthenticated());
//         }
//       } catch (e) {
//         emit(AuthenticatedErrors(message: e.toString()));
//         // Authentication failed, handle error
//         print('Authentication failed: $e');
//         // Display error message to the user
//         Get.snackbar('eror', 'not authenticated');
//       }
//     });

//     // logout...!

//     on<Logout>((event, emit) async {
//       try {
//         await auth.signOut();
//         emit(UnAthenticated());
//       } catch (e) {
//         emit(AuthenticatedErrors(message: e.toString()));
//       }
//     });

//     on<LoginEvent>((event, emit) async {
//       emit(AuthLoading());
//       try {
//         // Send sign-in link to the provided email
//         await auth.sendSignInLinkToEmail(
//           email: event.email,
//           actionCodeSettings: ActionCodeSettings(
//             url: 'YOUR_DYNAMIC_LINK_DOMAIN',
//             handleCodeInApp: true,
//           ),
//         );

//         print('Sign-in link sent to ${event.email}');
//         // You can emit an event indicating that the sign-in link has been sent if needed
//       } catch (e) {
//         emit(AuthenticatedErrors(message: e.toString()));
//         print('Error sending sign-in link: $e');
//       }
//     });
//   }

//   // validateEmailField...!

//   FutureOr<void> validateTextField(
//       TextFieldTextChanged event, Emitter<ManageState> emit) {
//     try {
//       emit(isValidEmail(event.text)
//           ? TextValid()
//           : TextInvalid(message: 'Enter Valid Email'));
//     } catch (e) {
//       emit(AuthenticatedErrors(message: e.toString()));
//     }
//   }

//   bool isValidEmail(String text) {
//     return text.isNotEmpty && text.contains('@gmail.');
//   }

//   // validatePasswordField...!

//   FutureOr<void> validatePasswordField(
//       TextFieldPasswordChanged event, Emitter<ManageState> emit) {
//     try {
//       emit(isValidPassword(event.password)
//           ? passwordValid()
//           : passwordInvalid(message: 'Enter Valid Password'));
//     } catch (e) {
//       emit(AuthenticatedErrors(message: e.toString()));
//     }
//   }

//   bool isValidPassword(String password) {
//     return password.isNotEmpty && password.length >= 6;
//   }

//   // password Visibility Icon..!

//   FutureOr<void> togglePasswordVisiblity(
//       TogglePasswordVisibility event, Emitter<ManageState> emit) {
//     isPasswordVisible = !isPasswordVisible;
//     emit(PasswordVisibilityToggled(isPasswordVisible));
//   }

// // validate Form...!

//   FutureOr<void> validateFields(
//       ValidateFields event, Emitter<ManageState> emit) {
//     final isEmailvalid = isValidEmail(event.Email);
//     final isPasswordValid = isValidPassword(event.Password);

//     if (event.Email.isEmpty) {
//       emit(TextInvalid(message: 'Email Address Requied'));
//     } else if (!isEmailvalid) {
//       emit(TextInvalid(message: 'Enter Valid Email'));
//     } else if (event.Password.isEmpty) {
//       emit(passwordInvalid(message: 'Password Required'));
//     } else if (!isPasswordValid) {
//       emit(passwordInvalid(message: 'Enter Valid Password'));
//     } else {
//       emit(ValidatonSuccess());
//     }
//   }
// }
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
    on<ValidateFields>(validateFields);
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

  FutureOr<void> togglePasswordVisibility(
      TogglePasswordVisibility event, Emitter<ManageState> emit) {
    isPasswordVisible = !isPasswordVisible;
    emit(PasswordVisibilityToggled(isPasswordVisible));
  }

  // Future<void> initializePersistence() async {
  //   await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  // }

  FutureOr<void> validateFields(
      ValidateFields event, Emitter<ManageState> emit) {
    final isEmailValid = isValidEmail(event.Email);
    final isPasswordValid = isValidPassword(event.Password);

    if (event.Email.isEmpty) {
      emit(TextInvalid(message: 'Email address required'));
    } else if (!isEmailValid) {
      emit(TextInvalid(message: 'Enter valid email'));
    } else if (event.Password.isEmpty) {
      emit(passwordInvalid(message: 'Password required'));
    } else if (!isPasswordValid) {
      emit(passwordInvalid(message: 'Enter valid password'));
    } else {
      emit(ValidatonSuccess());
    }
  }
}
