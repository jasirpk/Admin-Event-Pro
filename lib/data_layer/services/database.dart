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
}
