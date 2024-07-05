import 'package:admineventpro/bussiness_layer/entities/repos/snackbar.dart';
import 'package:admineventpro/data_layer/services/generated_vendor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showDeleteConfirmationDialog({
  required String uid,
  required String documentId,
  required GeneratedVendor generatedVendor,
}) {
  Get.defaultDialog(
    title: 'Delete Confirmation',
    middleText: 'Are you sure you want to delete this vendor?',
    textCancel: 'Cancel',
    textConfirm: 'Delete',
    confirmTextColor: Colors.white,
    onCancel: () {
      Get.back();
    },
    onConfirm: () async {
      try {
        await generatedVendor.deleteGeneratedCategoryDetail(uid, documentId);
        Get.back();
        showCustomSnackBar('Success', 'Deleted Succesfully');
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to delete vendor: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    },
  );
}
