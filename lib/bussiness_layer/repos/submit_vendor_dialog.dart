import 'package:admineventpro/data_layer/models/profile_document.dart';
import 'package:admineventpro/data_layer/services/generated_vendor.dart';
import 'package:admineventpro/data_layer/services/profile.dart';
import 'package:admineventpro/presentation/pages/dashboard/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Listing ids whose submission is already running.
///
/// Module level on purpose. The three-dot menu lives inside a
/// `StatelessWidget` that a Firestore stream rebuilds on every write, so a
/// flag held in the widget would not reliably outlive the first tap.
final Set<String> _inFlight = <String>{};

@visibleForTesting
bool isSubmissionInFlight(String documentId) => _inFlight.contains(documentId);

@visibleForTesting
void resetSubmissionsInFlight() => _inFlight.clear();

/// Sends a generated listing to the admin, but only from an owner the admin
/// can identify.
///
/// The profile is read here, at the moment Submit is tapped, rather than
/// taken from whatever the profile screen last rendered: it may have been
/// edited on another device, saved since, or never filled in at all, and
/// only a fresh read can say which. An incomplete profile stops the
/// submission before any write — [GeneratedVendor.updateIsValidField] is
/// reached only for a profile the editor itself would accept.
///
/// The submission call and its arguments are unchanged; this only decides
/// whether it runs.
Future<void> submitGeneratedVendor({
  required String uid,
  required String documentId,
  required GeneratedVendor generatedVendor,
  UserProfile? userProfile,
}) async {
  // A second tap while the first is still in the air is the same request.
  if (!_inFlight.add(documentId)) return;

  try {
    final Map<String, dynamic>? profile;
    try {
      profile = await (userProfile ?? UserProfile()).getProfileData(uid);
    } catch (_) {
      // A failed read is not an incomplete profile. Saying so would send a
      // registered user off to re-fill a form that is already correct.
      _showError('Could not check your profile. Please try again.');
      return;
    }

    if (!isStoredProfileComplete(profile)) {
      showCompleteProfileDialog(profile);
      return;
    }

    await generatedVendor.updateIsValidField(uid, documentId, isSumbit: true);
  } catch (e) {
    _showError('Failed to submit vendor: $e');
  } finally {
    _inFlight.remove(documentId);
  }
}

/// Asks the user to finish their profile before the listing can be sent.
///
/// [profile] is whatever is stored today, and is handed to the editor so a
/// half-filled profile opens with its fields already populated rather than
/// blank — the same arguments the settings screen opens the editor with.
void showCompleteProfileDialog(Map<String, dynamic>? profile) {
  Get.defaultDialog(
    title: 'Complete Your Profile',
    middleText: 'Please complete your profile before submitting vendor '
        'details. This helps the admin identify and contact you.',
    textCancel: 'Cancel',
    textConfirm: 'Edit Profile',
    confirmTextColor: Colors.white,
    // No onCancel: Get.defaultDialog closes itself on cancel, and a
    // Get.back() here would pop the screen underneath as well.
    onConfirm: () {
      // Confirm, unlike cancel, does not close the dialog itself.
      Get.back();
      Get.to(() => ProfileScreen(
            companyName: profileText(profile?['companyName']),
            description: profileText(profile?['description']),
            phoneNumber: profileText(profile?['phoneNumber']),
            email: profileText(profile?['emailAddress']),
            website: profileText(profile?['website']),
            imagePath: profileText(profile?['profileImage']),
            portfolio: profilePortfolioRefs(profile?['images']),
            links: profileLinks(profile?['links']),
          ));
    },
  );
}

void _showError(String message) {
  Get.snackbar(
    'Error',
    message,
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: Colors.red,
    colorText: Colors.white,
  );
}
