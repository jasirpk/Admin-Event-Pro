import 'dart:async';
import 'dart:developer';
import 'package:admineventpro/bussiness_layer/entities/admin_auth.dart';
import 'package:admineventpro/presentation/pages/dashboard/home.dart';
import 'package:admineventpro/presentation/pages/onboarding_pages/welcome_admin.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
      emit(AuthLoading(true));

      try {
        final userCredential = await auth.signInWithEmailAndPassword(
            email: event.email, password: event.password);

        final user = userCredential.user!;
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('entrepreneurs')
            .doc(user.uid)
            .get();
        String platform = userDoc['platform'];

        if (platform == 'mobile') {
          await saveAuthState(user.uid, user.email ?? '');
          print('Account is authenticated');
          emit(Authenticated(
              UserModel(uid: user.uid, email: user.email, password: '')));
        }
      } catch (e) {
        emit(AuthenticatedErrors(message: 'not authenticated'));
        print('Authentication failed: $e');
      }
    });

    on<SignUp>((event, emit) async {
      emit(AuthLoading(true));
      try {
        final userCredential = await auth.createUserWithEmailAndPassword(
          email: event.userModel.email ?? '',
          password: event.userModel.password ?? '',
        );
        final user = userCredential.user;
        if (user != null) {
          // Account bookkeeping only. The password is never persisted: the
          // entrepreneur document is readable by consumers once an admin sets
          // isValid, so anything stored here is effectively public. Firebase
          // Auth already holds the credential.
          await FirebaseFirestore.instance
              .collection('entrepreneurs')
              .doc(user.uid)
              .set({
            'uid': user.uid,
            'email': user.email,
            'platform': 'mobile',
            'isActive': true,
            'createdAt': DateTime.now(),
          }, SetOptions(merge: true));
          await saveAuthState(user.uid, user.email!);
          print('Account is authenticated');
          print('Current FirebaseAuth user UID: ${user.uid}');
          print('Current FirebaseAuth user Email: ${user.email}');

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

// Startup authentication check...!

    /// Decides where a cold start lands, using Firebase Auth as the only
    /// authority on whether anyone is signed in.
    ///
    /// The uid in SharedPreferences is a local mirror, not a credential, and
    /// it outlives the thing it mirrors in two ordinary situations: Android
    /// Auto Backup restores `shared_prefs/` on reinstall (the manifest
    /// declares no android:allowBackup, so it defaults to true), and a
    /// sign-out that failed part-way leaves it behind. This used to enter
    /// Home on that string alone, which put the dashboard in front of a user
    /// Firebase had never heard of — every authenticated read then failed and
    /// the page rendered blank.
    on<CheckUserEvent>((event, emit) async {
      emit(AuthLoading(true));

      // The splash has a deliberate two-second dwell. Starting it here rather
      // than awaiting it first means the auth work happens *during* that
      // dwell instead of after it, so the check is free in wall-clock terms.
      final minimumSplash = Future<void>.delayed(const Duration(seconds: 2));

      final user = await _restoredUser();

      if (user == null) {
        // Nothing to honour, so remove the mirror before it is read again.
        await clearAuthState();
        await minimumSplash;
        emit(UnAthenticated());
        Get.offAll(() => WelcomeAdmin());
        return;
      }

      if (!await _hasUsableCredential(user)) {
        await auth.signOut();
        await clearAuthState();
        await minimumSplash;
        emit(UnAthenticated());
        Get.offAll(() => WelcomeAdmin());
        return;
      }

      await minimumSplash;
      emit(Authenticated(
        UserModel(uid: user.uid, email: user.email, password: ''),
      ));
      Get.offAll(() => HomeScreen());
    });

    // // Handle logout
    on<Logout>((event, emit) async {
      try {
        await auth.signOut();
        await clearAuthState();
        emit(UnAthenticated());
      } catch (e) {
        emit(AuthenticatedErrors(message: e.toString()));
      }
    });

// Google Auth...!
    on<GoogleAuth>((event, emit) async {
      emit(AuthLoading(true));

      try {
        final GoogleSignIn googleSignIn = GoogleSignIn.instance;

        await googleSignIn.initialize();

        final GoogleSignInAccount googleUser =
            await googleSignIn.authenticate();

        final GoogleSignInAuthentication googleAuth = googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );

        final userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);

        final user = userCredential.user;

        if (user != null) {
          await saveAuthState(
            user.uid,
            user.email ?? '',
          );

          emit(
            Authenticated(
              UserModel(
                uid: user.uid,
                email: user.email,
                password: '',
              ),
            ),
          );
        }
      } catch (e) {
        emit(
          AuthenticatedErrors(message: e.toString()),
        );
        log(e.toString());
      }
    });

    // Google Sign-out..!
    on<SignOutWithGoogle>((event, emit) async {
      try {
        await GoogleSignIn.instance.signOut();
        await clearAuthState();
      } catch (e) {
        emit(AuthenticatedErrors(message: 'signOut error'));
      }
    });

// Handle the Facebook Auth...!

    on<FaceBookAuth>((event, emit) async {
      emit(AuthLoading(true));
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
        await clearAuthState();
        emit(UnAthenticated());
      } catch (e) {
        emit(AuthenticatedErrors(message: 'Facebook clear statement error'));
      }
    });
  }

  /// The signed-in user once Firebase has finished restoring a persisted
  /// session, or null if there is none.
  ///
  /// `currentUser` is null for a short while after `Firebase.initializeApp`
  /// while the stored session is read back from disk (Android) or the
  /// Keychain (iOS), so reading it directly at startup is a race that
  /// intermittently reports "signed out" for a user who is signed in. The
  /// first event from [FirebaseAuth.authStateChanges] is emitted exactly when
  /// that restore has settled.
  Future<User?> _restoredUser() async {
    try {
      return await auth
          .authStateChanges()
          .first
          .timeout(const Duration(seconds: 8));
    } catch (error) {
      // A stalled or failed stream must not strand the app on the splash
      // screen; whatever Firebase has restored by now is the best answer
      // available, and null simply routes to the welcome screen.
      log('Auth state restore failed, falling back to currentUser: $error');
      return auth.currentUser;
    }
  }

  /// Whether [user] still has a credential the backend would accept.
  ///
  /// A restored or long-idle session can have been revoked, disabled or
  /// deleted server-side, and the local user object says nothing about that —
  /// only a forced token refresh does. Without this an entering user reaches
  /// Home and every authenticated request then fails with a 401.
  Future<bool> _hasUsableCredential(User user) async {
    try {
      await user.getIdToken(true);
      return true;
    } on FirebaseAuthException catch (error) {
      if (_rejectedSessionCodes.contains(error.code)) {
        log('Session rejected by Firebase (${error.code})');
        return false;
      }

      // Anything else is a transport problem, not a verdict on the session:
      // network-request-failed, too-many-requests, an unreachable host.
      // Firebase still holds a valid refresh token, so signing the user out
      // here would log them out every time they opened the app offline.
      log('Could not refresh the ID token (${error.code}) — keeping session');
      return true;
    } catch (error) {
      // Same reasoning for a non-Firebase failure, e.g. a socket error.
      log('Could not refresh the ID token ($error) — keeping session');
      return true;
    }
  }

  /// Firebase error codes that mean the session itself is finished, as
  /// opposed to a request that merely failed to complete.
  static const Set<String> _rejectedSessionCodes = {
    'user-not-found',
    'user-disabled',
    'user-token-expired',
    'invalid-user-token',
    'user-mismatch',
    'invalid-credential',
  };

// User Credential storing in Sharedpreference...!

  Future<void> saveAuthState(String uid, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('uid', uid);
    await prefs.setString('email', email);
    // Merge, never replace: this runs on every sign-in, and a replacing set()
    // wiped companyName, isValid, images, links and the server-owned rating
    // aggregate each time. Merging also keeps the write within what the
    // security rules allow, since it no longer removes guarded fields.
    await FirebaseFirestore.instance.collection('entrepreneurs').doc(uid).set({
      'uid': uid,
      'email': email,
    }, SetOptions(merge: true));
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
