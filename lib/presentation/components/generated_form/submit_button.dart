import 'package:admineventpro/bussiness_layer/entities/repos/snackbar.dart';
import 'package:admineventpro/data_layer/services/generated_vendor.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VendorDetailsManager {
  static Future<void> addVendorDetails({
    required String categoryName,
    required String description,
    required String location,
    required List<Map<String, dynamic>> imagesData,
    required String? imageUrl,
    required Map<String, double> budget,
    required BuildContext context,
    required TextEditingController locationController,
    required TextEditingController nameEditingController,
    required TextEditingController descriptionEditingController,
    required TextEditingController FromBudgetController,
    required TextEditingController ToBudgetController,
    required List<TextEditingController> imageNameControllers,
  }) async {
    String? imagePath = imageUrl;
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        Get.back();
        // Add vendor details to Firebase or your preferred backend
        await GeneratedVendor().addGeneratedCategoryDetail(
          uid: user.uid,
          categoryName: categoryName,
          description: description,
          location: location,
          images: imagesData,
          imagePath: imagePath!,
          budget: budget,
          context: context,
          validate: false,
        );

        // Show success message
        showCustomSnackBar("Success", "Details Added Successfully");

        // Clear form fields after successful submission
        locationController.clear();
        nameEditingController.clear();
        descriptionEditingController.clear();
        FromBudgetController.clear();
        ToBudgetController.clear();
        imageNameControllers.forEach((controller) => controller.clear());

        print('Vendor details added');
      } else {
        // Show error message if user is not authenticated
        showCustomSnackBar("Error", "User is not authenticated");
      }
    } catch (e) {
      // Show error message if there's an exception
      showCustomSnackBar("Error", "Failed to add vendor details: $e");
      print('Failed to add vendor details: $e');
    }
  }
}
