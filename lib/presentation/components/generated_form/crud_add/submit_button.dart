import 'dart:io';

import 'package:admineventpro/bussiness_layer/repos/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:admineventpro/data_layer/services/generated_vendor.dart';
import 'package:admineventpro/data_layer/services/vendor_api_service.dart';
import 'package:get/get.dart';

class FormSubmitManager {
  /// Uploads every image to R2 and registers the listing.
  ///
  /// Throws on every failure rather than reporting one itself. The caller
  /// already wraps this in a try/catch that shows a snackbar, so swallowing a
  /// failure here used to produce two messages at once — an error *and*
  /// "Succesfully Registered", because control returned normally. One
  /// thrower, one reporter.
  ///
  /// [templateImageKey] is the selected sub-category's existing R2 key, used
  /// as the main image when the user did not pick their own. It is passed
  /// separately from [mainImageFile] so the two can never be confused: one is
  /// a reference to stored media, the other is bytes to upload.
  static Future<VendorCreation> submitForm({
    required BuildContext context,
    required String categoryName,
    required String description,
    required String location,
    required List<Map<String, dynamic>> imagesData,
    required Map<String, double> budget,
    required TextEditingController locationController,
    required TextEditingController nameEditingController,
    required TextEditingController descriptionEditingController,
    required TextEditingController fromBudgetController,
    required TextEditingController toBudgetController,
    required List<TextEditingController> imageNameControllers,
    File? mainImageFile,
    String? templateImageKey,
    String? categoryId,
    String? subCategoryId,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw VendorApiException('Please sign in again to register a vendor.');
    }

    final double fromBudget;
    final double toBudget;

    try {
      fromBudget = double.parse(fromBudgetController.text);
      toBudget = double.parse(toBudgetController.text);
    } catch (_) {
      throw VendorApiException('Invalid budget values');
    }

    budget = {
      'from': fromBudget,
      'to': toBudget,
    };

    // The API rejects surrounding whitespace rather than trimming it, so a
    // stray space from a text field would otherwise come back as an opaque 400.
    final creation = await GeneratedVendor().addGeneratedCategoryDetail(
      categoryName: categoryName.trim(),
      description: description.trim(),
      location: location.trim(),
      images: imagesData,
      budget: budget,
      mainImageFile: mainImageFile,
      templateImageKey: templateImageKey,
      categoryId: categoryId,
      subCategoryId: subCategoryId,
      context: context,
    );

    // Only reached on success, so the form is never cleared after a failure —
    // the user keeps what they typed and can retry.
    locationController.clear();
    nameEditingController.clear();
    descriptionEditingController.clear();
    fromBudgetController.clear();
    toBudgetController.clear();
    for (final controller in imageNameControllers) {
      controller.clear();
    }
    Navigator.pop(context);
    showCustomSnackBar('Success', 'Successfully Registered');
    return creation;
  }
}
