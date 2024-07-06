import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UserProfile {
  Future<void> addProfile({
    required String uid,
    required String companyName,
    required String about,
    required String imagePath,
    required String phoneNumber,
    required String emailAddress,
    required String website,
    required List<Map<String, dynamic>> images,
    required List<Map<String, dynamic>> links,
  }) async {
    try {
      // Upload images and get URLs
      List<Map<String, dynamic>> imageUrlList = await uploadImages(images);

      // Upload profile image and get URL
      String finalImagePath = await uploadImageToFirebase(File(imagePath));

      // Create a reference to the generatedVendors collection and the specific document for the user
      DocumentReference documentRef =
          FirebaseFirestore.instance.collection('generatedVendors').doc(uid);

      // Set the data for the document
      await documentRef.set({
        'companyName': companyName,
        'description': about,
        'website': website,
        'phoneNumber': phoneNumber,
        'emailAddress': emailAddress,
        'profileImage':
            finalImagePath, // Assuming you want to save the profile image URL
        'images': imageUrlList,
        'links': links,
        'createdAt': FieldValue.serverTimestamp(),
      });

      log('Vendor details added successfully to sub-collection.');
    } catch (e) {
      log('Error adding user Profile to sub-collection: $e');
      throw Exception('Failed to add user Profile: $e');
    }
  }

  Future<List<Map<String, dynamic>>> uploadImages(
      List<Map<String, dynamic>> images) async {
    List<Map<String, dynamic>> uploadedImages = [];
    for (var image in images) {
      if (image['image'] != null) {
        try {
          String imageUrl = await uploadImageToFirebase(File(image['image']));
          uploadedImages.add({'image': imageUrl});
        } catch (e) {
          log('Failed to upload one of the images: $e');
          throw Exception('Failed to upload images: $e');
        }
      }
    }
    return uploadedImages;
  }

  Future<String> uploadImageToFirebase(File image) async {
    try {
      // Create a unique file name for the image
      String fileName =
          'profile_images/${DateTime.now().millisecondsSinceEpoch}_${image.path.split('/').last}';

      // Get a reference to Firebase Storage
      Reference storageRef = FirebaseStorage.instance.ref().child(fileName);

      // Upload the image file to Firebase Storage
      UploadTask uploadTask = storageRef.putFile(image);
      TaskSnapshot snapshot = await uploadTask;

      // Get the download URL of the uploaded image
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      log('Failed to upload image: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<void> updateProfile({
    required String uid,
    String? companyName,
    String? about,
    String? imagePath,
    String? phoneNumber,
    String? emailAddress,
    String? website,
    List<Map<String, dynamic>>? images,
    List<Map<String, dynamic>>? links,
  }) async {
    try {
      Map<String, dynamic> updateData = {};

      if (companyName != null) updateData['companyName'] = companyName;
      if (about != null) updateData['description'] = about;
      if (phoneNumber != null) updateData['phoneNumber'] = phoneNumber;
      if (emailAddress != null) updateData['emailAddress'] = emailAddress;
      if (website != null) updateData['website'] = website;

      if (imagePath != null) {
        String finalImagePath = await uploadImageToFirebase(File(imagePath));
        updateData['profileImage'] = finalImagePath;
      }

      if (images != null) {
        List<Map<String, dynamic>> imageUrlList = await uploadImages(images);
        updateData['images'] = imageUrlList;
      }

      if (links != null) {
        updateData['links'] = links;
      }

      DocumentReference documentRef =
          FirebaseFirestore.instance.collection('generatedVendors').doc(uid);

      await documentRef.update(updateData);

      log('User profile updated successfully.');
    } catch (e) {
      log('Error updating user profile: $e');
      throw Exception('Failed to update user profile: $e');
    }
  }

  Future<void> deleteProfile(String uid) async {
    try {
      DocumentReference documentRef =
          FirebaseFirestore.instance.collection('generatedVendors').doc(uid);

      await documentRef.delete();

      log('User profile deleted successfully.');
    } catch (e) {
      log('Error deleting user profile: $e');
      throw Exception('Failed to delete user profile: $e');
    }
  }
}
