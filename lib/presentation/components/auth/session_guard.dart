import 'package:admineventpro/data_layer/auth_bloc/manage_bloc.dart';
import 'package:admineventpro/presentation/pages/auth/sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

/// Renders [child] only while Firebase Auth actually holds a user.
///
/// Authenticated screens read `FirebaseAuth.instance.currentUser!.uid` in
/// their `State` field initialisers, so mounting one without a session throws
/// a null-check error and the tab paints as a blank grey box. This keeps them
/// unmounted instead — which also means no authenticated Firestore or Media
/// API call is ever issued without a session — and hands the app back to the
/// login screen once, if the session goes away while the screen is open.
///
/// This is a backstop, not the gate: startup already refuses to enter Home
/// without a validated session (see `CheckUserEvent`). It covers what startup
/// cannot — a sign-out from elsewhere, a disabled account, a deleted user.
class SessionGuard extends StatefulWidget {
  const SessionGuard({super.key, required this.child});

  final Widget child;

  @override
  State<SessionGuard> createState() => _SessionGuardState();
}

class _SessionGuardState extends State<SessionGuard> {
  /// At most one return-to-login per guard.
  ///
  /// The builder runs on every stream tick and on every ordinary rebuild, so
  /// without this a lost session would queue a fresh `Get.offAll` each frame.
  bool _leaving = false;

  void _returnToLogin() {
    if (_leaving) return;
    _leaving = true;

    // Read the bloc now: this runs during build, and the callback below fires
    // after this element may already be gone.
    final manageBloc = context.read<ManageBloc>();

    // Navigating from inside build() is not allowed, so defer by one frame.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // A uid left behind would be read back as a session on the next cold
      // start, which is the bug this whole guard exists to prevent.
      await manageBloc.clearAuthState();

      Get.offAll(() => GoogleAuthScreen());
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      // Without this the first frame has no data and would be read as "no
      // user", bouncing a perfectly good session back to the login screen.
      initialData: FirebaseAuth.instance.currentUser,
      builder: (context, snapshot) {
        final user = snapshot.data;

        if (user == null) {
          _returnToLogin();

          // Black rather than the default surface, so the hand-off to the
          // login screen is one continuous frame and never a grey flash.
          return const Scaffold(
            backgroundColor: Colors.black,
            body: SizedBox.expand(),
          );
        }

        return widget.child;
      },
    );
  }
}
