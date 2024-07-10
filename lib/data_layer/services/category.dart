import 'dart:developer';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  Stream<QuerySnapshot> getVendorDetail(String Entrepreneur) {
    return FirebaseFirestore.instance
        .collection('Categories')
        .where('value', isEqualTo: Entrepreneur)
        .snapshots();
  }

  Future<DocumentSnapshot> getCategoryDetailById(String id) async {
    try {
      DocumentSnapshot docSanpshot = await FirebaseFirestore.instance
          .collection('Categories')
          .doc(id)
          .get();
      return docSanpshot;
    } catch (e) {
      log('Error fetching category detail by ID: $e');
      print('Data Can\'t find in database');
      rethrow;
    }
  }

  // Stream<QuerySnapshot> searchSubcategorie(
  //     String categoryId, String searchTerm) {
  //   if (categoryId.isEmpty || searchTerm.isEmpty) {
  //     print('categoryId and searchTerm must not be empty');
  //     return Stream.empty(); // Return an empty stream if parameters are invalid
  //   }

  //   try {
  //     print('Searching for: $searchTerm in category: $categoryId');
  //     return FirebaseFirestore.instance
  //         .collection('Categories')
  //         .doc(categoryId) // Assuming categoryId is the document ID
  //         .collection(
  //             'subcategories') // Adjust this path based on your Firestore structure
  //         .where('categoryName', isGreaterThanOrEqualTo: searchTerm)
  //         .where('categoryName', isLessThanOrEqualTo: searchTerm + '\uf8ff')
  //         .snapshots();
  //   } catch (e) {
  //     print('Error executing query: $e');
  //     return Stream.empty(); // Return an empty stream on error
  //   }
  // }
}
