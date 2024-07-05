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
        'validate': validate,
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
}
