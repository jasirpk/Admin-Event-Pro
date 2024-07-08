import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class subDatabaseMethods {
  Stream<QuerySnapshot> getSubcategories(String categoryId) {
    return FirebaseFirestore.instance
        .collection('Categories')
        .doc(categoryId)
        .collection('SubCategories')
        .snapshots();
  }

  Future<DocumentSnapshot> getSubCategoryId(
      String categoryId, String subCategoryId) async {
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('Categories')
          .doc(categoryId)
          .collection('SubCategories')
          .doc(subCategoryId)
          .get();
      if (!docSnapshot.exists) {
        print('Subcategory document does not exist for ID: $subCategoryId');
      }
      return docSnapshot;
    } catch (e) {
      log('Error fetching sub-category detail by ID: $e');
      rethrow;
    }
  }

  Stream<QuerySnapshot> getFavoriteSubcategories(String uid) {
    return FirebaseFirestore.instance
        .collection('generatedVendors')
        .doc(uid)
        .collection('favoritesItems')
        .snapshots();
  }

  Future<DocumentSnapshot> getFavoritesById(
      String uid, String subCategoryId) async {
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('generatedVendors')
          .doc(uid)
          .collection('favoritesItems')
          .doc(subCategoryId)
          .get();
      return docSnapshot;
    } catch (e) {
      log('Error fetching sub-category detail by ID: $e');
      rethrow;
    }
  }

  Future<void> toggleFavoriteStatus(
      String uid,
      String subCategoryName,
      String about,
      String imagePath,
      String subcategoryId,
      bool currentIsFavorite) async {
    try {
      DocumentReference docRef = FirebaseFirestore.instance
          .collection('generatedVendors')
          .doc(uid)
          .collection('favoritesItems')
          .doc(subcategoryId);

      bool newIsFavorite = !currentIsFavorite;

      String imageUrl = imagePath;

      if (newIsFavorite) {
        if (!imagePath.startsWith('http')) {
          imageUrl = await _uploadImage(uid, imagePath, subcategoryId);
        }

        await docRef.set({
          'isFavorite': true,
          'subCategoryName': subCategoryName,
          'about': about,
          'imagePath': imageUrl,
          'subCategory': subcategoryId,
          'timestamp': FieldValue.serverTimestamp(),
        });
      } else {
        await docRef.delete();
      }

      print('Favorite status updated successfully: $newIsFavorite');
    } catch (e) {
      print('Failed to update favorite status: $e');
      throw e;
    }
  }

  Future<String> _uploadImage(
      String uid, String imagePath, String subcategoryId) async {
    try {
      Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('users/$uid/favorited_images/$subcategoryId.jpg');

      UploadTask uploadTask = storageReference.putFile(File(imagePath));
      await uploadTask;

      String downloadURL = await storageReference.getDownloadURL();
      return downloadURL;
    } catch (e) {
      print('Error uploading image: $e');
      throw e;
    }
  }
}
