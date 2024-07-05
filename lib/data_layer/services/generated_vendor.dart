import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class GeneratedVendor {
  Future<void> addGeneratedCategoryDetail({
    required String uid,
    required String categoryName,
    required String description,
    required String location,
    required List<Map<String, dynamic>> images,
    required String imagePath,
    required Map<String, double> budget,
    bool validate = false,
    BuildContext? context,
  }) async {
    try {
      // Upload images and get their download URLs
      List<Map<String, dynamic>> imageUrls = await uploadImages(images);
      String finalImagePath = imagePath;

      // Check if the imagePath is a local file path or a URL
      if (!imagePath.startsWith('http')) {
        // If it's a local file path, upload it to Firebase Storage
        finalImagePath = await uploadImageToFirebase(File(imagePath));
      }

      // Firestore document reference for sub-collection
      CollectionReference subCollectionRef = FirebaseFirestore.instance
          .collection('generatedVendors')
          .doc(uid)
          .collection('vendorDetails');

      // Add document data to sub-collection
      await subCollectionRef.add({
        'categoryName': categoryName,
        'description': description,
        'location': location,
        'images': imageUrls, // Include image URLs with corresponding text
        'imagePathUrl': finalImagePath,
        'budget': budget,
        'isValid': validate,
        'createdAt': FieldValue.serverTimestamp(),
      });

      log('Vendor details added successfully to sub-collection.');
    } catch (e) {
      log('Error adding vendor details to sub-collection: $e');
      throw Exception('Failed to add vendor details: $e');
    }
  }

  Future<List<Map<String, dynamic>>> uploadImages(
      List<Map<String, dynamic>> images) async {
    try {
      List<Map<String, dynamic>> imageUrls = [];
      for (var imageData in images) {
        File imageFile = imageData['image'];
        String text = imageData['text'];
        String imageUrl = await uploadImageToFirebase(imageFile);
        imageUrls.add({
          'imageUrl': imageUrl,
          'text': text, // Modify as per your requirement
        });
      }

      return imageUrls;
    } catch (e) {
      log('Error uploading images: $e');
      throw Exception('Failed to upload images');
    }
  }

  Future<String> uploadImageToFirebase(File imageFile) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('generated_images/${DateTime.now().millisecondsSinceEpoch}');
      UploadTask uploadTask = storageRef.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask.whenComplete(() => {});
      String downloadUrl = await snapshot.ref.getDownloadURL();

      log('Image uploaded successfully. URL: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      log('Error uploading image: $e');
      throw Exception('Failed to upload image');
    }
  }

  Future<DocumentSnapshot?> getCategoryDetailById(
      String uid, String documentId) async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('generatedVendors')
          .doc(uid)
          .collection('vendorDetails')
          .doc(documentId)
          .get();

      if (documentSnapshot.exists) {
        return documentSnapshot;
      } else {
        log('Document with ID $documentId not found.');
        return null;
      }
    } catch (e) {
      log('Error getting document by ID: $e');
      throw Exception('Failed to get document by ID: $e');
    }
  }

  Stream<QuerySnapshot> getGeneratedCategoryDetails(String uid) {
    return FirebaseFirestore.instance
        .collection('generatedVendors')
        .doc(uid)
        .collection('vendorDetails')
        .snapshots();
  }

  Future<void> updateGeneratedCategoryDetail({
    required String uid,
    required String documentId,
    String? categoryName,
    String? description,
    String? location,
    List<Map<String, dynamic>>? images,
    String? imagePath,
    Map<String, double>? budget,
    bool? validate,
  }) async {
    try {
      Map<String, dynamic> updateData = {};

      if (categoryName != null) updateData['categoryName'] = categoryName;
      if (description != null) updateData['description'] = description;
      if (location != null) updateData['location'] = location;
      if (budget != null) updateData['budget'] = budget;
      if (validate != null) updateData['isValid'] = validate;

      // Upload new images if provided
      if (images != null && images.isNotEmpty) {
        List<Map<String, dynamic>> imageUrls = await uploadImages(images);
        updateData['images'] = imageUrls;
      }

      // Upload new imagePath if provided and it's a local file path
      if (imagePath != null && !imagePath.startsWith('http')) {
        String finalImagePath = await uploadImageToFirebase(File(imagePath));
        updateData['imagePathUrl'] = finalImagePath;
      }

      await FirebaseFirestore.instance
          .collection('generatedVendors')
          .doc(uid)
          .collection('vendorDetails')
          .doc(documentId)
          .update(updateData);

      log('Vendor details updated successfully.');
    } catch (e) {
      log('Error updating vendor details: $e');
      throw Exception('Failed to update vendor details: $e');
    }
  }

  Future<void> deleteGeneratedCategoryDetail(
      String uid, String documentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('generatedVendors')
          .doc(uid)
          .collection('vendorDetails')
          .doc(documentId)
          .delete();

      log('Vendor details deleted successfully.');
    } catch (e) {
      log('Error deleting vendor details: $e');
      throw Exception('Failed to delete vendor details: $e');
    }
  }

  Future<void> updateIsValidField(String uid, String documentId,
      {required bool isSumbit}) async {
    try {
      CollectionReference vendorDetailsRef = FirebaseFirestore.instance
          .collection('generatedVendors')
          .doc(uid)
          .collection('vendorDetails');

      await vendorDetailsRef.doc(documentId).update({
        'isValid': isSumbit, // Set isValid to true
      });

      print('isValid field updated successfully.');
    } catch (e) {
      log('Error updating isValid field: $e');
      throw Exception('Failed to update isValid field: $e');
    }
  }
}
