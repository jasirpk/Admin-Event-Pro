import 'package:admineventpro/bussiness_layer/entities/repos/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:admineventpro/data_layer/services/generated_vendor.dart';

class FormSubmitManager {
  static Future<void> submitForm({
    required BuildContext context,
    required String categoryName,
    required String description,
    required String location,
    required List<Map<String, dynamic>> imagesData,
    required String? imageUrl,
    required Map<String, double> budget,
    required TextEditingController locationController,
    required TextEditingController nameEditingController,
    required TextEditingController descriptionEditingController,
    required TextEditingController fromBudgetController,
    required TextEditingController toBudgetController,
    required List<TextEditingController> imageNameControllers,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        double? fromBudget;
        double? toBudget;
        try {
          fromBudget = double.parse(fromBudgetController.text);
          toBudget = double.parse(toBudgetController.text);
        } catch (e) {
          showCustomSnackBar('Error', 'Invalid budget values');
          return;
        }

        budget = {
          'from': fromBudget,
          'to': toBudget,
        };

        await GeneratedVendor().addGeneratedCategoryDetail(
          uid: user.uid,
          categoryName: categoryName,
          description: description,
          location: location,
          images: imagesData,
          imagePath: imageUrl!,
          budget: budget,
          context: context,
          validate: false,
        );

        locationController.clear();
        nameEditingController.clear();
        descriptionEditingController.clear();
        fromBudgetController.clear();
        toBudgetController.clear();
        imageNameControllers.forEach((controller) => controller.clear());

        print('Vendor details added');
      } else {
        showCustomSnackBar("Error", "User is not authenticated");
      }
    } catch (e) {
      showCustomSnackBar("Error", "Failed to add vendor details: $e");
      print('Failed to add vendor details: $e');
    }
  }
}
