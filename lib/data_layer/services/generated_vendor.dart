import 'dart:developer';
import 'dart:typed_data';
import 'package:admineventpro/bussiness_layer/entities/repos/snackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class GeneratedVendor {
  Future<void> addGeneratedCategoryDetail(Map<String, dynamic> generatedData,
      String id, String imageName, Uint8List imageBytes,
      {bool isEditing = false}) async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('generatedVendors')
          .doc(id)
          .get();
      if (docSnapshot.exists && isEditing) {
      } else {
        String? imagePath = await uploadImage(id, imageName, imageBytes);
        if (imagePath != null) {
          generatedData['imagePath'] = imagePath;
          await FirebaseFirestore.instance
              .collection('generatedVendors')
              .doc(id)
              .set(generatedData);
          log('Vendor generatedCategory detail ${isEditing ? 'updated' : 'added'} successfully.');
          showCustomSnackBar(
              'Success', 'Vendor category detail Added successfully.');
        } else {
          showCustomSnackBar('Error', 'Vendor category detail Not added.');
        }
      }
    } catch (e) {
      log('Failed to upload image. Category detail not ${isEditing ? 'updated' : 'added'}.');
    }
  }

  Future<String?> uploadImage(
      String id, String imageName, Uint8List imageBytes) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('generated_images/$id/$imageName');
      UploadTask uploadTask = storageRef.putData(imageBytes);
      TaskSnapshot snapshot = await uploadTask.whenComplete(() => {});
      String downloadUrl = await snapshot.ref.getDownloadURL();

      log('Image uploaded successfully. URL: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      log('Error uploading image: $e');
      return null;
    }
  }
}
