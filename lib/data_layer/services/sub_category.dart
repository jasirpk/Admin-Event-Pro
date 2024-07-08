// import 'dart:developer';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class subDatabaseMethods {
//   Stream<QuerySnapshot> getSubcategories(String categoryId) {
//     return FirebaseFirestore.instance
//         .collection('Categories')
//         .doc(categoryId)
//         .collection('SubCategories')
//         .snapshots();
//   }

//   Future<DocumentSnapshot> getSubCategoryId(
//       String categoryId, String subCategoryId) async {
//     try {
//       DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
//           .collection('Categories')
//           .doc(categoryId)
//           .collection('SubCategories')
//           .doc(subCategoryId)
//           .get();
//       return docSnapshot;
//     } catch (e) {
//       log('Error fetching sub-category detail by ID: $e');
//       rethrow;
//     }
//   }

//   Stream<List<DocumentSnapshot>> getFavoriteSubcategories(String uid) async* {
//     try {
//       // Get favorite subcategory IDs
//       QuerySnapshot favoriteSnapshot = await FirebaseFirestore.instance
//           .collection('generatedVendors')
//           .doc(uid)
//           .collection('favorites')
//           .where('isFavorite', isEqualTo: true)
//           .get();

//       // Extract favorite subcategory IDs
//       List<String> favoriteIds =
//           favoriteSnapshot.docs.map((doc) => doc.id).toList();

//       // Fetch corresponding subcategory data
//       List<DocumentSnapshot> favoriteSubcategories = [];
//       for (int i = 0; i < favoriteIds.length; i++) {
//         DocumentSnapshot subcategorySnapshot = await FirebaseFirestore.instance
//             .collection('Categories')
//             .doc(uid) // Assuming uid is the categoryId here
//             .collection('SubCategories')
//             .doc(favoriteIds[i])
//             .get();
//         favoriteSubcategories.add(subcategorySnapshot);
//       }

//       yield favoriteSubcategories;
//     } catch (e) {
//       print('Failed to retrieve favorite subcategories: $e');
//       throw e;
//     }
//   }

//   Future<void> toggleFavoriteStatus(
//       String uid,
//       // String categoryId,
//       String subCategoryName,
//       String about,
//       String imagePath,
//       String subcategoryId,
//       bool currentIsFavorite) async {
//     try {
//       // Reference to the favorite document using subcategoryId
//       DocumentReference docRef = FirebaseFirestore.instance
//           .collection('generatedVendors')
//           .doc(uid)
//           .collection('favorites')
//           .doc(subcategoryId); // Use subcategoryId here

//       bool newIsFavorite = !currentIsFavorite;

//       if (newIsFavorite) {
//         // Add subcategory to favorites
//         await docRef.set({
//           'isFavorite': true, // Set isFavorite to true
//           // 'id': categoryId,
//           'subCategoryName': subCategoryName,
//           'about': about,
//           'imagePath': imagePath,
//           'subaCategory': subcategoryId,
//           'timestamp': FieldValue.serverTimestamp(),
//         });
//       } else {
//         // Remove subcategory from favorites
//         await docRef.delete();
//       }

//       print('Favorite status updated successfully: $newIsFavorite');
//     } catch (e) {
//       print('Failed to update favorite status: $e');
//       throw e;
//     }
//   }
// }
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
      return docSnapshot;
    } catch (e) {
      log('Error fetching sub-category detail by ID: $e');
      rethrow;
    }
  }

  Stream<List<DocumentSnapshot>> getFavoriteSubcategories(String uid) async* {
    try {
      // Get favorite subcategory IDs
      QuerySnapshot favoriteSnapshot = await FirebaseFirestore.instance
          .collection('generatedVendors')
          .doc(uid)
          .collection('favorites')
          .where('isFavorite', isEqualTo: true)
          .get();

      // Extract favorite subcategory IDs
      List<String> favoriteIds =
          favoriteSnapshot.docs.map((doc) => doc.id).toList();

      // Fetch corresponding subcategory data
      List<DocumentSnapshot> favoriteSubcategories = [];
      for (int i = 0; i < favoriteIds.length; i++) {
        DocumentSnapshot subcategorySnapshot = await FirebaseFirestore.instance
            .collection('Categories')
            .doc(uid) // Assuming uid is the categoryId here
            .collection('SubCategories')
            .doc(favoriteIds[i])
            .get();
        favoriteSubcategories.add(subcategorySnapshot);
      }

      yield favoriteSubcategories;
    } catch (e) {
      print('Failed to retrieve favorite subcategories: $e');
      throw e;
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
      // Reference to the favorite document using subcategoryId
      DocumentReference docRef = FirebaseFirestore.instance
          .collection('generatedVendors')
          .doc(uid)
          .collection('favorites')
          .doc(subcategoryId); // Use subcategoryId here

      bool newIsFavorite = !currentIsFavorite;

      String imageUrl = imagePath;

      if (newIsFavorite) {
        // Check if the imagePath is a local file path
        if (!imagePath.startsWith('http')) {
          // Upload the image to Firebase Storage
          imageUrl = await _uploadImage(uid, imagePath, subcategoryId);
        }

        // Add subcategory to favorites
        await docRef.set({
          'isFavorite': true, // Set isFavorite to true
          'subCategoryName': subCategoryName,
          'about': about,
          'imagePath': imageUrl,
          'subCategory': subcategoryId,
          'timestamp': FieldValue.serverTimestamp(),
        });
      } else {
        // Remove subcategory from favorites
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
      // Create a reference to the location you want to upload to in Firebase Storage
      Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('users/$uid/favorited_images/$subcategoryId.jpg');

      // Upload the file to Firebase Storage
      UploadTask uploadTask = storageReference.putFile(File(imagePath));
      await uploadTask;

      // Get the download URL of the uploaded image
      String downloadURL = await storageReference.getDownloadURL();
      return downloadURL;
    } catch (e) {
      print('Error uploading image: $e');
      throw e;
    }
  }
}
