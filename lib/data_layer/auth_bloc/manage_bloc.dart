import 'dart:async';
import 'dart:developer';
import 'package:admineventpro/bussiness_layer/entities/logic_models/admin_auth.dart';
import 'package:admineventpro/presentation/pages/dashboard/home.dart';
import 'package:admineventpro/presentation/pages/onboarding_pages/welcome_admin.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
            email: event.email, password: event.password);

        final user = userCredential.user!;
        await saveAuthState(user.uid, user.email!);

        print('Account is authenticated');
        emit(Authenticated(
            UserModel(uid: user.uid, email: user.email, password: '')));
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
              .collection('entrepreneurs')
              .doc(user.uid)
              .set({
            'uid': user.uid,
            'email': user.email,
            'password': event.userModel.password,
            'createdAt': DateTime.now(),
          });
          await saveAuthState(user.uid, user.email!);
          print('Account is authenticated');
          print('Current FirebaseAuth user UID: ${user.uid}');
          print('Current FirebaseAuth user Email: ${user.email}');
          emit(Authenticated(
              UserModel(uid: user.uid, email: user.email!, password: '')));
        } else {
          emit(UnAthenticated());
        }
      } catch (e) {
        emit(AuthenticatedErrors(message: e.toString()));
        print('Authentication failed: $e');
      }
    });

// storing data in SharedPreference...!

    on<CheckUserEvent>((event, emit) async {
      emit(AuthLoading());
      await Future.delayed(Duration(seconds: 2));
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('uid');
      final email = prefs.getString('email');

      print('SharedPreferences UID: $uid');
      print('SharedPreferences Email: $email');

      if (uid != null) {
        print('User found in SharedPreferences');
        Get.offAll(() => HomeScreen());
        emit(Authenticated(UserModel(uid: uid, email: email, password: '')));
      } else {
        print('User not found in SharedPreferences, checking FirebaseAuth');
        print('User NOt found in FirebaseAuth');
        emit(UnAthenticated());

        Get.offAll(() => WelcomeAdmin());
        final user = auth.currentUser;
        if (user != null) {
          print('User found in FirebaseAuth');
          Get.offAll(() => HomeScreen());
          emit(Authenticated(
              UserModel(uid: user.uid, email: user.email, password: '')));
        } else {
          print('User NOt found in FirebaseAuth');
          Get.offAll(() => WelcomeAdmin());
          emit(UnAthenticated());
        }
      }
    });

    // // Handle logout
    on<Logout>((event, emit) async {
      try {
        await auth.signOut();
        clearAuthState();
        emit(UnAthenticated());
      } catch (e) {
        emit(AuthenticatedErrors(message: e.toString()));
      }
    });

// Google Auth...!
    on<GoogleAuth>((event, emit) async {
      emit(AuthLoading());

      try {
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

        if (googleUser == null) {
          // User canceled the Google sign-in process
          emit(AuthenticatedErrors(message: 'Google sign-in canceled'));
          return;
        }

        final GoogleSignInAuthentication? googleAuth =
            await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken,
          idToken: googleAuth?.idToken,
        );

        final userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);

        final user = userCredential.user;
        if (user != null) {
          // Authentication successful, save user data and emit Authenticated state
          await saveAuthState(user.uid, user.email!);
          emit(Authenticated(
              UserModel(uid: user.uid, email: user.email!, password: '')));
          print('Google Authentication successful');
        } else {
          // Failed to get user after authentication
          emit(AuthenticatedErrors(
              message: 'Failed to authenticate with Google'));
        }
      } catch (e) {
        // Error during authentication process
        emit(AuthenticatedErrors(message: 'Google authentication error: $e'));
      }
    });

// Google Sign-out..!
    on<SignOutWithGoogle>((event, emit) async {
      try {
        await GoogleSignIn().signOut();
        clearAuthState();
      } catch (e) {
        emit(AuthenticatedErrors(message: 'signOut error'));
      }
    });

// Handle the Facebook Auth...!

    on<FaceBookAuth>((event, emit) async {
      emit(AuthLoading());
      try {
        final LoginResult result =
            await FacebookAuth.instance.login(permissions: [
          'email',
        ]);

        if (result.status == LoginStatus.success) {
          final OAuthCredential FacebookAuthCredential =
              FacebookAuthProvider.credential(result.accessToken!.tokenString);
          final userCredential =
              await auth.signInWithCredential(FacebookAuthCredential);
          final user = userCredential.user!;

          await saveAuthState(user.uid, user.email!);

          print('facebook account is authenticated');
          emit(Authenticated(
              UserModel(uid: user.uid, email: user.email, password: '')));
        } else {
          emit(AuthenticatedErrors(
              message: 'Facebook login failed:${result.message}'));
        }
      } catch (e) {
        emit(AuthenticatedErrors(message: 'facebook errors$e'));
      }
    });

// facebook signOut...!

    on<SignOutWithFacebook>((event, emit) async {
      try {
        await FacebookAuth.instance.logOut();
        clearAuthState();
        emit(UnAthenticated());
      } catch (e) {
        emit(AuthenticatedErrors(message: 'Facebook clear statement error'));
      }
    });
  }

// User Credential storing in Sharedpreference...!

  Future<void> saveAuthState(String uid, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('uid', uid);
    await prefs.setString('email', email);
    log('Saved UID: $uid');
    log('Saved Email: $email');
  }

// User Credential clearing..!

  Future<void> clearAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('uid');
    await prefs.remove('email');
    log('Cleared UID and Email from SharedPreferences');
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
