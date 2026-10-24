import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Shows the auth loading dialog, at most one at a time.
///
/// Both auth screens listen to the same app-wide ManageBloc and both react
/// to `AuthLoading`. While the signup screen is open, sign-in is still
/// mounted beneath it, so one state would otherwise stack two identical
/// dialogs and a single dismissal would leave one behind.
void showLoadingDialog() {
  if (Get.isDialogOpen ?? false) return;

  Get.dialog(
    const Center(child: CircularProgressIndicator()),
    barrierDismissible: false,
  );
}

/// Closes the auth loading dialog, and only that.
///
/// The auth listeners used to call `Navigator.pop()` unconditionally,
/// assuming a dialog was open. When one was not — a state arriving without a
/// preceding `AuthLoading`, such as the error emitted by a failed Google
/// sign-out during logout — the pop consumed a page route instead. Once the
/// stack was empty, every later pop threw `Bad state: No element`.
///
/// `Get.isDialogOpen` is authoritative because these dialogs are now opened
/// with `Get.dialog`, which registers them with GetX; a plain `showDialog`
/// would not be tracked.
void dismissLoadingDialog() {
  if (Get.isDialogOpen ?? false) Get.back();
}

void showCustomSnackBar(String title, String message) {
  Get.snackbar(
    '',
    '',
    titleText: Text(
      title,
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    ),
    messageText: Text(
      message,
      style: TextStyle(
        color: Colors.white,
        fontSize: 14,
      ),
    ),
    snackPosition: SnackPosition.TOP,
    backgroundColor: Colors.teal,
    borderRadius: 10,
    margin: EdgeInsets.all(10),
    icon: Icon(
      Icons.info,
      color: Colors.white,
    ),
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    duration: Duration(seconds: 3),
    isDismissible: true,
    forwardAnimationCurve: Curves.easeOutBack,
    reverseAnimationCurve: Curves.easeInBack,
  );
}
